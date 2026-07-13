CREATE PROCEDURE "informix".sp_fc_consnombresupana(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumEmp CHAR(20), pTipo CHAR(1))
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS nom_empleado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNomEmpleado CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNomEmpleado = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmpleado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_consnombresupana.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmpleado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmpleado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_desbctasfus_obtnombresupana(pNumEmp,pTipo) 
		INTO cCodRetSp,cNomEmpleado;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_desbctasfus_obtnombresupana';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '01150'; --NO. DE CLIENTE INVÃLIDO
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '01178'; --EL USUARIO NO ESTÃ AUTORIZADO PARA OPERAR LA APLICACIÃN
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01179'; --NO SE ENCONTRÃ EL ANALISTA SOLICITADO
		END IF;
		
		RETURN cCodRet,cNomEmpleado;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el nombre de los empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_consparam(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdConsulta CHAR(1),pFiltro CHAR(50))
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS valor;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_consparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pFiltro = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cValor;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
			SELECT 
			{+AVOID_FULL (bdinteg:"informix".si_param)}
			valor INTO cValor
			FROM bdinteg:"informix".si_param WHERE UPPER(descripcion) = pFiltro;
		ELIF pIdConsulta = '2' THEN
			SELECT 
			{+AVOID_FULL (bdinteg:"informix".si_param)}
			valor INTO cValor
			FROM bdinteg:"informix".si_param WHERE cod_param = pFiltro;
		END IF;
		
		IF NVL(cValor,'') = '' THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,cValor;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el valor del parametro consultado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_deletectetraspasa(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTraspasaCtas CHAR(20),pIdEjecucion CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_deletectetraspasa.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCteTraspasaCtas = '' OR pIdEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdEjecucion = '1' THEN
			
			DELETE FROM bdinteg:"informix".si_fuscliente WHERE numcte = pCteTraspasaCtas AND empresa = cEmpresa;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00862';
				RETURN cCodRet;
			END IF;
			
			DELETE FROM bdinteg:"informix".si_fusctepf WHERE numcte = pCteTraspasaCtas AND empresa = cEmpresa;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00862';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar la eliminacion de registros del cliente traspasa.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_desbctasfus(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pUsEjecuta CHAR(8),pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cEmp CHAR(3);
	DEFINE cCuenta CHAR(20);
	--DEFINE cCuenta LVARCHAR;
	DEFINE iRecuperacion INTEGER;
	DEFINE iContador INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET iRecuperacion = 0;	
	LET iContador = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_desbctasfus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCteTitular = '' OR pUsEjecuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_desbctasfus(pCteTitular,pCuenta,pUsEjecuta) 
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_desbctasfus';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00000'; --
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '01191'; --NO SE PUDO DESBLOQUEAR LA CUENTA DE DÃBITO
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01192'; --NO SE PUDO DESBLOQUEAR LA CUENTA DE CRÃDITO
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '01193'; --LA CUENTA DE CAPTACIÃN [] TIENE UN SALDO CONGELADO. NO SE PUEDE DESBLOQUEAR
		ELIF iCodRetSp = 5 THEN
			LET cCodRet = '01194'; --LA CUENTA DE CAPTACIÃN [] TIENE UN BLOQUEO DISTINTO DE FUSIÃN DE CLIENTES. NO SE PUEDE DESBLOQUEAR
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de realizar el desbloqueo de cuentas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detallecuentasdesb(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20),pAnalista CHAR(20),pRegistros INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS numcte,
		CHAR(20) AS cuenta,
		CHAR(4) AS producto,
		CHAR(40) AS descripcion,
		CHAR(2) AS status,
		MONEY(10,2) AS saldo,
		CHAR(10) AS usuario_bloqueo,
		DATE AS fecha_bloqueo,
		CHAR(10) AS supervisor_desbloqueo,
		DATE AS fecha_desbloqueo,
		CHAR(1) AS bloq_cred;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cStatusCta CHAR(2);
	DEFINE mSaldo MONEY(10,2);
	DEFINE cUsuario_bloqueo CHAR(10);
	DEFINE dFecha_bloqueo DATE;
	DEFINE cSupervisor_desbloqueo CHAR(10);
	DEFINE dFecha_desbloqueo DATE;
	DEFINE cBloqueo CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET cStatusCta = '';
	LET mSaldo = 0.00;
	LET cUsuario_bloqueo = '';
	LET dFecha_bloqueo = '';
	LET cSupervisor_desbloqueo = '';
	LET dFecha_desbloqueo = '';
	LET cBloqueo = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detallecuentasdesb.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT 
			{+AVOID_FULL (bdinteg:"informix".si_desbctasfus_cuentas)}
			SKIP pRegistros FIRST pRecuperacion 
			cuenta,producto,nombre,status,saldo,usuario_bloqueo,fecha_bloqueo,supervisor_desbloqueo,fecha_desbloqueo,bloq_cred
			INTO cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo
			FROM bdinteg:"informix".si_desbctasfus_cuentas 
			WHERE analista = pAnalista
			ORDER BY cuenta ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01186'; --EL CLIENTE FUSIONADO NO TIENE CUENTAS PARA DESBLOQUEAR
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,pNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas del cliente a desbloquear.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detallecuentasdesb_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20),pAnalista CHAR(20))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cStatusCta CHAR(2);
	DEFINE mSaldo MONEY(10,2);
	DEFINE cUsuario_bloqueo CHAR(10);
	DEFINE dFecha_bloqueo DATE;
	DEFINE cSupervisor_desbloqueo CHAR(10);
	DEFINE dFecha_desbloqueo DATE;
	DEFINE cBloqueo CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET cStatusCta = '';
	LET mSaldo = 0.00;
	LET cUsuario_bloqueo = '';
	LET dFecha_bloqueo = '';
	LET cSupervisor_desbloqueo = '';
	LET dFecha_desbloqueo = '';
	LET cBloqueo = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detallecuentasdesb_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_desbctasfus_consctas(pNumCte,pAnalista)
			INTO cCodRetSp,cNumCte,cCuenta,cProducto,cDescProducto,cStatusCta,mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,cBloqueo
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_desbctasfus_consctas';
			ELIF iCodRetSp = 100 THEN
				LET cCodRet = '01186'; --EL CLIENTE FUSIONADO NO TIENE CUENTAS PARA DESBLOQUEAR
				RETURN cCodRet,iNoRegistros;
			END IF;
		END FOREACH;
		
		SELECT 
		{+AVOID_FULL (bdinteg:"informix".si_desbctasfus_cuentas)}
		COUNT(*) INTO iNoRegistros
		FROM bdinteg:"informix".si_desbctasfus_cuentas WHERE analista = pAnalista;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01186'; --EL CLIENTE FUSIONADO NO TIENE CUENTAS PARA DESBLOQUEAR
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de cuentas del cliente a desbloquear.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detallecuentastraspasar(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20),pRegistros INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS numcte, 
		CHAR(20) AS cuenta, 
		CHAR(4) AS producto, 
		CHAR(40) AS descripcion, 
		DATE AS fecha_alta, 
		CHAR(2) AS status, 
		DATE AS fecha_ult_mov, 
		MONEY(16,2) AS saldo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE dFechaAlta DATE;
	DEFINE cStatusCta CHAR(2);
	DEFINE dFechaUltMov DATE;
	DEFINE mSaldo MONEY(16,2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET dFechaAlta = '';
	LET cStatusCta = '';
	LET dFechaUltMov = '';
	LET mSaldo = 0.00;
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detallecuentastraspasar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			numcte,cuenta,producto,descripcion,fecha_alta,status,fecha_ult_mov,saldo
			INTO cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo
			FROM bdicnweb:"informix".sw_fc_detcuentastraspasar
			WHERE usuario_insert = pUsuario
			ORDER BY id_registro ASC
			
			-- SE DESCARTAN PAGARÃS CANCELADOS
			IF cProducto = '3000' AND cStatusCta = '4' THEN
			ELSE
				IF cProducto IN ('6300','6800','7600','7700','7800') THEN
					LET cDescProducto = 'SOLICITUD DE PRESTAMO PERSONAL';
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo WITH RESUME;
			END IF;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas del cliente.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/06/2020',
'DESCRIPCION: Se modifica SPL para agregar validaciones por Producto.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 30/07/2020',
'DESCRIPCION: Se modifica SPL para eliminar acento en la descripcion del Producto (PRESTAMO).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detallecuentastraspasar_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE dFechaAlta DATE;
	DEFINE cStatusCta CHAR(2);
	DEFINE dFechaUltMov DATE;
	DEFINE mSaldo MONEY(16,2);
	DEFINE iNoRegistros INTEGER;
	
	DEFINE iIdRegistro INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET dFechaAlta = '';
	LET cStatusCta = '';
	LET dFechaUltMov = '';
	LET mSaldo = 0.00;
	LET iNoRegistros = 0;
	
	LET iIdRegistro = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detallecuentastraspasar_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			SELECT id_registro INTO iIdRegistro 
			FROM bdicnweb:"informix".sw_fc_detcuentastraspasar WHERE usuario_insert = pUsuario
			
			DELETE FROM bdicnweb:"informix".sw_fc_detcuentastraspasar WHERE usuario_insert = pUsuario AND id_registro = iIdRegistro;
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consctastraspasar(pNumCte)
			INTO cCodRetSp,cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_consctastraspasar';
			ELIF iCodRetSp = 100 THEN
				LET cCodRet = '01152'; --NO. DE CLIENTE NO EXISTE
				RETURN cCodRet,iNoRegistros;
			ELIF iCodRetSp <> 0 THEN
				LET cCodRet = '01158'; --EL CLIENTE NO TIENE CUENTAS Y/O DOCUMENTOS A TRASPASAR
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			-- SE DESCARTAN PAGARÃS CANCELADOS
			IF cProducto = '3000' AND cStatusCta = '4' THEN
				LET iNoRegistros = iNoRegistros;
			ELSE
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			INSERT INTO bdicnweb:"informix".sw_fc_detcuentastraspasar(numcte,cuenta,producto,descripcion,fecha_alta,status,fecha_ult_mov,saldo,usuario_insert)
			VALUES(cNumCte,cCuenta,cProducto,cDescProducto,dFechaAlta,cStatusCta,dFechaUltMov,mSaldo,pUsuario);
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de cuentas del cliente.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/06/2020',
'DESCRIPCION: Se modifica SPL para agregar validaciones por Producto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detalledocsdigitalizados(pUsuario CHAR(8),pIdFuncion CHAR(10),pTipoCte CHAR(1),pNumCte CHAR(20),pRegistros INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS cod_docto,
		CHAR(35) AS desc_docto,
		CHAR(20) AS cuenta,
		SMALLINT AS secuencia,
		CHAR(10) AS fecha,
		CHAR(50) AS descripcion,
		CHAR(20) AS numcte,
		INTEGER AS id_registro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDesc_docto CHAR(35);
	DEFINE cCuenta CHAR(20);
	DEFINE sSecuencia SMALLINT;
	DEFINE cFecha CHAR(10);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNumCte CHAR(20);
	DEFINE iIdReg INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cCod_docto = '';
	LET cDesc_docto = '';
	LET cCuenta = '';
	LET sSecuencia = 0;
	LET cFecha = '';
	LET cDescripcion = '';
	LET cNumCte = '';
	LET iIdReg = 0;
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detalledocsdigitalizados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoCte = '' OR pNumCte = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			cod_docto,UPPER(desc_docto),cuenta,secuencia,fecha,UPPER(descripcion),numcte,id_registro
			INTO cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizados
			WHERE tipocte = pTipoCte AND usuario_insert = pUsuario
			ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01159'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cNumCte,iIdReg;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el detalle de los documentos digitalizados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detalledocsdigitalizadosdesb(pUsuario CHAR(8),pIdFuncion CHAR(10),pTipoCte CHAR(1),pNumCte CHAR(20),pRegistros INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS cod_docto,
		CHAR(35) AS desc_docto,
		CHAR(20) AS cuenta,
		SMALLINT AS secuencia,
		CHAR(10) AS fecha,
		CHAR(50) AS descripcion,
		CHAR(4) AS cuenta_valida,
		CHAR(20) AS numcte,
		INTEGER AS id_registro,
		CHAR(4) AS producto,
		CHAR(40) AS desc_producto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDesc_docto CHAR(35);
	DEFINE cCuenta CHAR(20);
	DEFINE sSecuencia SMALLINT;
	DEFINE cFecha CHAR(10);
	DEFINE cDescripcion CHAR(50);
	DEFINE cCuentaValida CHAR(4);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cNumCte CHAR(20);
	DEFINE iIdReg INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cCod_docto = '';
	LET cDesc_docto = '';
	LET cCuenta = '';
	LET sSecuencia = 0;
	LET cFecha = '';
	LET cDescripcion = '';
	LET cCuentaValida = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET cNumCte = '';
	LET iIdReg = 0;
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detalledocsdigitalizadosdesb.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			cod_docto,UPPER(desc_docto),cuenta,secuencia,fecha,UPPER(descripcion),cuenta_valida,numcte,id_registro,producto,UPPER(desc_producto)
			INTO cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizadosdesb
			WHERE usuario_insert = pUsuario
			ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01190'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS PARA EL CLIENTE TITULAR
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cNumCte,iIdReg,cProducto,cDescProducto;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el detalle de documentos digitalizados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detalledocsdigitalizados_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pTipoCte CHAR(1),pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDesc_docto CHAR(35);
	DEFINE cCuenta CHAR(20);
	DEFINE sSecuencia SMALLINT;
	DEFINE cFecha CHAR(10);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNumCte CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	DEFINE iIdRegistro INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cCod_docto = '';
	LET cDesc_docto = '';
	LET cCuenta = '';
	LET sSecuencia = 0;
	LET cFecha = '';
	LET cDescripcion = '';
	LET cNumCte = '';
	LET iNoRegistros = 0;
	
	LET iIdRegistro = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detalledocsdigitalizados_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoCte = '' OR pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			SELECT id_registro INTO iIdRegistro 
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizados WHERE tipocte = pTipoCte AND usuario_insert = pUsuario
			
			DELETE FROM bdicnweb:"informix".sw_fc_detdocsdigitalizados WHERE tipocte = pTipoCte AND usuario_insert = pUsuario AND id_registro = iIdRegistro;
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerdoctos(pNumCte,0,500)
			INTO cCodRetSp,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_obtenerdoctos';
			ELIF iCodRetSp = 100 THEN
				LET cCodRet = '01159'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_fc_detdocsdigitalizados(cod_docto,desc_docto,cuenta,secuencia,fecha,descripcion,numcte,tipocte,usuario_insert)
			VALUES(cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,pNumCte,pTipoCte,pUsuario);
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01159'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los documentos digitalizados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_ejecutalog(pUsuario CHAR(8),pIdFuncion CHAR(10),pUsEjecuta CHAR(20),pAbreAplic CHAR(2),pFusion CHAR(2),
pFechaAbreApli DATETIME YEAR TO SECOND,pHraAbreApli DATETIME HOUR TO FRACTION(3),pFechaFus DATETIME YEAR TO SECOND,pHraFus DATETIME HOUR TO FRACTION(3),
pUsNoAut CHAR(20),pCteTit CHAR(20),pCteTras CHAR(20),pStatus CHAR(100),pTipoRep CHAR(1),pBandera CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_ejecutalog.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_logfsnctes(pUsEjecuta,pAbreAplic,pFusion,
		pFechaAbreApli,pHraAbreApli,pFechaFus,pHraFus,pUsNoAut,pCteTit,pCteTras,pStatus,pTipoRep,pBandera) 
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_logfsnctes';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00282';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00283';
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de insertar/actualizar el registro del usuario al entrar al aplicativo dependiendo la situacion del cliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_historicodoctosfusionados(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCteTrasp CHAR(20),pRegistros INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS cliente,
		CHAR(20) AS cuenta,
		CHAR(4) AS cod_docto, 
		INTEGER AS secuencia, 
		CHAR(10) AS fecha_alta,
		CHAR(35) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iIdRegistro INTEGER;
	
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCodDocto CHAR(4);
	DEFINE iSecuencia INTEGER;
	DEFINE cFechaAlta CHAR(10);
	DEFINE cDescripcion CHAR(35);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
	LET iIdRegistro = 0;
	
	LET cCliente = '';
	LET cCuenta = '';
	LET cCodDocto = '';
	LET iSecuencia = 0;
	LET cFechaAlta = '';
	LET cDescripcion = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_historicodoctosfusionados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCteTrasp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			cliente,cuenta,cod_docto,secuencia,fecha_alta,UPPER(descripcion)
			INTO cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion
			FROM bdicnweb:"informix".sw_fc_rephistoricodoctos
			WHERE usuario_insert = pUsuario
			ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01201'; --EL CLIENTE NO TIENE DOCUMENTOS FUSIONADOS
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: REPORTE HISTÃRICO FUSIÃN DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el detalle de documentos fusionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_historicodoctosfusionados_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCteTrasp CHAR(20))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCodDocto CHAR(4);
	DEFINE iSecuencia INTEGER;
	DEFINE cFechaAlta CHAR(10);
	DEFINE cDescripcion CHAR(35);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	
	LET cCliente = '';
	LET cCuenta = '';
	LET cCodDocto = '';
	LET iSecuencia = 0;
	LET cFechaAlta = '';
	LET cDescripcion = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_historicodoctosfusionados_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCteTrasp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			SELECT id_registro INTO iIdRegistro 
			FROM bdicnweb:"informix".sw_fc_rephistoricodoctos WHERE usuario_insert = pUsuario
			
			SET ISOLATION TO DIRTY READ;
			DELETE FROM bdicnweb:"informix".sw_fc_rephistoricodoctos WHERE usuario_insert = pUsuario AND id_registro = iIdRegistro;
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_doctosfusionados(pNumCteTrasp)
			INTO cCodRetSp,cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_doctosfusionados';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '01201'; --EL CLIENTE NO TIENE DOCUMENTOS FUSIONADOS
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			INSERT INTO "informix".sw_fc_rephistoricodoctos(cliente,cuenta,cod_docto,secuencia,fecha_alta,descripcion,usuario_insert) 
			VALUES(cCliente,cCuenta,cCodDocto,iSecuencia,cFechaAlta,cDescripcion,pUsuario);
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01201'; --EL CLIENTE NO TIENE DOCUMENTOS FUSIONADOS
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: REPORTE HISTÃRICO FUSIÃN DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de documentos fusionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_historicofusion(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaDel DATE,pFechaAl DATE,pOpcion CHAR(1),pUsAnalista CHAR(8),pRegistros INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_tit,
		CHAR(110) AS nom_tit,
		CHAR(10) AS fechanac_tit,
		CHAR(20) AS num_trasp,
		CHAR(110) AS nom_trasp,
		CHAR(10) AS fechanac_trasp,
		CHAR(20) AS cta_trasp,
		CHAR(4) AS producto,
		CHAR(20) AS numcte,
		CHAR(2) AS status,
		MONEY(16,2) AS saldo,
		CHAR(40) AS descripcion,
		CHAR(10) AS fecha_alta,
		INTEGER AS num_direc,
		DATETIME YEAR TO SECOND AS fecha_fus,
		DATETIME HOUR TO FRACTION(3) AS hr_fus,
		CHAR(10) AS status_cta,
		CHAR(45) AS nom_analista;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cDia CHAR(2);
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cDiaHasta CHAR(2);
	DEFINE cMesHasta CHAR(2);
	DEFINE cAnioHasta CHAR(4);
	
	DEFINE cNumCteTit 		  CHAR(20);
	DEFINE cNumCteTrasp 	  CHAR(20);
	DEFINE cApePaterTit 	  CHAR(26);
	DEFINE cApeMaterTit 	  CHAR(26);
	DEFINE cNom1Tit 		  CHAR(26);
	DEFINE cNom2Tit 		  CHAR(26);
	DEFINE cFechaNacTit 	  CHAR(10);
	DEFINE cApePaterTrasp	  CHAR(26);
	DEFINE cApeMaterTrasp	  CHAR(26);
	DEFINE cNom1Trasp 		  CHAR(26);
	DEFINE cNom2Trasp 		  CHAR(26);
	DEFINE cFechaNacTrasp 	  CHAR(10);
	DEFINE cNomCompTitular 	  CHAR(110);
	DEFINE cNomCompTrasp 	  CHAR(110);
	DEFINE cNumCtaTrasp 	  CHAR(20);
	DEFINE cProducto 		  CHAR(4);
	DEFINE cNumCte 			  CHAR(20);
	DEFINE cStatus 			  CHAR(2);
	DEFINE mSaldo 			  MONEY(16,2);
	DEFINE cDescripcion 	  CHAR(40);
	DEFINE cFechaAlta 		  CHAR(10);
	DEFINE iNumDireccionesFus INTEGER;
	DEFINE dHoraFusion  	  DATETIME HOUR TO FRACTION(3);
	DEFINE cStatusCuenta      CHAR(10);
	DEFINE cNombreAnalista    CHAR(45);
	DEFINE dFechaFusion       DATE ;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
	LET iIdRegistro = 0;
	LET cDia = '';
	LET cMes = '';
	LET cAnio = '';
	LET cDiaHasta = '';
	LET cMesHasta = '';
	LET cAnioHasta = '';
	
	LET cNumCteTit 		      = '';
	LET cNumCteTrasp 	      = '';
	LET cApePaterTit 	      = '';
	LET cApeMaterTit 	      = '';
	LET cNom1Tit 		      = '';
	LET cNom2Tit 		      = '';
	LET cFechaNacTit 	      = '';
	LET cApePaterTrasp 	      = '';
	LET cApeMaterTrasp 	      = '';
	LET cNom1Trasp 		      = '';
	LET cNom2Trasp 		      = '';
	LET cFechaNacTrasp 	      = '';
	LET cNomCompTitular       = '';
	LET cNomCompTrasp 	      = '';
	LET cNumCtaTrasp 	      = '';
	LET cProducto 		      = '';
	LET cNumCte 		      = '';
	LET cStatus 		      = '';
	LET mSaldo 			      = 0;
	LET cDescripcion 	      = '';
	LET cFechaAlta 		      = '';
	LET iNumDireccionesFus 	  = 0;
	LET dHoraFusion 		  = '';
	LET cStatusCuenta 	      = '';
	LET cNombreAnalista       = '';
	LET dFechaFusion 		  = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_historicofusion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL OR pOpcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		END IF;
		
		-- VALIDACIÃâN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			numcte_tit,nombrecte_tit,fechanac_cte_tit,numcte_traspasado,nombrecte_traspasado,fechanac_cte_traspasado,numcta_traspasado,producto,
			numero_cliente,estatus,saldo,descripcion,fecha_alta,num_direcciones_fusionadas,fecha_fusion,hora_fusion,UPPER(status_cuenta),nombre_analista
			INTO cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista
			FROM bdicnweb:"informix".sw_fc_rephistorico
			WHERE usuario_insert = pUsuario
			ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01200'; --NO SE ENCONTRARON DATOS, FAVOR DE VERIFICAR
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: REPORTE HISTÃâRICO FUSIÃâN DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el detalle de clientes fusionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_obtienehuellas(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCteCorr CHAR(20),pNumCteInc CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(942) AS trama_1,
		CHAR(942) AS trama_2;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE iIsamErrorSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTrama_1 CHAR(942);
	DEFINE cTrama_2 CHAR(942);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET cEmpresa = '001';
	LET cTrama_1 = '';
	LET cTrama_2 = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTrama_1,cTrama_2;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_obtienehuellas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTrama_1,cTrama_2;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTrama_1,cTrama_2;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_obthuellasactes(pNumCteCorr,pNumCteInc) 
		INTO cCodRetSp,cTrama_1,cTrama_2;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_obthuellasactes';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '01171'; --FALTAN PARÃMETROS DE ENTRADA
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '01172'; --CLIENTE TITULAR NO EXISTE
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01173'; --CLIENTE A TRASPASAR NO EXISTE
		ELIF iCodRetSp = 6 THEN
			LET cCodRet = '01174'; --LOS CLIENTES CONSULTADOS YA TUVIERON LA COMPARACIÃN DE HUELLAS
		END IF;
		
		RETURN cCodRet,cTrama_1,cTrama_2;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar la informaciÃ³n de las huellas del cliente titular y cliente traspasa.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_respaldacargaimg(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iIsamErrorSp INT;
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInsImg CHAR(100);
	DEFINE cInsImgHis CHAR(100);
	DEFINE cRuta CHAR(50);
	DEFINE cArchUnl CHAR(20);
	
	DEFINE cEmp CHAR(3);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cCod_docto CHAR(4);
	DEFINE sSecuencia SMALLINT;
	DEFINE cProd_nombre CHAR(40);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cUsuario_alta CHAR(8);
	DEFINE dFecha_alta DATE;
	DEFINE cUsuario_modif CHAR(8);
	DEFINE dFecha_modif DATE;
	DEFINE cDetalleMov CHAR(200);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cInsImg = '';
	LET cInsImgHis = '';
	LET cRuta = '';
	LET cArchUnl = '';
	
	LET cEmp = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cCod_docto = '';
	LET sSecuencia = 0;
	LET cProd_nombre = '';
	LET cDescrip2 = '';
	LET cUsuario_alta = '';
	LET dFecha_alta = '';
	LET cUsuario_modif = '';
	LET dFecha_modif = '';
	LET cDetalleMov = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_respaldacargaimg.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(valor) INTO cRuta
		FROM bdinteg:"informix".si_param WHERE cod_param = 122;
		
		LET cArchUnl = 'img'||TRIM(pCteTraspasa)||'.unl';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_respalda_img(pCteTraspasa,cArchUnl,cRuta) 
		INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_respalda_img';
		ELIF iCodRetSp = 0 THEN
			
			EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_carga_img(pCteTraspasa,cArchUnl,cRuta) 
			INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_carga_img';
			ELIF iCodRetSp = 0 THEN
				
				FOREACH
					SELECT empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif
					INTO cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif
					FROM bdidigital@coppelimg_tcp:dg_expediente	
					WHERE cliente = pCteTraspasa AND empresa = '001'
					
					LET iNoRegistros = iNoRegistros + 1;
					INSERT INTO bdidigital@coppelimg_tcp:dg_expediente_fus(empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif)
					VALUES(cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif);
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					END IF;
				END FOREACH;
				
				DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img1 WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
			
			ELSE
				
				DELETE FROM bdinteg:"informix".si_fuscliente WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_fusctepf WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				LET cDetalleMov = 'CARGA DE IMAGENES NO REALIZADA'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ('RESPALDO IMAGEN','dg_expediente_img1',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				END IF;
                
				LET cCodRet = '01187'; --NO SE REALIZO CARGA DE IMAGENES
				
			END IF;
			
		ELSE
			
			DELETE FROM bdinteg:"informix".si_fuscliente WHERE numcte = pCteTraspasa AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			DELETE FROM bdinteg:"informix".si_fusctepf WHERE numcte = pCteTraspasa AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			LET cDetalleMov = 'RESPALDO DE IMAGENES NO REALIZADO'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('RESPALDO IMAGEN','dg_expediente_img1',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			END IF;
			
			LET cCodRet = '01188'; --NO SE REALIZO RESPALDO DE IMAGENES
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el respaldo y carga de imagenes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_respaldacargaimg2(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iIsamErrorSp INT;
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInsImg CHAR(100);
	DEFINE cInsImgHis CHAR(100);
	DEFINE cRuta CHAR(50);
	DEFINE cArchUnl CHAR(20);
	
	DEFINE cEmp CHAR(3);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cCod_docto CHAR(4);
	DEFINE sSecuencia SMALLINT;
	DEFINE cProd_nombre CHAR(40);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cUsuario_alta CHAR(8);
	DEFINE dFecha_alta DATE;
	DEFINE cUsuario_modif CHAR(8);
	DEFINE dFecha_modif DATE;
	DEFINE cDetalleMov CHAR(200);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cInsImg = '';
	LET cInsImgHis = '';
	LET cRuta = '';
	LET cArchUnl = '';
	
	LET cEmp = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cCod_docto = '';
	LET sSecuencia = 0;
	LET cProd_nombre = '';
	LET cDescrip2 = '';
	LET cUsuario_alta = '';
	LET dFecha_alta = '';
	LET cUsuario_modif = '';
	LET dFecha_modif = '';
	LET cDetalleMov = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_respaldacargaimg2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(valor) INTO cRuta
		FROM bdinteg:"informix".si_param WHERE cod_param = 122;
		
		LET cArchUnl = '2img'||TRIM(pCteTraspasa)||'.unl';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--EXECUTE PROCEDURE bdidigital@coppelimg20_tcp:"informix".sp_respalda_img2(pCteTraspasa,cArchUnl,cRuta) 
		EXECUTE PROCEDURE bdidigital@coppelimghis_tcp:"informix".sp_respalda_img2(pCteTraspasa,cArchUnl,cRuta) 
		INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_respalda_img2';
		ELIF iCodRetSp = 0 THEN
			
			EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_carga_img2(pCteTraspasa,cArchUnl,cRuta) 
			INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_carga_img2';
			ELIF iCodRetSp = 0 THEN
				
				FOREACH
					SELECT empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif
					INTO cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif
					FROM bdidigital@coppelimg_tcp:dg_expediente	
					WHERE cliente = pCteTraspasa AND empresa = '001'
					
					LET iNoRegistros = iNoRegistros + 1;
					INSERT INTO bdidigital@coppelimg_tcp:dg_expediente_fus(empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif)
					VALUES(cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif);
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					END IF;
				END FOREACH;
				
				--DELETE FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his WHERE cliente = pCteTraspasa AND empresa = '001';
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
			ELSE
				
				LET cDetalleMov = 'CARGA DE IMAGENES NO REALIZADA'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ('RESPALDO IMAGEN','dg_expediente_img_his',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
				END IF;
                
				LET cCodRet = '01187'; --NO SE REALIZO CARGA DE IMAGENES
				
			END IF;
			
		ELSE
			
			LET cDetalleMov = 'RESPALDO DE IMAGENES NO REALIZADO'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('RESPALDO IMAGEN','dg_expediente_img_his',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			END IF;
			
			LET cCodRet = '01188'; --NO SE REALIZO RESPALDO DE IMAGENES
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el respaldo y carga de imagenes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_respaldacargaimg3(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iIsamErrorSp INT;
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInsImg CHAR(100);
	DEFINE cInsImgHis CHAR(100);
	DEFINE cRuta CHAR(50);
	DEFINE cArchUnl CHAR(20);
	
	DEFINE cEmp CHAR(3);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cCod_docto CHAR(4);
	DEFINE sSecuencia SMALLINT;
	DEFINE cProd_nombre CHAR(40);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cUsuario_alta CHAR(8);
	DEFINE dFecha_alta DATE;
	DEFINE cUsuario_modif CHAR(8);
	DEFINE dFecha_modif DATE;
	DEFINE cDetalleMov CHAR(200);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cInsImg = '';
	LET cInsImgHis = '';
	LET cRuta = '';
	LET cArchUnl = '';
	
	LET cEmp = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cCod_docto = '';
	LET sSecuencia = 0;
	LET cProd_nombre = '';
	LET cDescrip2 = '';
	LET cUsuario_alta = '';
	LET dFecha_alta = '';
	LET cUsuario_modif = '';
	LET dFecha_modif = '';
	LET cDetalleMov = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_respaldacargaimg3.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(valor) INTO cRuta
		FROM bdinteg:"informix".si_param WHERE cod_param = 122;
		
		LET cArchUnl = '3img'||TRIM(pCteTraspasa)||'.unl';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--EXECUTE PROCEDURE bdidigital@coppelimg20_tcp:"informix".sp_respalda_img3(pCteTraspasa,cArchUnl,cRuta) 
		EXECUTE PROCEDURE bdidigital@coppelimghis_tcp:"informix".sp_respalda_img3(pCteTraspasa,cArchUnl,cRuta) 
		INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_respalda_img3';
		ELIF iCodRetSp = 0 THEN
			
			EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_carga_img3(pCteTraspasa,cArchUnl,cRuta) 
			INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:sp_carga_img3';
			ELIF iCodRetSp = 0 THEN
				
				FOREACH
					SELECT empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif
					INTO cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif
					FROM bdidigital@coppelimg_tcp:dg_expediente	
					WHERE cliente = pCteTraspasa AND empresa = '001'
					
					LET iNoRegistros = iNoRegistros + 1;
					INSERT INTO bdidigital@coppelimg_tcp:dg_expediente_fus(empresa,cliente,cuenta,producto,cod_docto,secuencia,prod_nombre,descrip2,usuario_alta,fecha_alta,usuario_modif,fecha_modif)
					VALUES(cEmp,cCliente,cCuenta,cProducto,cCod_docto,sSecuencia,cProd_nombre,cDescrip2,cUsuario_alta,dFecha_alta,cUsuario_modif,dFecha_modif);
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					END IF;
				END FOREACH;
				
				--DELETE FROM bdidigital@coppelimg20_tcp:dg_expediente_img WHERE cliente = pCteTraspasa AND empresa = '001';
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
			
			ELSE
				
				DELETE FROM bdinteg:"informix".si_fuscliente WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				DELETE FROM bdinteg:"informix".si_fusctepf WHERE numcte = pCteTraspasa AND empresa = '001';
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
				
				LET cDetalleMov = 'CARGA DE IMAGENES NO REALIZADA'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ('RESPALDO IMAGEN','dg_expediente_img',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				END IF;
                
				LET cCodRet = '01187'; --NO SE REALIZO CARGA DE IMAGENES
				
			END IF;
			
		ELSE
			
			DELETE FROM bdinteg:"informix".si_fuscliente WHERE numcte = pCteTraspasa AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			DELETE FROM bdinteg:"informix".si_fusctepf WHERE numcte = pCteTraspasa AND empresa = '001';
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
			
			LET cDetalleMov = 'RESPALDO DE IMAGENES NO REALIZADO'||'|'||TRIM(cCodRetSp)||'|'||iIsamErrorSp;
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('RESPALDO IMAGEN','dg_expediente_img',pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			END IF;
			
			LET cCodRet = '01188'; --NO SE REALIZO RESPALDO DE IMAGENES
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el respaldo y carga de imagenes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasodoctosinc(pUsuario CHAR(8),pIdFuncion CHAR(10),
pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8),pTipoCte CHAR(1),pBloqueInf CHAR(500),pIteracion CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInsImg CHAR(100);
	DEFINE cInsImgHis CHAR(100);
	DEFINE cCod_doctoDig CHAR(4);
	DEFINE cDesc_doctoDig CHAR(35);
	DEFINE cCuentaDig CHAR(20);
	DEFINE sSecuenciaDig SMALLINT;
	DEFINE cFechaDig CHAR(10);
	DEFINE cDescripcionDig CHAR(50);
	DEFINE cNumCteDig CHAR(20);
	DEFINE cEmp CHAR(3);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cCod_docto CHAR(4);
	DEFINE sSecuencia SMALLINT;
	DEFINE cProd_nombre CHAR(40);
	DEFINE cDescrip2 CHAR(30);
	DEFINE cUsuario_alta CHAR(8);
	DEFINE dFecha_alta DATE;
	DEFINE cUsuario_modif CHAR(8);
	DEFINE dFecha_modif DATE;
	DEFINE cTabla CHAR(30);
	DEFINE cDetalleMov CHAR(200);
	DEFINE cCuentaDg CHAR(20);
	DEFINE cProductoDg CHAR(4);
	DEFINE cCod_doctoDg CHAR(4);
	DEFINE sSecuenciaDg SMALLINT;
	DEFINE dFecha_altaDg DATE;
	DEFINE iMaxSec SMALLINT;
	
	DEFINE cValor1 CHAR(4);
	DEFINE cValor2 CHAR(6);
	DEFINE cValor3 CHAR(10);
	
	DEFINE cIdReg LVARCHAR;
	DEFINE iRecuperacion INTEGER;
	DEFINE iContador INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cInsImg = '';
	LET cInsImgHis = '';
	LET cCod_doctoDig = '';
	LET cDesc_doctoDig = '';
	LET cCuentaDig = '';
	LET sSecuenciaDig = 0;
	LET cFechaDig = '';
	LET cDescripcionDig = '';
	LET cNumCteDig = '';
	LET cEmp = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cProducto = '';
	LET cCod_docto = '';
	LET sSecuencia = 0;
	LET cProd_nombre = '';
	LET cDescrip2 = '';
	LET cUsuario_alta = '';
	LET dFecha_alta = '';
	LET cUsuario_modif = '';
	LET dFecha_modif = '';
	LET cTabla = '';
	LET cDetalleMov = '';
	LET cCuentaDg = '';
	LET cProductoDg = '';
	LET cCod_doctoDg = '';
	LET sSecuenciaDg = 0;
	LET dFecha_altaDg = '';
	LET iMaxSec = 0;
	
	LET cValor1 = '';
	LET cValor2 = '';
	LET cValor3 = '';
	
	LET cIdReg = '';
	LET iRecuperacion = 0;	
	LET iContador = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasodoctosinc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCteTitular = '' OR pCteTraspasa = '' OR pUsEjecuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			EXECUTE PROCEDURE "informix".sp_split_cadena(pBloqueInf, '|')
			INTO cIdReg
			
			SELECT cod_docto,desc_docto,cuenta,secuencia,fecha,descripcion,numcte
			INTO cCod_doctoDig,cDesc_doctoDig,cCuentaDig,sSecuenciaDig,cFechaDig,cDescripcionDig,cNumCteDig
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizados
			WHERE usuario_insert = pUsuario AND id_registro = cIdReg;
			
			LET iRecuperacion = iRecuperacion + 1;
			
			SELECT cuenta,producto,cod_docto,secuencia,fecha_alta 
			INTO cCuenta,cProducto,cCod_docto,sSecuencia,dFecha_alta
			FROM bdidigital@coppelimg_tcp:dg_expediente 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001' AND cuenta = cCuentaDig;
			
			LET cTabla = 'dg_expediente';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||TRIM(cCuenta)||'|'||cProducto||'|'||cCod_docto||'|'||sSecuencia||'|'||dFecha_alta||'|'||'DOCUMENTO ELIMINADO';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('DG_EXPEDIENTE',cTabla,pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			END IF;
			
			SELECT cod_docto,secuencia,fecha_alta 
			INTO cValor1,cValor2,cValor3
			FROM bdidigital@coppelimg_tcp:dg_expediente_img1 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			
			LET cTabla = 'dg_expediente_img1';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||TRIM(cValor1)||'|'||cValor2||'|'||cValor3||'|'||'DOCUMENTO ELIMINADO';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('DG_EXPEDIENTE_IMG',cTabla,pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			END IF;
			
			SELECT cod_docto,secuencia,fecha_alta 
			INTO cValor1,cValor2,cValor3
			--FROM bdidigital@coppelimg20_tcp:dg_expediente_img 
			FROM bdidigital@coppelimghis_tcp:dg_expediente_img 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			
			LET cTabla = 'dg_expediente_img';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||TRIM(cValor1)||'|'||cValor2||'|'||cValor3||'|'||'DOCUMENTO ELIMINADO';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('DG_EXPEDIENTE_IMG',cTabla,pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			END IF;
			
			SELECT cod_docto,secuencia,fecha_alta 
			INTO cValor1,cValor2,cValor3
			--FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his 
			FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his 
			WHERE cliente = pCteTraspasa AND cod_docto = cCod_doctoDig AND secuencia = sSecuenciaDig AND empresa = '001';
			
			LET cTabla = 'dg_expediente_img_his';
			LET cDetalleMov = TRIM(pCteTraspasa)||'|'||TRIM(cValor1)||'|'||cValor2||'|'||cValor3||'|'||'DOCUMENTO ELIMINADO';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('DG_EXPEDIENTE_IMG',cTabla,pCteTitular,pCteTraspasa,cDetalleMov,CURRENT HOUR TO FRACTION(4),pUsEjecuta,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			END IF;
			
		END FOREACH;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar la eliminacion de los documentos que no se traspasaron.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 13/08/2020',
'DESCRIPCION: Se realiza ajuste a SP para Control de errores',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_validactasbloqueadas(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE iIsamErrorSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_validactasbloqueadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_vdactasbqdas(pNumCte) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_vdactasbqdas';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '01169'; --EL CLIENTE TIENE UNA CUENTA CON STATUS BLOQUEADA, SE CANCELARÃ LA FUSIÃN
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '01170'; --LOS PARÃMETROS SON INCORRECTOS
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de validar que el cliente a fusionar no tenga cuentas bloqueadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_validaejecucion(pUsuario CHAR(8),pIdFuncion CHAR(10),pAutoridad CHAR(8),pCveReporte CHAR(50))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_validaejecucion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_ejecucion_reporte_regulatorio(cEmpresa,pAutoridad,pCveReporte) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_valida_ejecucion_reporte_regulatorio';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '01149'; --SE ESTÃ GENERANDO EL REPORTE REGULATORIO R24B2423. NO SE PODRÃ LLEVAR A CABO LA FUSIÃN
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar si el proceso de generacion de reportes se esta ejecutado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_validanombre(pUsuario CHAR(8),pIdFuncion CHAR(10),
pPrimerNomBan CHAR(40), pSegNomBan CHAR(40), pApePatBan CHAR(40), pApeMatBan CHAR(40),
pPrimerNomBTS CHAR(40), pSegNomBTS CHAR(40), pApePatBTS CHAR(40), pApeMatBTS CHAR(40))
	RETURNING CHAR(5) AS codret,
		DECIMAL(6,2) AS porcentaje,
		CHAR(6) AS codret_sp;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE dPorcentaje DECIMAL(6,2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET dPorcentaje = 0.00;
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dPorcentaje,cCodRetSp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_validanombre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dPorcentaje,cCodRetSp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dPorcentaje,cCodRetSp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_validanombenefbts(pPrimerNomBan,pSegNomBan,pApePatBan,pApeMatBan,pPrimerNomBTS,pSegNomBTS,pApePatBTS,pApeMatBTS) 
		INTO cCodRetSp,dPorcentaje;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisac:sp_validanombenefbts';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '01157'; --PARA REALIZAR LA COMPARACIÃN SE DEBE INGRESAR POR LO MENOS EL PRIMER NOMBRE Y EL APELLIDO PATERNO
		END IF;
		
		RETURN cCodRet,dPorcentaje,cCodRetSp;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de comparar los nombres ingresados y obtener el porcentaje mÃ¡ximo de coincidencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_validaprocede(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_validaprocede.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_procede_fusion(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_valida_procede_fusion_clon';
		ELIF iCodRetSp = 10 THEN
			LET cCodRet = '01160'; --CANCELACIÃN POR VALIDACIÃN DEL CLUB DE PROTECCIÃN
		ELIF iCodRetSp = 11 THEN
			LET cCodRet = '01161'; --CANCELACIÃN POR VALIDACIÃN DE CUENTA-TELÃFONO
		ELIF iCodRetSp = 12 THEN
			LET cCodRet = '01162'; --CANCELACIÃN POR VALIDACIÃN DE CUENTA TRANSFER
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar si procede o no la fusiÃ³n manual de clientes.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 01/06/2020',
'DESCRIPCION: Se modifica SPL para cambiar llamado de procedimiento sp_valida_procede_fusion -> sp_valida_procede_fusion_clon.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_conssolicitudaleatoria_soc(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2), pEjecutivo CHAR(8), pEjecucion CHAR(1))
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		CHAR(100) as nom_cliente, 
		CHAR(80) as nom_analista, 
		DATETIME HOUR TO SECOND AS hora;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
		
	DEFINE cNum_solicitud CHAR(20); 
	DEFINE cNum_cliente CHAR(20); 
	DEFINE cNom_cliente CHAR(100);
	DEFINE cNom_analista CHAR(80);
	DEFINE dHora DATETIME HOUR TO SECOND;	
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';

	LET cNum_solicitud = ''; 
	LET cNum_cliente = '';
	LET cNom_cliente = '';
	LET cNom_analista = '';
	LET dHora = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_conssolicitudaleatoria_soc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pEjecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		END IF;
		
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_asigna_solicitud_soc(cEmpresa,pEjecutivo)
			INTO cCodRetSp, cNum_solicitud, cNum_cliente
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_asigna_solicitudaleatoria_mc';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
			END IF;
			
		END FOREACH;
		
		RETURN cCodRet, cNum_solicitud, cNum_cliente, cNom_cliente, cNom_analista, dHora;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/12/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: MONITOR DE OPERACIÃN EN LÃNEA',
'Descripcion: SPL encargado de consultar el la solicitud nueva que se va a asignar al analista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_detalledocsdigitalizadosdesb_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pTipoCte CHAR(1),pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDesc_docto CHAR(35);
	DEFINE cCuenta CHAR(20);
	DEFINE sSecuencia SMALLINT;
	DEFINE cFecha CHAR(10);
	DEFINE cDescripcion CHAR(50);
	DEFINE cCuentaValida CHAR(4);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cNumCte CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	DEFINE iIdRegistro INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cCod_docto = '';
	LET cDesc_docto = '';
	LET cCuenta = '';
	LET sSecuencia = 0;
	LET cFecha = '';
	LET cDescripcion = '';
	LET cCuentaValida = '';
	LET cProducto = '';
	LET cDescProducto = '';
	LET cNumCte = '';
	LET iNoRegistros = 0;
	
	LET iIdRegistro = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_detalledocsdigitalizadosdesb_totales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			SELECT id_registro INTO iIdRegistro 
			FROM bdicnweb:"informix".sw_fc_detdocsdigitalizadosdesb WHERE usuario_insert = pUsuario
			
			DELETE FROM bdicnweb:"informix".sw_fc_detdocsdigitalizadosdesb WHERE usuario_insert = pUsuario AND id_registro = iIdRegistro;
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_desbctasfus_obtenerdoctos_soc(pNumCte,0,500)
			INTO cCodRetSp,cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cProducto,cDescProducto
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_desbctasfus_obtenerdoctos_soc';
			ELIF iCodRetSp = 100 THEN
				LET cCodRet = '01190'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS PARA EL CLIENTE TITULAR
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_fc_detdocsdigitalizadosdesb(cod_docto,desc_docto,cuenta,secuencia,fecha,descripcion,cuenta_valida,producto,desc_producto,numcte,tipocte,usuario_insert)
			VALUES(cCod_docto,cDesc_docto,cCuenta,sSecuencia,cFecha,cDescripcion,cCuentaValida,cProducto,cDescProducto,pNumCte,pTipoCte,pUsuario);
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01190'; --NO EXISTEN DOCUMENTOS DIGITALIZADOS PARA EL CLIENTE TITULAR
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: DESBLOQUEO DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el número total de documentos digitalizados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_historicofusion_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pFechaDel DATE,pFechaAl DATE,pOpcion CHAR(1),pUsAnalista CHAR(8))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cDia CHAR(2);
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cDiaHasta CHAR(2);
	DEFINE cMesHasta CHAR(2);
	DEFINE cAnioHasta CHAR(4);
	
	DEFINE cNumCteTit 		  CHAR(20);
	DEFINE cNumCteTrasp 	  CHAR(20);
	DEFINE cApePaterTit 	  CHAR(26);
	DEFINE cApeMaterTit 	  CHAR(26);
	DEFINE cNom1Tit 		  CHAR(26);
	DEFINE cNom2Tit 		  CHAR(26);
	DEFINE cFechaNacTit 	  CHAR(10);
	DEFINE cApePaterTrasp	  CHAR(26);
	DEFINE cApeMaterTrasp	  CHAR(26);
	DEFINE cNom1Trasp 		  CHAR(26);
	DEFINE cNom2Trasp 		  CHAR(26);
	DEFINE cFechaNacTrasp 	  CHAR(10);
	DEFINE cNomCompTitular 	  CHAR(110);
	DEFINE cNomCompTrasp 	  CHAR(110);
	DEFINE cNumCtaTrasp 	  CHAR(20);
	DEFINE cProducto 		  CHAR(4);
	DEFINE cNumCte 			  CHAR(20);
	DEFINE cStatus 			  CHAR(2);
	DEFINE mSaldo 			  MONEY(16,2);
	DEFINE cDescripcion 	  CHAR(40);
	DEFINE cFechaAlta 		  CHAR(10);
	DEFINE iNumDireccionesFus INTEGER;
	DEFINE dHoraFusion  	  DATETIME HOUR TO FRACTION(3);
	DEFINE cStatusCuenta      CHAR(10);
	DEFINE cNombreAnalista    CHAR(45);
	DEFINE dFechaFusion       DATE ;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	LET cDia = '';
	LET cMes = '';
	LET cAnio = '';
	LET cDiaHasta = '';
	LET cMesHasta = '';
	LET cAnioHasta = '';
	
	LET cNumCteTit 		      = '';
	LET cNumCteTrasp 	      = '';
	LET cApePaterTit 	      = '';
	LET cApeMaterTit 	      = '';
	LET cNom1Tit 		      = '';
	LET cNom2Tit 		      = '';
	LET cFechaNacTit 	      = '';
	LET cApePaterTrasp 	      = '';
	LET cApeMaterTrasp 	      = '';
	LET cNom1Trasp 		      = '';
	LET cNom2Trasp 		      = '';
	LET cFechaNacTrasp 	      = '';
	LET cNomCompTitular       = '';
	LET cNomCompTrasp 	      = '';
	LET cNumCtaTrasp 	      = '';
	LET cProducto 		      = '';
	LET cNumCte 		      = '';
	LET cStatus 		      = '';
	LET mSaldo 			      = 0;
	LET cDescripcion 	      = '';
	LET cFechaAlta 		      = '';
	LET iNumDireccionesFus 	  = 0;
	LET dHoraFusion 		  = '';
	LET cStatusCuenta 	      = '';
	LET cNombreAnalista       = '';
	LET dFechaFusion 		  = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_historicofusion_totales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
		LET bEnTransaccion = 't';
		
		FOREACH WITH HOLD
			SELECT id_registro INTO iIdRegistro 
			FROM bdicnweb:"informix".sw_fc_rephistorico WHERE usuario_insert = pUsuario
			
			SET ISOLATION TO DIRTY READ;
			DELETE FROM bdicnweb:"informix".sw_fc_rephistorico WHERE usuario_insert = pUsuario AND id_registro = iIdRegistro;
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
		END FOREACH;
		
		COMMIT WORK;
		
		-- SE PARAMETRIZAN VALORES DE FECHA
		LET cDia = DAY(pFechaDel);
		LET cMes = MONTH(pFechaDel);
		LET cAnio = YEAR(pFechaDel);
		LET cDiaHasta =  DAY(pFechaAl);
		LET cMesHasta = MONTH(pFechaAl);
		LET cAnioHasta = YEAR(pFechaAl); 
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 6;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_historico_fusion_soc(cDia,cMes,cAnio,cDiaHasta,cMesHasta,cAnioHasta,pOpcion,pUsAnalista)
			INTO cCodRetSp,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_historico_fusion_soc';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '01200'; --NO SE ENCONTRARON DATOS, FAVOR DE VERIFICAR
				
				IF bEnTransaccion = 't' THEN
					BEGIN WORK;
					LET bEnTransaccion = 'f';
					LET iContador = 0;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			INSERT INTO "informix".sw_fc_rephistorico(numcte_tit,nombrecte_tit,fechanac_cte_tit,numcte_traspasado,nombrecte_traspasado,
			fechanac_cte_traspasado,numcta_traspasado,producto,numero_cliente,estatus,saldo,descripcion,fecha_alta,num_direcciones_fusionadas,
			fecha_fusion,hora_fusion,status_cuenta,nombre_analista,usuario_insert) 
			VALUES(cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTrasp,cFechaNacTrasp,cNumCtaTrasp,cProducto,cNumCte,cStatus,
			mSaldo,cDescripcion,cFechaAlta,iNumDireccionesFus,dFechaFusion,dHoraFusion,cStatusCuenta,cNombreAnalista,pUsuario);
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01200'; --NO SE ENCONTRARON DATOS, FAVOR DE VERIFICAR
		END IF;
		
		IF bEnTransaccion = 't' THEN
			BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: REPORTE HISTORICO FUSION DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros de clientes fusionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasoctascred(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasoctascred.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred_soc(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicred:sp_traspasocuentas_cred_soc';
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de cuentas cred.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasotelefonos(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasotelefonos.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_fustraspasotelefonos_soc(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_fustraspasotelefonos_soc';
		ELIF iCodRetSp <> 0 THEN
			LET cCodRet = '01189'; --FUSIÓN DE CLIENTES INCOMPLETA
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de telefonos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catestatus(pUsuario CHAR(8),pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS estatus_sol,
		CHAR(40) AS descripcion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEstatusSol CHAR(2);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEstatusSol = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cEstatusSol,cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catestatus.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cEstatusSol,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cEstatusSol,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT status_solicitud,UPPER(descripcion)
			INTO cEstatusSol,cDescripcion
			FROM bdisolic:"informix".ss_status_sol
			ORDER BY status_solicitud ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cEstatusSol,cDescripcion WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cEstatusSol,cDescripcion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estatus.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatsecausa(pUsuario CHAR(8), pIdFuncion CHAR(10), pSituacion CHAR(1), pCausa INTEGER, pFlagSoloSituaciones CHAR(1), pAlcance SMALLINT, 
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(1) AS situacion,
		INTEGER AS causa,
		CHAR(75) AS descripcion,
		CHAR(1) AS alcance,
		CHAR(1) AS despliegue,
		CHAR(1) AS vigente,
		CHAR(5) AS cvecc;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSituacion CHAR(1);
	DEFINE iCausa INTEGER;
    DEFINE cDescripcion CHAR(75);
    DEFINE cAlcance CHAR(1);
    DEFINE cDespliegue CHAR(1);
    DEFINE cVigente CHAR(1);
    DEFINE cCvecc CHAR(5);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cSituacion = '';
	LET iCausa = 0;
    LET cDescripcion = '';
    LET cAlcance = '';
    LET cDespliegue = '';
    LET cVigente = '';
    LET cCvecc = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatsecausa.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisitesp:"informix".sp_consultarsecausaconalcance_clon(cEmpresa,pSituacion,pCausa,pFlagSoloSituaciones,pAlcance,pRegistros,pRecuperacion)			
			INTO cCodRetSp,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_consultarsecausaconalcance_clon';
			ELIF cCodRetSp::INTEGER > 0 THEN 
				IF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00003';
				END IF;
				RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cSituacion,iCausa,UPPER(cDescripcion),cAlcance,cDespliegue,cVigente,cCvecc WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion,cAlcance,cDespliegue,cVigente,cCvecc;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar el detalle de los catalogos Situacion Actual/Causa.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultasesustituibles(pUsuario CHAR(8), pIdFuncion CHAR(10), pSituacion CHAR(1), pCausa SMALLINT, pAlcance SMALLINT, 
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(5) AS situacion,
		CHAR(5) AS causa,
		CHAR(75) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSituacion CHAR(5);
	DEFINE iCausa CHAR(5);
    DEFINE cDescripcion CHAR(75);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cSituacion = '';
	LET iCausa = 0;
    LET cDescripcion = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultasesustituibles.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisitesp:"informix".sp_obtienesesustituibles_clon(cEmpresa,pSituacion,pCausa,pAlcance,pRegistros,pRecuperacion)			
			INTO cCodRetSp,cSituacion,iCausa,cDescripcion
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_obtienesesustituibles_clon';
			ELIF cCodRetSp::INTEGER > 0 THEN 
				IF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '01206'; --NO ES UNA SITUACIÓN Y CAUSA VALIDOS
				END IF;
				RETURN cCodRet,cSituacion,iCausa,cDescripcion;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cSituacion,iCausa,UPPER(cDescripcion) WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSituacion,iCausa,cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar las SE y Causas que pueden sustituir a la SE que llego por parametro.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_verificastatus_detalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pOperacion CHAR(1))
	RETURNING CHAR(5) AS codRet,
		CHAR(1) AS status,
		CHAR(6) AS codError,
		CHAR(1) AS operacion,
		INTEGER AS numRegistro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(1);
	DEFINE cErrorSp CHAR(6);
	DEFINE cOperacion CHAR(1);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';
	LET cErrorSp = '';
	LET iNumRegistros = 0;
	LET cOperacion = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorSp, cOperacion, iNumRegistros;
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cre_verificastatus_detalle.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorSp, cOperacion, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, error_spl, operacion, num_registros
		INTO cStatus, cErrorSp, cOperacion, iNumRegistros
		FROM "informix".sw_verifica_detallemarcaje
		WHERE usuario_insert = pUsuario AND operacion = pOperacion;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet, 'I', cErrorSp, cOperacion, iNumRegistros;
		ELSE
			RETURN cCodRet, cStatus, cErrorSp, cOperacion, iNumRegistros;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2020',
'MODULO: Credito',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SP encargado de verificar el estatus de la ejecucion de los procedimientos de consulta y elimina informacion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_desccodret(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodRet CHAR(4))
    RETURNING CHAR(5) AS codret,
		CHAR(50) AS mensaje_error;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(50);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescCodRetSp;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_desccodret.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodRet = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescCodRetSp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescCodRetSp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06',pCodRet)			
		INTO cCodRetSp, cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_desc_ret';
		END IF;			
		
		RETURN cCodRet, UPPER(cDescCodRetSp);
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 04/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE CRÉDITOS QUEBRANTADOS',
'DESCRIPCION: SPL encargado de consultar la descripcion del codigo de retorno.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallecoincidenciasind(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20), 
pApePat CHAR(26), pApeMat CHAR(26), pNombre1 CHAR(26), pNombre2 CHAR(26), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS numcte,
		CHAR(104) AS nombre,
		CHAR(13) AS rfc,
		CHAR(20) AS num_credito,
		CHAR(20) AS num_tarjeta;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombre CHAR(104);
	DEFINE cRFC CHAR(13);
	DEFINE cNumCred CHAR(20);
	DEFINE cNumTarjeta CHAR(20);	
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cNombre = '';
	LET cRFC = '';
	LET cNumCred = '';
	LET cNumTarjeta = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecoincidenciasind.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			numcte,nombre,rfc,num_credito,num_tarjeta
			INTO cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta
			FROM "informix".sw_detcoincidenciasind
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar el detalle del cliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallecoincidenciasind_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20), 
pApePat CHAR(26), pApeMat CHAR(26), pNombre1 CHAR(26), pNombre2 CHAR(26), pFecha DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombre CHAR(104);
	DEFINE cRFC CHAR(13);
	DEFINE cNumCred CHAR(20);
	DEFINE cNumTarjeta CHAR(20);	
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cNombre = '';
	LET cRFC = '';
	LET cNumCred = '';
	LET cNumTarjeta = '';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
				
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet
			WHERE usuario_insert = pUsuario AND operacion = '1';
				
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecoincidenciasind_totales.out';
		-- TRACE ON;
		
		-- SE ELIMINA INFORMACION EN TABLA POR USUARIO Y OPERACION
		DELETE FROM "informix".sw_verifica_detallemarcaje WHERE usuario_insert = pUsuario AND operacion = '1';
		
		-- SE REALIZA INSERCIÓN 
		INSERT INTO sw_verifica_detallemarcaje (codret, status, error_spl, operacion, num_registros, usuario_insert)
		VALUES('', 'I', NULL, '1', NULL, pUsuario);
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet 
			WHERE usuario_insert = pUsuario AND operacion = '1';
			
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".sw_detcoincidenciasind WHERE usuario_insert = pUsuario;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet 
			WHERE usuario_insert = pUsuario AND operacion = '1';
			
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisitesp:"informix".sp_consultacoincidenciasindividual(cEmpresa,pNumCte,pNumCredito,pNumTarjeta,pApePat,pApeMat,pNombre1,pNombre2,pFecha)			
			INTO cCodRetSp,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta
			
			IF cCodRetSp::INTEGER < 0 THEN 
				
				UPDATE "informix".sw_verifica_detallemarcaje
				SET status = 'E', error_spl = cCodRet 
				WHERE usuario_insert = pUsuario AND operacion = '1';
			
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_consultacoincidenciasindividual';
			ELIF cCodRetSp::INTEGER > 0 THEN 
				IF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00003';
					
					UPDATE "informix".sw_verifica_detallemarcaje
					SET status = 'E', error_spl = cCodRet 
					WHERE usuario_insert = pUsuario AND operacion = '1';
					
				END IF;
			
				RETURN cCodRet, iNumRegistros;
			END IF;			
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detcoincidenciasind(id_registro,numcte,nombre,rfc,num_credito,num_tarjeta,usuario_insert)
			VALUES(iNumRegistros,cNumCte,cNombre,cRFC,cNumCred,cNumTarjeta,pUsuario);	
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet 
			WHERE usuario_insert = pUsuario AND operacion = '1';
					
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		UPDATE "informix".sw_verifica_detallemarcaje
		SET status = 'T', codret = cCodRet, error_spl = '', num_registros = iNumRegistros
		WHERE usuario_insert = pUsuario AND operacion = '1';
		
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar el numero total de registros del detalle del cliente.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2020',
'DESCRIPCION: Se realiza ajute a SP para agregar tabla de verificacion';

CREATE PROCEDURE "informix".sp_detallecredbloqfall(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cliente,
		CHAR(26) AS apell_paterno,
		CHAR(26) AS apell_materno,
		CHAR(26) AS nombre,
		CHAR(26) AS nombre2,
		CHAR(20) AS num_credito,
		DATE AS fecha_bloqueo,
		CHAR(2) AS status,
		CHAR(60) AS descripcion,
		DECIMAL(18,2) AS capital_vig,
		DECIMAL(18,2) AS capital_ven,
		DECIMAL(18,2) AS vencido_noexi,
		DECIMAL(18,2) AS transitorio,
		DECIMAL(18,2) AS total_quebrantado;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumcte CHAR(20);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNum_credito CHAR(20);
	DEFINE dFecha_bloqueo DATE;
	DEFINE cStatus CHAR(2);
	DEFINE cDescripcion CHAR(60);
	DEFINE dCapital_Vigente DECIMAL(18,2);
	DEFINE dCapital_Vencido DECIMAL(18,2);
	DEFINE dVencido_No_Exigible DECIMAL(18,2);
	DEFINE dTransitorio DECIMAL(18,2);
	DEFINE dTotal_Quebrantado DECIMAL(18,2);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cNum_credito = ''; 
	LET dFecha_bloqueo = '';
	LET cStatus = '';
	LET cDescripcion = '';
	LET dCapital_Vigente = 0.00; 
	LET dCapital_Vencido = 0.00;
	LET dVencido_No_Exigible = 0.00;
	LET dTransitorio = 0.00;
	LET dTotal_Quebrantado = 0.00;
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecredbloqfall.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			num_cliente,apell_paterno,apell_materno,nombre,nombre2,num_credito,fecha_bloqueo,
			status,descripcion,capital_vig,capital_ven,vencido_noexi,transitorio,total_quebrantado
			INTO cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado
			FROM "informix".sw_detcredbloqfall
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado;
		END IF;	
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 04/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE CRÉDITOS QUEBRANTADOS',
'DESCRIPCION: SPL encargado de consultar el detalle de creditos quebrantados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallecredbloqfall_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pFechaInicio CHAR(10), pFechaFin CHAR(10))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNumcte CHAR(20);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNum_credito CHAR(20);
	DEFINE dFecha_bloqueo DATE;
	DEFINE cStatus CHAR(2);
	DEFINE cDescripcion CHAR(60);
	DEFINE dCapital_Vigente DECIMAL(18,2);
	DEFINE dCapital_Vencido DECIMAL(18,2);
	DEFINE dVencido_No_Exigible DECIMAL(18,2);
	DEFINE dTransitorio DECIMAL(18,2);
	DEFINE dTotal_Quebrantado DECIMAL(18,2);
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cNum_credito = ''; 
	LET dFecha_bloqueo = '';
	LET cStatus = '';
	LET cDescripcion = '';
	LET dCapital_Vigente = 0.00; 
	LET dCapital_Vencido = 0.00;
	LET dVencido_No_Exigible = 0.00;
	LET dTransitorio = 0.00;
	LET dTotal_Quebrantado = 0.00;
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrepqueb
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecredbloqfall_totales.out';
		-- TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatusrepqueb WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatusrepqueb(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		DELETE FROM bdicnweb:"informix".sw_detcredbloqfall WHERE usuario_insert = pUsuario;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatusrepqueb
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_verificastatusrepqueb
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_consultacredbloqfallecimiento(pNumCte,pNumCredito,pFechaInicio,pFechaFin)			
			INTO cCodRetSp, cDescCodRetSp, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_consultacredbloqfallecimiento';
			ELIF cCodRetSp::INTEGER > 0 THEN 
				UPDATE "informix".sw_verificastatusrepqueb
				SET status = 'E', error_proceso = 'S', error_sp = cCodRetSp WHERE usuario_insert = pUsuario;
				IF cCodRetSp::INTEGER = 434 THEN 
					LET cCodRet = '00017';
				ELIF cCodRetSp::INTEGER = 433 THEN 
					LET cCodRet = '00017';
				ELIF cCodRetSp::INTEGER = 432 THEN 
					LET cCodRet = '00017';
				END IF;
				RETURN cCodRet, iNumRegistros;
			END IF;			
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detcredbloqfall(id_registro,num_cliente,apell_paterno,apell_materno,nombre,nombre2,num_credito,fecha_bloqueo,
			status,descripcion,capital_vig,capital_ven,vencido_noexi,transitorio,total_quebrantado,usuario_insert)
			VALUES(iNumRegistros, cNumcte, cApell_paterno, cApell_materno, cNombre1, cNombre2, cNum_credito, dFecha_bloqueo, 
			cStatus, cDescripcion, dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio, dTotal_Quebrantado, pUsuario);	
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatusrepqueb
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		UPDATE "informix".sw_verificastatusrepqueb
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 04/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE CRÉDITOS QUEBRANTADOS',
'DESCRIPCION: SPL encargado de consultar el numero total de registros de creditos quebrantados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallecteseind(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pIdBusqueda INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_credito,
		CHAR(20) AS num_tarjeta,
		CHAR(1) AS sit_esp,
		SMALLINT AS causa,
		CHAR(75) AS descripcion,
		DATETIME YEAR TO SECOND AS fecha_modificacion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCred CHAR(20);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cSitEsp CHAR(1);
	DEFINE cCausa SMALLINT;
	DEFINE cDescripcion CHAR(75);
	DEFINE dFechaMod DATETIME YEAR TO SECOND;	
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCred = '';
	LET cNumTarjeta = '';
	LET cSitEsp = '';
	LET cCausa = '';
	LET cDescripcion = '';
	LET dFechaMod = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecteseind.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			num_credito,num_tarjeta,sit_esp,causa,descripcion,fecha_modificacion
			INTO cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod
			FROM "informix".sw_detcteseind
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,UPPER(cDescripcion),dFechaMod WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar el detalle de informacion de creditos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallecteseind_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pIdBusqueda INTEGER)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCred CHAR(20);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cSitEsp CHAR(1);
	DEFINE cCausa SMALLINT;
	DEFINE cDescripcion CHAR(75);
	DEFINE dFechaMod DATETIME YEAR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCred = '';
	LET cNumTarjeta = '';
	LET cSitEsp = '';
	LET cCausa = '';
	LET cDescripcion = '';
	LET dFechaMod = '';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallecteseind_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".sw_detcteseind WHERE usuario_insert = pUsuario;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisitesp:"informix".sp_consultaclienteseindividual(cEmpresa,pNumCte,pIdBusqueda)			
			INTO cCodRetSp,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_consultaclienteseindividual';
			ELIF cCodRetSp::INTEGER > 0 THEN 
				IF cCodRetSp::INTEGER = 999 THEN
					LET cCodRet = '00003';
				END IF;
				RETURN cCodRet, iNumRegistros;
			END IF;			
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detcteseind(id_registro,num_credito,num_tarjeta,sit_esp,causa,descripcion,fecha_modificacion,usuario_insert)
			VALUES(iNumRegistros,cNumCred,cNumTarjeta,cSitEsp,cCausa,cDescripcion,dFechaMod,pUsuario);	
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de consultar el numero total de registros del detalle de informacion de creditos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallestatussol(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
pSucursal CHAR(4), pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(4) AS sucursal,       
		CHAR(40) AS nom_sucursal,     
		CHAR(104) AS nom_cliente,    
		CHAR(2) AS status_solicitud,      
		MONEY(14,2) AS monto_solicitud,  
		MONEY(14,2) AS monto_otorgado,  
		DATE AS fecha_alta,         
		DATE AS fecha_cambio_status,         
		DECIMAL(10,2) AS eficiencia_pago,
		SMALLINT AS meses_historial, 
		SMALLINT AS scoring_1,     
		SMALLINT AS scoring_2,     
		SMALLINT AS total_scoring,     
		CHAR(10) AS causa_rechazo;	
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cSucursal CHAR(4); 
	DEFINE cNom_sucursal CHAR(40);  
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2);  
	DEFINE dFecha_alta DATE;
	DEFINE dFecha_cambio_status DATE;
	DEFINE dEficiencia_pago DECIMAL(10,2);
	DEFINE iMeses_historial SMALLINT;
	DEFINE iScoring_1 SMALLINT;
	DEFINE iScoring_2 SMALLINT;
	DEFINE iTotal_scoring SMALLINT;
	DEFINE cCausa_rechazo CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNum_solicitud = '';
	LET cSucursal = ''; 
	LET cNom_sucursal = ''; 
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_alta = '';
	LET dFecha_cambio_status = '';
	LET dEficiencia_pago = 0.00; 
	LET iMeses_historial = 0;
	LET iScoring_1 = 0;
	LET iScoring_2 = 0;
	LET iTotal_scoring = 0;
	LET cCausa_rechazo = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END EXCEPTION;
  
	SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallestatussol.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pStatus  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;

		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			num_solicitud,sucursal,nom_sucursal,nom_cliente,status_solicitud,
			monto_solicitud,monto_otorgado,fecha_alta,fecha_cambio_status,
			eficiencia_pago,meses_historial,scoring_1,scoring_2,total_scoring,causa_rechazo
			INTO cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo
			FROM "informix".sw_detstatussol
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNum_solicitud, cSucursal, UPPER(cNom_sucursal), UPPER(cNom_cliente), UPPER(cStatus_solicitud), 
			NVL(mMonto_solicitud,0), NVL(mMonto_otorgado,0), dFecha_alta, dFecha_cambio_status,  
			NVL(dEficiencia_pago,0), NVL(iMeses_historial,0), NVL(iScoring_1,0), NVL(iScoring_2,0), NVL(iTotal_scoring,0), UPPER(cCausa_rechazo) WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;	
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el detalle del status de la solicitud.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2020',
'DESCRIPCION: Se realiza ajuste a SP para quitar el paramtro Sucursal como requerido';

CREATE PROCEDURE "informix".sp_detallestatussolaud(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
pSucursal CHAR(4), pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		DATE AS fecha_alta, 
		CHAR(104) AS nom_cliente,    
		CHAR(2) AS status_solicitud,      
		MONEY(14,2) AS monto_solicitud,  
		MONEY(14,2) AS monto_otorgado,
		DATE AS fecha_cambio_status,
		CHAR(45) AS nom_promotor,
		CHAR(13) AS tel_particular,
		CHAR(13) AS tel_celular,
		CHAR(13) AS tel_oficina,
		CHAR(4) AS sucursal;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFecha_alta DATE;
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2); 
	DEFINE dFecha_cambio_status DATE;
	DEFINE cNom_promotor CHAR(45);
	DEFINE cTelefono_particular CHAR(13);
	DEFINE cTelefono_celular CHAR(13);
	DEFINE cTelefono_oficina CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cNum_solicitud = '';
	LET cNum_cliente = '';
	LET dFecha_alta = '';
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_cambio_status = '';
	LET cNom_promotor = '';
	LET cTelefono_particular = '';
	LET cTelefono_celular = '';
	LET cTelefono_oficina = '';
	LET cSucursal = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END EXCEPTION;
  
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallestatussolaud.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pStatus  = '' OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;

		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			num_solicitud,num_cliente,fecha_alta,nom_cliente,status_solicitud,monto_solicitud,monto_otorgado,
			fecha_cambio_status,nom_promotor,tel_particular,tel_celular,tel_oficina,sucursal
			INTO cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal
			FROM "informix".sw_detstatussolaud
			WHERE usuario_insert = pUsuario ORDER BY id_registro ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, UPPER(cNom_cliente), UPPER(cStatus_solicitud), NVL(mMonto_solicitud,0), NVL(mMonto_otorgado,0),
			dFecha_cambio_status, UPPER(cNom_promotor), cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el detalle de los datos del reporte de solicitudes para el area de auditoria.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 24/09/2020',
'DESCRIPCION: Se quita el parametro sucursal como requerido';

CREATE PROCEDURE "informix".sp_detallestatussolaud_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
pSucursal CHAR(4), pStatus CHAR(2))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFecha_alta DATE;
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2); 
	DEFINE dFecha_cambio_status DATE;
	DEFINE cNom_promotor CHAR(45);
	DEFINE cTelefono_particular CHAR(13);
	DEFINE cTelefono_celular CHAR(13);
	DEFINE cTelefono_oficina CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cNum_solicitud = '';
	LET cNum_cliente = '';
	LET dFecha_alta = '';
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_cambio_status = '';
	LET cNom_promotor = '';
	LET cTelefono_particular = '';
	LET cTelefono_celular = '';
	LET cTelefono_oficina = '';
	LET cSucursal = '';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallestatussolaud_totales.out';
		-- TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatusrep WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatusrep(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		DELETE FROM bdicnweb:"informix".sw_detstatussolaud WHERE usuario_insert = pUsuario;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pStatus  = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_status_sol_aud(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus)			
			INTO cCodRetSp, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_status_sol_aud';
			END IF;
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detstatussolaud(id_registro,num_solicitud,num_cliente,fecha_alta,nom_cliente,status_solicitud,monto_solicitud,monto_otorgado,
			fecha_cambio_status,nom_promotor,tel_particular,tel_celular,tel_oficina,sucursal,usuario_insert)
			VALUES(iNumRegistros, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal, pUsuario);	
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		UPDATE "informix".sw_verificastatusrep
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el numero total de registros de solicitudes para el area de auditoria.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 24/09/2020',
'DESCRIPCION: Se quita el parametro sucursal como requerido';

CREATE PROCEDURE "informix".sp_detallestatussolaudexcel_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
pSucursal CHAR(4), pStatus CHAR(2))
    RETURNING CHAR(5) AS codret,          
		INTEGER AS num_registros;		
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFecha_alta DATE;
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2); 
	DEFINE dFecha_cambio_status DATE;
	DEFINE cNom_promotor_realizo CHAR(45);
	DEFINE cNom_promotor_autorizo CHAR(45);
	DEFINE cNom_promotor_entrego CHAR(45);
	DEFINE cNom_promotor_asigno CHAR(45);
	DEFINE cTelefono_particular CHAR(13);
	DEFINE cTelefono_celular CHAR(13);
	DEFINE cTelefono_oficina CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE cNom_referencia1 CHAR(104); 
	DEFINE cTel_ref1_particular CHAR(13); 
	DEFINE cTel_ref1_celular CHAR(13); 
	DEFINE cTel_ref1_oficina CHAR(13);
	DEFINE cNom_referencia2 CHAR(104); 
	DEFINE cTel_ref2_particular CHAR(13); 
	DEFINE cTel_ref2_celular CHAR(13); 
	DEFINE cTel_ref2_oficina CHAR(13);
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cNum_solicitud = '';
	LET cNum_cliente = '';
	LET dFecha_alta = '';
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_cambio_status = '';
	LET cNom_promotor_realizo = '';
	LET cNom_promotor_autorizo = '';
	LET cNom_promotor_entrego = '';
	LET cNom_promotor_asigno = '';
	LET cTelefono_particular = '';
	LET cTelefono_celular = '';
	LET cTelefono_oficina = '';
	LET cSucursal = '';
	LET cNom_referencia1 = ''; 
	LET cTel_ref1_particular = ''; 
	LET cTel_ref1_celular = ''; 
	LET cTel_ref1_oficina = '';
	LET cNom_referencia2 = ''; 
	LET cTel_ref2_particular = ''; 
	LET cTel_ref2_celular = ''; 
	LET cTel_ref2_oficina = '';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallestatussolaudexcel_totales.out';
		-- TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatusrep WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatusrep(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		DELETE FROM bdicnweb:"informix".sw_detstatussolaudexcel WHERE usuario_insert = pUsuario;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pSucursal  = '' OR pStatus  = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_status_sol_audexcel(cEmpresa,pSucursal,pFechaInicio,pFechaFin,pStatus)			
			INTO cCodRetSp, cDescCodRetSp, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_cambio_status, 
			cNom_promotor_realizo, cNom_promotor_autorizo, cNom_promotor_entrego, cNom_promotor_asigno,
			cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal,
			cNom_referencia1, cTel_ref1_particular, cTel_ref1_celular, cTel_ref1_oficina,
			cNom_referencia2, cTel_ref2_particular, cTel_ref2_celular, cTel_ref2_oficina			
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_status_sol_audexcel';
			ELIF cCodRetSp::INTEGER > 0 THEN
				IF cCodRetSp::INTEGER = 1 OR cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00996'; --EL ESTATUS NO ES VALIDO PARA LA EXPORTACIÃN A EXCEL
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00997'; --EL RANGO DE FECHAS NO ES VALIDO PARA LA EXPORTACIÃN A EXCEL
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00017';
				END IF;
				
				UPDATE "informix".sw_verificastatusrep
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detstatussolaudexcel(id_registro,num_solicitud,num_cliente,fecha_alta,nom_cliente,status_solicitud,monto_solicitud,monto_otorgado,
			fecha_cambio_status,nom_promotor_realizo,nom_promotor_autorizo,nom_promotor_entrego,nom_promotor_asigno,tel_particular,tel_celular,tel_oficina,sucursal,
			nom_ref1,tel_particular_ref1,tel_celular_ref1,tel_oficina_ref1,nom_ref2,tel_particular_ref2,tel_celular_ref2,tel_oficina_ref2,usuario_insert)
			VALUES(iNumRegistros, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado, 
			dFecha_cambio_status, cNom_promotor_realizo, cNom_promotor_autorizo, cNom_promotor_entrego, cNom_promotor_asigno, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal,
			cNom_referencia1, cTel_ref1_particular, cTel_ref1_celular, cTel_ref1_oficina, cNom_referencia2, cTel_ref2_particular, cTel_ref2_celular, cTel_ref2_oficina, pUsuario);
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		UPDATE "informix".sw_verificastatusrep
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el numero total de registros de los datos del reporte en excel de solicitudes para el area de auditoria.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_eliminase(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumCte CHAR(20), pNumCredito CHAR(20), pSE CHAR(1), pCausa SMALLINT, pTipoMovimiento INTEGER, pProcedencia INTEGER)
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreUsuario CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreUsuario = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet
			WHERE usuario_insert = pUsuario AND operacion = '2';
			
			RETURN cCodRet;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SET DEBUG FILE TO '/ifxsif01/tmp/mfinis/sp_eliminase.out';
		 --TRACE ON;
		
		-- SE ELIMINA INFORMACION EN TABLA POR USUARIO Y OPERACION
		DELETE FROM "informix".sw_verifica_detallemarcaje WHERE usuario_insert = pUsuario AND operacion = '2';
		
		-- SE REALIZA INSERCIÓN 
		INSERT INTO sw_verifica_detallemarcaje (codret, status, error_spl, operacion, num_registros, usuario_insert)
		VALUES('', 'I', NULL, '2', NULL, pUsuario);
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet 
			WHERE usuario_insert = pUsuario AND operacion = '2';
			
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRet 
			WHERE usuario_insert = pUsuario AND operacion = '2';
			
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(nombre) INTO cNombreUsuario
		FROM bdinteg:"informix".si_ejecut WHERE empresa = cEmpresa AND ejecutivo = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisitesp:"informix".sp_eliminarse(pNumCte,cEmpresa,pNumCredito,pSE,pCausa,cNombreUsuario,pUsuario,pTipoMovimiento,pProcedencia)			
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			
			UPDATE "informix".sw_verifica_detallemarcaje
			SET status = 'E', error_spl = cCodRetSp 
			WHERE usuario_insert = pUsuario AND operacion = '2';
			
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_eliminarse';
		ELIF cCodRetSp::INTEGER > 0 THEN 
			IF cCodRetSp::INTEGER = 999 THEN
				LET cCodRet = '00003';
				
				UPDATE "informix".sw_verifica_detallemarcaje
				SET status = 'E', error_spl = cCodRet 
				WHERE usuario_insert = pUsuario AND operacion = '2';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '01207'; --NO EXISTEN REGISTROS PARA ESTE NO. DE CLIENTE
				
				UPDATE "informix".sw_verifica_detallemarcaje
				SET status = 'E', error_spl = cCodRet 
				WHERE usuario_insert = pUsuario AND operacion = '2';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER IN (2,3) THEN
				LET cCodRet = '01208'; --LA SITUACIÓN Y LA CAUSA NO PUEDE SER ELIMINADA
				
				UPDATE "informix".sw_verifica_detallemarcaje
				SET status = 'E', error_spl = cCodRet 
				WHERE usuario_insert = pUsuario AND operacion = '2';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 5 THEN
				LET cCodRet = '01209'; --USUARIO SIN DERECHO PARA ELIMINAR
				
				UPDATE "informix".sw_verifica_detallemarcaje
				SET status = 'E', error_spl = cCodRet 
				WHERE usuario_insert = pUsuario AND operacion = '2';
				RETURN cCodRet;
			END IF;
		END IF;
		
		UPDATE "informix".sw_verifica_detallemarcaje
		SET status = 'T', codret = cCodRet, error_spl = '', num_registros = 0
		WHERE usuario_insert = pUsuario AND operacion = '2';
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de eliminar situaciones especiales y causas para un cliente y/o credito.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2020',
'FESCRIPCION: Se realiza ajuste a SP para agregar tabla de verificacion.';

CREATE PROCEDURE "informix".sp_genrepcredbloqfall(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
	CHAR(45) AS reporte_xls,
	CHAR(45) AS reporte_txt;		
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(45);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_genrepcredbloqfall.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		LET cNombreRepXls = 'RepQuebFallecimiento'||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
		LET cNombreRepTxt = 'RepQuebFallecimiento'||TO_CHAR(CURRENT, '%d%m%Y')||'.txt';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		LET cRutaGralTxt = TRIM(pRutaDescarga)||TRIM(cNombreRepTxt);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'FECHA DE BLOQUEO','NO. DE CLIENTE','NO. DE CREDITO','NOMBRE DEL CLIENTE','ESTATUS','CAPITAL VIGENTE','CAPITAL VENCIDO','CAPITAL VENCIDO NO EXIGIBLE','TRANSITORIO','TOTAL QUEBRANTADO'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT TO_CHAR(fecha_bloqueo, '%d/%m/%Y'),''''||num_cliente,''''||num_credito,TRIM(TRIM(nombre)||' '||TRIM(nombre2))||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno),";
		LET cCmd1 =""||TRIM(cCmd1)||"status,capital_vig::CHAR(20),capital_ven::CHAR(20),vencido_noexi::CHAR(20),transitorio::CHAR(20),total_quebrantado::CHAR(20)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detcredbloqfall";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
		
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- GENERACION DE ARCHIVO TXT
		LET cSql = '';
		--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralTxt)||".tmp > "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralTxt)||'; /usr/bin/mv '||TRIM(cRutaGralTxt)||'.tmp '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 04/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE CRÃDITOS QUEBRANTADOS',
'DESCRIPCION: SPL encargado de generar los reportes de creditos quebrantados en formato xls/txt.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 24/09/2020',
'DESCRIPCION: Se realiza ajuste a SP para agregar los siguientes campos al reporte CAPITAL VENCIDO, TRANSITORIO, TOTAL QUEBRANTADOS';

CREATE PROCEDURE "informix".sp_genrepstatussol(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
	CHAR(45) AS reporte_xls,
	CHAR(45) AS reporte_txt;		
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(45);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_genrepstatussol.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		LET cNombreRepXls = 'REPORTE_ESTATUS_SOLICITUDES_SOL_'||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
		LET cNombreRepTxt = 'REPORTE_ESTATUS_SOLICITUDES_SOL_'||TO_CHAR(CURRENT, '%d%m%Y')||'.txt';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		LET cRutaGralTxt = TRIM(pRutaDescarga)||TRIM(cNombreRepTxt);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'NO. SOLICITUD','SUC.','NOMBRE DEL CLIENTE','ST','MONTO SOL.','MONTO AUT.','FECHA SOL.','FECHA CAM ESTA','EFICIENCIA COPPEL','ANTIG. COPPEL','SC1','SC2','TOTAL SCORING'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ''''||num_solicitud,sucursal,nom_cliente,status_solicitud,monto_solicitud::CHAR(16),monto_otorgado::CHAR(16),";
		LET cCmd1 =""||TRIM(cCmd1)||"TO_CHAR(fecha_alta, '%d/%m/%Y'),TO_CHAR(fecha_cambio_status, '%d/%m/%Y'),eficiencia_pago::CHAR(12),meses_historial::CHAR(6),scoring_1::CHAR(6),scoring_2::CHAR(6),total_scoring::CHAR(6)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detstatussol";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
		
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- GENERACION DE ARCHIVO TXT
		LET cSql = '';
		--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralTxt)||".tmp > "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralTxt)||'; /usr/bin/mv '||TRIM(cRutaGralTxt)||'.tmp '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de generar los reportes estatus solicitudes (solicitud) en formato xls/txt.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrepstatussolaud(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
	CHAR(45) AS reporte_xls,
	CHAR(45) AS reporte_txt;		
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(45);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_genrepstatussolaud.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		LET cNombreRepXls = 'REPORTE_ESTATUS_SOLICITUDES_AUD_'||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
		LET cNombreRepTxt = 'REPORTE_ESTATUS_SOLICITUDES_AUD_'||TO_CHAR(CURRENT, '%d%m%Y')||'.txt';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		LET cRutaGralTxt = TRIM(pRutaDescarga)||TRIM(cNombreRepTxt);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'NO. SOLICITUD','CLIENTE','FECHA SOL.','SUC.','NOMBRE DEL CLIENTE','ST','MONTO SOL.','MONTO AUT.','FECHA CAM ESTA','USUARIO QUE APERTURO','TELEFONO PARTICULAR','TELEFONO CELULAR','TELEFONO OFICINA'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ''''||num_solicitud,''''||num_cliente,TO_CHAR(fecha_alta, '%d/%m/%Y'),sucursal,nom_cliente,status_solicitud,monto_solicitud::CHAR(16),monto_otorgado::CHAR(16),";
		LET cCmd1 =""||TRIM(cCmd1)||"TO_CHAR(fecha_cambio_status, '%d/%m/%Y'),nom_promotor,tel_particular,tel_celular,tel_oficina";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detstatussolaud";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
		
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- GENERACION DE ARCHIVO TXT
		LET cSql = '';
		--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralTxt)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralTxt)||".tmp > "||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralTxt)||" > "||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralTxt)||'; /usr/bin/mv '||TRIM(cRutaGralTxt)||'.tmp '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralTxt);
		SYSTEM TRIM(cSql);
		
		RETURN cCodRet,cNombreRepXls,cNombreRepTxt;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de generar los reportes estatus solicitudes (auditoria) en formato xls/txt.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrepstatussolaudexcel(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
	CHAR(45) AS reporte_xls;		
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFecha_alta DATE;
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2); 
	DEFINE dFecha_cambio_status DATE;
	DEFINE cNom_promotor_realizo CHAR(45);
	DEFINE cNom_promotor_autorizo CHAR(45);
	DEFINE cNom_promotor_entrego CHAR(45);
	DEFINE cNom_promotor_asigno CHAR(45);
	DEFINE cTelefono_particular CHAR(13);
	DEFINE cTelefono_celular CHAR(13);
	DEFINE cTelefono_oficina CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE cNom_referencia1 CHAR(104); 
	DEFINE cTel_ref1_particular CHAR(13); 
	DEFINE cTel_ref1_celular CHAR(13); 
	DEFINE cTel_ref1_oficina CHAR(13);
	DEFINE cNom_referencia2 CHAR(104); 
	DEFINE cTel_ref2_particular CHAR(13); 
	DEFINE cTel_ref2_celular CHAR(13); 
	DEFINE cTel_ref2_oficina CHAR(13);
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(45);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cNum_solicitud = '';
	LET cNum_cliente = '';
	LET dFecha_alta = '';
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_cambio_status = '';
	LET cNom_promotor_realizo = '';
	LET cNom_promotor_autorizo = '';
	LET cNom_promotor_entrego = '';
	LET cNom_promotor_asigno = '';
	LET cTelefono_particular = '';
	LET cTelefono_celular = '';
	LET cTelefono_oficina = '';
	LET cSucursal = '';
	LET cNom_referencia1 = ''; 
	LET cTel_ref1_particular = ''; 
	LET cTel_ref1_celular = ''; 
	LET cTel_ref1_oficina = '';
	LET cNom_referencia2 = ''; 
	LET cTel_ref2_particular = ''; 
	LET cTel_ref2_celular = ''; 
	LET cTel_ref2_oficina = '';
	LET iRecuperacion = 0;
	
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreRepXls;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_genrepstatussolaudexcel.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreRepXls;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreRepXls;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		LET cNombreRepXls = 'REPORTE_ESTATUS_SOLICITUDES_'||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ' ',' ',' ',' ',' ','REPORTE DE ESTATUS DE SOLICITUDES',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','PRIMERA REFERENCIA',' ',' ',' ','SEGUNDA REFERENCIA',' ',' ',' '";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'NO. SOLICITUD','CLIENTE','FECHA SOL.','SUC.','NOMBRE DEL CLIENTE','ST','MONTO SOL.','MONTO AUT.','FECHA CAM ESTA',";
		LET cCmd1 =""||TRIM(cCmd1)||"'RESPONSABLE DE CAPTURA','RESPONSABLE QUE AUTORIZO','RESPONSABLE DE ENTREGA','RESPONSABLE DE ACTIVACION','TELEFONO PARTICULAR','TELEFONO CELULAR','TELEFONO OFICINA',";
		LET cCmd1 =""||TRIM(cCmd1)||"'NOMBRE','TELEFONO PARTICULAR','TELEFONO CELULAR','TELEFONO OFICINA','NOMBRE','TELEFONO PARTICULAR','TELEFONO CELULAR','TELEFONO OFICINA'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ''''||num_solicitud,''''||num_cliente,TO_CHAR(fecha_alta, '%d/%m/%Y'),sucursal,nom_cliente,status_solicitud,monto_solicitud::CHAR(16),monto_otorgado::CHAR(16),";
		LET cCmd1 =""||TRIM(cCmd1)||"TO_CHAR(fecha_cambio_status, '%d/%m/%Y'),nom_promotor_realizo,nom_promotor_autorizo,nom_promotor_entrego,nom_promotor_asigno,''''||tel_particular,''''||tel_celular,''''||tel_oficina,";
		LET cCmd1 =""||TRIM(cCmd1)||"nom_ref1,''''||tel_particular_ref1,''''||tel_celular_ref1,''''||tel_oficina_ref1,nom_ref2,''''||tel_particular_ref2,''''||tel_celular_ref2,''''||tel_oficina_ref2";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detstatussolaudexcel";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)))";
		
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el archivo original
		LET cSql = '';
		LET cSql = "rm -rf "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃ­nea
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		RETURN cCodRet,cNombreRepXls;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de generar el reporte en excel de solicitudes para el area de auditoria.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_marcase(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumCte CHAR(20), pNumCredito CHAR(20), pSE CHAR(1), pCausa SMALLINT, pTipoMovimiento INTEGER)
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreUsuario CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreUsuario = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_marcase.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(nombre) INTO cNombreUsuario
		FROM bdinteg:"informix".si_ejecut WHERE empresa = cEmpresa AND ejecutivo = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisitesp:"informix".sp_marcarse(pNumCte,cEmpresa,pNumCredito,pSE,pCausa,cNombreUsuario,pUsuario,pTipoMovimiento)			
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_marcarse';
		ELIF cCodRetSp::INTEGER > 0 THEN 
			IF cCodRetSp::INTEGER = 999 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '01206'; --NO ES UNA SITUACIÓN Y CAUSA VÁLIDOS
			ELIF cCodRetSp::INTEGER = 2 AND pTipoMovimiento = 1 THEN
				LET cCodRet = '01210'; --EL CLIENTE YA TIENE UNA MARCACIÓN
			ELIF cCodRetSp::INTEGER = 2 AND pTipoMovimiento = 2 THEN
				LET cCodRet = '01211'; --EL CRÉDITO YA TIENE UNA MARCACIÓN
			ELIF cCodRetSp::INTEGER = 3 AND pTipoMovimiento = 1 THEN
				LET cCodRet = '01212'; --LA SITUACIÓN Y LA CAUSA QUE SELECCIONÓ SOLO MARCA AL CRÉDITO Y NO AL CLIENTE
			ELIF cCodRetSp::INTEGER = 3 AND pTipoMovimiento = 2 THEN
				LET cCodRet = '01213'; --LA SITUACIÓN Y LA CAUSA QUE SELECCIONÓ SOLO MARCA AL CLIENTE Y NO AL CRÉDITO
			ELIF cCodRetSp::INTEGER = 5 THEN
				LET cCodRet = '01214'; --USUARIO SIN DERECHO PARA EL MARCAJE
			END IF;
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de marcar los clientes y/o creditos para asignarles una situacion especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sustituyese(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumCte CHAR(20), pNumCredito CHAR(20), pSE CHAR(1), pCausa SMALLINT, pTipoMovimiento INTEGER)
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreUsuario CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreUsuario = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_sustituyese.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT TRIM(nombre) INTO cNombreUsuario
		FROM bdinteg:"informix".si_ejecut WHERE empresa = cEmpresa AND ejecutivo = pUsuario;
		
		LET cNombreUsuario = TRIM(cNombreUsuario);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisitesp:"informix".sp_sustituirse(pNumCte,cEmpresa,pNumCredito,pSE,pCausa,cNombreUsuario,pUsuario,pTipoMovimiento)			
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisitesp:sp_sustituirse';
		ELIF cCodRetSp::INTEGER > 0 THEN 
			IF cCodRetSp::INTEGER = 999 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '01206'; --NO ES UNA SITUACIÓN Y CAUSA VÁLIDOS
			ELIF cCodRetSp::INTEGER = 2 AND pTipoMovimiento = 1 THEN
				LET cCodRet = '01215'; --EL CLIENTE NO ESTÁ MARCADO CON UNA SITUACIÓN Y CAUSA
			ELIF cCodRetSp::INTEGER = 2 AND pTipoMovimiento = 2 THEN
				LET cCodRet = '01216'; --EL CRÉDITO NO ESTÁ MARCADO CON UNA SITUACIÓN Y CAUSA
			ELIF cCodRetSp::INTEGER = 3 AND pTipoMovimiento = 1 THEN
				LET cCodRet = '01217'; --LA SITUACIÓN Y CAUSA QUE DESEA MARCAR AL CLIENTE NO PUEDE SUSTITUIR A LA SITUACIÓN Y CAUSA ACTUAL
			ELIF cCodRetSp::INTEGER = 3 AND pTipoMovimiento = 2 THEN
				LET cCodRet = '01218'; --LA SITUACIÓN Y CAUSA QUE DESEA MARCAR AL CRÉDITO NO PUEDE SUSTITUIR A LA SITUACIÓN Y CAUSA ACTUAL
			ELIF cCodRetSp::INTEGER = 4 AND pTipoMovimiento = 1 THEN
				LET cCodRet = '01212'; --LA SITUACIÓN Y LA CAUSA QUE SELECCIONÓ SOLO MARCA AL CRÉDITO Y NO AL CLIENTE
			ELIF cCodRetSp::INTEGER = 4 AND pTipoMovimiento = 2 THEN
				LET cCodRet = '01213'; --LA SITUACIÓN Y LA CAUSA QUE SELECCIONÓ SOLO MARCA AL CLIENTE Y NO AL CRÉDITO
			ELIF cCodRetSp::INTEGER = 5 THEN
				LET cCodRet = '01219'; --USUARIO SIN DERECHO PARA SUSTITUIR
			END IF;
		END IF;
		
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 05/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: MARCAJE INDIVIDUAL - SITUACIONES ESPECIALES',
'DESCRIPCION: SPL encargado de realizar la sustitucion de alguna situacion especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaperfil(pUsuario CHAR(8),pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		SMALLINT AS tipo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE sTipo SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET sTipo = 0;
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,sTipo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_validaperfil.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,sTipo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,sTipo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_perfil_usuario(cEmpresa,pUsuario) 
		INTO cCodRetSp,cDescCodRetSp,sTipo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_valida_perfil_usuario';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet,sTipo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat Leon Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de validar el perfil del usuario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatuscredbloqfall(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(6) AS error_sp;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cErrorSp CHAR(6);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cErrorSp = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cErrorSp;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatuscredbloqfall.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cErrorSp;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cErrorSp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,num_registros,error_proceso,error,error_sp
		INTO cStatus,iNumRegistros,cErrorProceso,cError,cErrorSp
		FROM "informix".sw_verificastatusrepqueb WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cErrorSp;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 04/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE CRÉDITOS QUEBRANTADOS',
'DESCRIPCION: SPL encargado verificar el status de la generacion del reporte de creditos quebrantados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusgenerarep(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusgenerarep.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".sw_verificastatusrep WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado verificar el status de la generacion del reporte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaciudades(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2),pNumCiudad CHAR(3),pNomCiudad CHAR(30))
		RETURNING CHAR(5) AS codret,
		  CHAR(80) AS mensaje_Retorno,
		  CHAR(2)  AS ciudad,
		  CHAR(30) AS nombre;    
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE cCiudad CHAR(2);
	DEFINE cNombre CHAR(30);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET cCiudad = '';
	LET cNombre = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, cCiudad, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaciudades.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEstado IS NULL OR pNumCiudad IS NULL OR pNumCiudad = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, cCiudad, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, cCiudad, cNombre;
		END IF;
		
		LET pNumCiudad = LPAD(TRIM(pNumCiudad),3,'0');
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultaciudades(pEstado, pNumCiudad, pNomCiudad, 0)
			INTO cCodRetSp, cMensajeRet, cCiudad, cNombre
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultaciudades';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cMensajeRet, cCiudad, cNombre WITH RESUME;
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta la Ciudad del Cliente Coppel',
'BD: bdicnweb',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 13/07/2020',
'DESCRIPCION: Se realiza incremento a la longitud del parametro pNumCiudad',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 22/10/2020',
'DESCRIPCION: Se realiza ajuste a procedimiento para realiar el llamada al SP sp_consultaciudades',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultacoloniascp(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2), pNumCiudad CHAR(3), pNumColonia INTEGER, pNomZona CHAR(32))
		RETURNING CHAR(5) AS codret,
		  CHAR(80) AS mensaje_Retorno,
		  INTEGER  AS colonia,
		  CHAR(32) AS nombre,
		  INTEGER  AS codigo_postal,
		  CHAR(1) AS unidad_habitacional;    
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE iColonia INTEGER;
	DEFINE cNombre CHAR(32);
	DEFINE iCodigoPostal INTEGER;
	DEFINE cUnidadHabitacional CHAR(1); 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET iColonia = 0;
	LET cNombre = '';
	LET iCodigoPostal = 0;
	LET cUnidadHabitacional = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultacoloniascp.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEstado = '' OR pNumCiudad = '' OR pNumColonia IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
		END IF;
		
		LET pNumCiudad = LPAD(TRIM(pNumCiudad),3,'0');
		
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultacoloniascp(pEstado, pNumCiudad, pNumColonia, pNomZona, 0)
			INTO cCodRetSp, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultacoloniascp';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional WITH RESUME;
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta la Colonia del Cliente Coppel',
'BD: bdicnweb',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 13/07/2020',
'DESCRIPCION: Se realiza incremento a la logitud del parametro pNumciudad',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 22/10/2020',
'DESCRIPCION: Se realiza ajuste a procedimiento para realizar el llamada al sp sp_consultacoloniascp',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultactesdictamenhawk(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, 
															pNumCte CHAR(20), pTipoDictamen CHAR(1), pAnalista CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATETIME YEAR TO SECOND AS FechaAlerta,
			DATETIME YEAR TO SECOND AS FechaAtendida,
			SMALLINT AS Coincidencias,
			CHAR(4) AS NumSucursal,
			CHAR(8) AS NumEmpProm,
			CHAR(45) AS NombrePromotor,
			CHAR(20) AS NumCte,
			CHAR(100) AS NomCte,
			CHAR(8) AS EmpAnalista,
			CHAR(45) AS NomAnalista,
			CHAR(20) AS TiempoResp,
			CHAR(20) AS NumCteCoinc,
			CHAR(25) AS DescCoinc,		
			CHAR(1) AS Origen,
			CHAR(30) AS DescripOrigen,
			CHAR(40) AS NomSucursal,
			CHAR(30) AS EstadoSucursal,
			CHAR(60) AS CiudadSucursal,
			CHAR(50) AS DescDictamen;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaAlerta DATETIME YEAR TO SECOND;
	DEFINE dFechaAtendida DATETIME YEAR TO SECOND;	
	DEFINE sCoincidencias SMALLINT;
	DEFINE cSucursal CHAR(4);
	DEFINE cNumEmpProm CHAR(8);
	DEFINE cNombrePromotor CHAR(45);	
	DEFINE cNumCte CHAR(20);
	DEFINE cNomCte CHAR(100);
	DEFINE cEmpAnalista CHAR(8);
	DEFINE cNomAnalista CHAR(45);
	DEFINE cTiempoResp CHAR(20);
	DEFINE cNumCteCoinc CHAR(20);
	DEFINE cDescCoinc CHAR(25);
	DEFINE cOrigen CHAR(1);
	DEFINE cDescripOrigen CHAR(30);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cEstadoSuc CHAR(30);
	DEFINE cCiudadSuc CHAR(60);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripDict CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iCodRetSp = 0;
	LET dFechaAlerta = '';
	LET dFechaAtendida = '';	
	LET cTiempoResp = '';
	LET sCoincidencias = 0;
	LET cSucursal= '';
	LET cNumEmpProm = '';
	LET cNombrePromotor= '';
	LET cNomAnalista = '';
	LET cNumCte = '';
	LET cNomCte = '';
	LET cEmpAnalista = '';	
	LET cNumCteCoinc = '';	
	LET cDescCoinc = '';
	LET cOrigen = '';
	LET cDescripOrigen = '';
	LET cNomSucursal = '';
	LET cEstadoSuc = '';
	LET cCiudadSuc = '';
	LET iRecuperacion = 0;
	LET cDescripDict = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultactesdictamenhawk.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta NOT IN('1','2','3','4', '5') THEN
			LET cCodRet = '00003';						           
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		END IF;
		
		IF pTipoConsulta IN('1','2','3','4') THEN
			--IF pTipoDictamen = '' OR pAnalista = '' THEN
			--	LET cCodRet = '00003';				
			--	RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc;
			IF pTipoConsulta = '2' AND pSucursal = '' THEN
				LET cCodRet = '00003';				
				RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
			ELIF pTipoConsulta = '3' AND (pFechaIni IS NULL OR pFechaFin IS NULL) THEN
				LET cCodRet = '00003';				
				RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
			ELIF pTipoConsulta = '4' AND pNumCte = '' THEN
				LET cCodRet = '00003';				
				RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
			END IF;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		END IF;
		
		FOREACH
			SELECT SKIP pRegistros FIRST  pRecuperacion fecha_alerta,fecha_atendida,coincidencias,num_sucursal,num_emp_prom,nombre_promotor,num_cte,nom_cte,emp_analista,nom_analista,tiempo_resp,num_cte_coinc,desc_coinc,origen,descrip_origen,nom_sucursal,estado_sucursal,ciudad_sucursal,descripcionDictamen
			INTO dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict
			FROM "informix".sw_dic_ctesdictamenhawktmp
			WHERE usuario = pUsuario
			AND tipo_consulta = pTipoConsulta 
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict;
		END IF;
		/*IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc;
		END IF;	*/		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la consulta de clientes dictamenes hawk',
'BD: bdicnweb',
'AUTOR: Veronica Sanchex Tlacomulco',
'FECHA: 22/09/2020',
'DESCRIPCION: Se realiza ajuste a SPL para tratamiento de pÃÂ¡ginado',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'DESCRIPCION: Se realiza ajuste a SPL para agregar la descripcion del dictamen';

CREATE PROCEDURE "informix".sp_dic_consultactesdictamenhawk_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), pSucursal CHAR(4), 
																	pFechaIni DATE, pFechaFin DATE, pNumCte CHAR(20), pTipoDictamen CHAR(1), pAnalista CHAR(8))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dFechaAlerta DATETIME YEAR TO SECOND;
	DEFINE dFechaAtendida DATETIME YEAR TO SECOND;	
	DEFINE sCoincidencias SMALLINT;
	DEFINE cSucursal CHAR(4);
	DEFINE cNumEmpProm CHAR(8);
	DEFINE cNombrePromotor CHAR(45);
	DEFINE cNumCte CHAR(20);
	DEFINE cNomCte CHAR(100);
	DEFINE cEmpAnalista CHAR(8);
	DEFINE cNomAnalista CHAR(45);
	DEFINE cTiempoResp CHAR(20);
	DEFINE cNumCteCoinc CHAR(20);
	DEFINE cDescCoinc CHAR(25);
	DEFINE cOrigen CHAR(1);
	DEFINE cDescripOrigen CHAR(30);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cEstadoSuc CHAR(30);
	DEFINE cCiudadSuc CHAR(60);
	DEFINE cDescripDict CHAR(50);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iNoRegistros = 0;
	LET dFechaAlerta = '';
	LET dFechaAtendida = '';	
	LET cTiempoResp = '';
	LET sCoincidencias = 0;
	LET cSucursal= '';
	LET cNumEmpProm = '';
	LET cNombrePromotor= '';
	LET cNomAnalista = '';
	LET cNumCte = '';
	LET cNomCte = '';
	LET cEmpAnalista = '';	
	LET cNumCteCoinc = '';	
	LET cDescCoinc = '';
	LET cOrigen = '';
	LET cDescripOrigen = '';
	LET cNomSucursal = '';
	LET cEstadoSuc = '';
	LET cCiudadSuc = '';
	LET cDescripDict = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
            SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultactesdictamenhawk_totales.out';
		-- TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta NOT IN('1','2','3','4', '5') THEN
			LET cCodRet = '00003';			
			UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
            SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoConsulta IN('2','3','4') THEN
			--IF pTipoDictamen = '' OR pAnalista = '' THEN
			--	LET cCodRet = '00003';
			--	UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
            --    SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			--	RETURN cCodRet, iNoRegistros;
			IF pTipoConsulta = '2' AND pSucursal = '' THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNoRegistros;
			ELIF pTipoConsulta = '3' AND (pFechaIni IS NULL OR pFechaFin IS NULL) THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNoRegistros;
			ELIF pTipoConsulta = '4' AND pNumCte = '' THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNoRegistros;
			END IF;
		END IF;
		
		--IF pTipoConsulta IN('6', '7') AND pNumCte = '' THEN
		--	LET cCodRet = '00003';			
		--	RETURN cCodRet, iNoRegistros;
		--END IF;							
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD	
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
            SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- TRATAMIENTO POR VOLUMETRIA 
		DELETE FROM bdicnweb:"informix".sw_dic_statusconsctesdichawk WHERE usuario = pUsuario;
		
		INSERT INTO bdicnweb:"informix".sw_dic_statusconsctesdichawk(usuario,total_registros,status,error_proceso,error_code)
        VALUES(pUsuario, iNoRegistros,'I','', ''); 
		
		--BORRA DATOS TABLA TEMPORAL 
		DELETE FROM "informix".sw_dic_ctesdictamenhawktmp WHERE usuario = pUsuario AND tipo_consulta = pTipoConsulta;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consultactesdictamen2(pTipoConsulta, pSucursal, pFechaIni, pFechaFin, pNumCte, pTipoDictamen, pAnalista)
			INTO cCodRetSp,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cDescripDict
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNoRegistros;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
				SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNoRegistros;
			ELSE
				INSERT INTO "informix".sw_dic_ctesdictamenhawktmp(usuario,tipo_consulta,fecha_alerta,fecha_atendida,coincidencias,num_sucursal,num_emp_prom,nombre_promotor,num_cte,nom_cte,emp_analista,nom_analista,tiempo_resp,num_cte_coinc,desc_coinc,origen,descrip_origen,nom_sucursal,estado_sucursal,ciudad_sucursal,descripcionDictamen)
				VALUES (pUsuario,pTipoConsulta,dFechaAlerta,dFechaAtendida,sCoincidencias,cSucursal,cNumEmpProm,cNombrePromotor,cNumCte,cNomCte,cEmpAnalista,cNomAnalista,cTiempoResp,cNumCteCoinc,cDescCoinc,cOrigen,cDescripOrigen,cNomSucursal,cEstadoSuc,cCiudadSuc,cDescripDict);
			END IF;
		END FOREACH;
		
		SELECT COUNT(*) 
		INTO iNoRegistros
		FROM "informix".sw_dic_ctesdictamenhawktmp
		WHERE usuario = pUsuario
		AND tipo_consulta = pTipoConsulta;
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
			SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		UPDATE bdicnweb:"informix".sw_dic_statusconsctesdichawk
        SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
		RETURN cCodRet, iNoRegistros;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/06/2018',
'MODULO: Clientes',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el total de dictamen de alertas',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 22/09/2020',
'DESCRIPCION: Se realiza ajuste a SP para realiza el llamado al SP sp_dicta_consultactesdictamen2',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'DESCRIPCION: Se realiza ajuste a SPL para agregar la descripcion del dictamen';

CREATE PROCEDURE "informix".sp_dic_detallectesdictamenhawk(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20))
		RETURNING CHAR(5) AS codret,
			DATETIME YEAR TO SECOND AS FechaAlerta,
			DATETIME YEAR TO SECOND AS FechaAtendida,
			CHAR(1) AS Origen,
			CHAR(30) AS DescripOrigen,			
			CHAR(4) AS NumSucursal,
			CHAR(40) AS NomSucursal,
			CHAR(20) AS NumCte,
			CHAR(100) AS NomCte,
			CHAR(25) AS DescCoinc,	
			CHAR(20) AS NumCteCoinc,
			CHAR(8) AS EmpAnalista,
			CHAR(45) AS NomAnalista,
			CHAR(20) AS TiempoResp,
			CHAR(50) AS DescDictamen,
			CHAR(104) AS NomCteCoinc;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	--DEFINE cCodRetSp CHAR();
	--DEFINE iCodRetSp INTEGER;
	DEFINE dFechaAlerta DATETIME YEAR TO SECOND;
	DEFINE dFechaAtendida DATETIME YEAR TO SECOND;
	DEFINE cOrigen CHAR(1);
	DEFINE cDescripOrigen CHAR(30);
	DEFINE cSucursal CHAR(4);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cNumCte CHAR(20);
	DEFINE cNomCte CHAR(100);
	DEFINE cDescCoinc CHAR(25);
	DEFINE cNumCteCoinc CHAR(20);
	DEFINE cEmpAnalista CHAR(8);
	DEFINE cNomAnalista CHAR(45);
	DEFINE cTiempoResp CHAR(20);
	DEFINE cTipoCoinc CHAR(1);
	DEFINE cTipoDictamen CHAR(1);
	DEFINE cNombre1 VARCHAR(26);
	DEFINE cNombre2 VARCHAR(26);
	DEFINE cApellPaterno VARCHAR(26);
	DEFINE cApellMaterno VARCHAR(26);
	DEFINE cDescripDict CHAR(50);
	DEFINE cNombreCteCoinc CHAR(104);
	DEFINE cTicket CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	--LET cCodRetSp = '';
	--LET iCodRetSp = 0;
	LET dFechaAlerta = '';
	LET dFechaAtendida = '';
	LET cOrigen = '';
	LET cDescripOrigen = '';
	LET cSucursal = '';
	LET cNomSucursal = '';
	LET cNumCte = '';
	LET cNomCte = '';
	LET cDescCoinc = '';
	LET cNumCteCoinc = '';
	LET cEmpAnalista = '';
	LET cNomAnalista = '';
	LET cTiempoResp = '';
	LET cTipoCoinc = '';
	LET cTipoDictamen = '';	
	LET cNombre1='';
	LET cNombre2='';
	LET cApellPaterno='';
	LET cApellMaterno='';
	LET cDescripDict='';
	LET cNombreCteCoinc = '';
	LET cTicket = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,cOrigen,cDescripOrigen,cSucursal,cNomSucursal,cNumCte,cNomCte,cDescCoinc,cNumCteCoinc,cEmpAnalista,cNomAnalista,cTiempoResp,cDescripDict,cNombreCteCoinc;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_detallectesdictamenhawk.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,cOrigen,cDescripOrigen,cSucursal,cNomSucursal,cNumCte,cNomCte,cDescCoinc,cNumCteCoinc,cEmpAnalista,cNomAnalista,cTiempoResp,cDescripDict,cNombreCteCoinc;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,cOrigen,cDescripOrigen,cSucursal,cNomSucursal,cNumCte,cNomCte,cDescCoinc,cNumCteCoinc,cEmpAnalista,cNomAnalista,cTiempoResp,cDescripDict,cNombreCteCoinc;
		END IF;
		
		FOREACH
			SELECT bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, bd.numcte, bd.tipo, numcte_coinc, bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen 
			INTO dFechaAlerta, dFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen
			FROM bdinteg:"informix".si_bitacora_dictamenes bd,bdinteg:"informix".si_catorigenhuellas sc
			WHERE bd.numcte = pNumCte
			AND bd.origen = sc.cod_origen 
				
				-- DESCRIPCION DICTAMEN --------
				SELECT descripcion 
				INTO cDescripDict
				FROM bdisitesp:"informix".se_catdictamenes 
				WHERE tipodictamen = cTipoDictamen;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA. --------
				SELECT nombre INTO cNomAnalista
				FROM bdinteg:"informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.  --------
				SELECT descripcion INTO cDescCoinc
				FROM bdinteg:"informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
								
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL. --------
				SELECT nombre1,nombre2,apell_paterno,apell_materno --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNombre1,cNombre2,cApellPaterno,cApellMaterno
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = cNumCte;
				
				LET cNomCte=TRIM(TRIM(cNombre1)||' '||TRIM(cNombre2))||' '||TRIM(TRIM(cApellPaterno)||' '||TRIM(cApellMaterno));
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT nombre AS sucursal --se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal 
				FROM bdinteg:"informix".si_sucursales  
				WHERE sucursal = cSucursal;
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE COINCIDENCIA.
				SELECT FIRST 1 ticket INTO cTicket FROM bdinteg:"informix".si_huella_linea WHERE numcte=cNumCte;
				
				SELECT LIMIT 1 nombre INTO cNombreCteCoinc
				FROM bdinteg:"informix".si_huella_linea_resultado
				WHERE ticket = TRIM(cTicket) AND cliente=cNumCteCoinc and num_mensaje='602' and empresa=cTipoCoinc;
				
				IF NVL(cNombreCteCoinc,'') = '' THEN
					SELECT LIMIT 1 nombre INTO cNombreCteCoinc
					FROM bdinteg:"informix".si_huella_linea_resultado_hist
					WHERE ticket = TRIM(cTicket) AND cliente=cNumCteCoinc and num_mensaje='602' and empresa=cTipoCoinc;
				end if;
				
				RETURN cCodRet,dFechaAlerta,dFechaAtendida,cOrigen,cDescripOrigen,cSucursal,cNomSucursal,cNumCte,cNomCte,cDescCoinc,cNumCteCoinc,cEmpAnalista,cNomAnalista,cTiempoResp,cDescripDict,cNombreCteCoinc WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,dFechaAlerta,dFechaAtendida,cOrigen,cDescripOrigen,cSucursal,cNomSucursal,cNumCte,cNomCte,cDescCoinc,cNumCteCoinc,cEmpAnalista,cNomAnalista,cTiempoResp,cDescripDict,cNombreCteCoinc;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 12/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el detalle del dictamen por cliente',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'DESCRIPCION: Se realiza ajuste a SPL para agregar la descripcion del dictamen',
'AUTOR: Veronica Sanches Tlacomulco',
'FECHA: 19/10/2020',
'DESCRIPCION: Se realiza ajuste a SPL para agregar el nomnbre del cliente en coincidencia';

CREATE PROCEDURE "informix".sp_dic_actualizastatusalerta(pUsuario CHAR(8), pIdFuncion CHAR(10), pTramaEnvios CHAR(250), pEstatus CHAR(1))
		RETURNING CHAR(5) AS codret,
		CHAR(30) AS mensaje;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescMensaje CHAR(30);
	DEFINE cNumCte CHAR(9);
	DEFINE cNumSucursal CHAR(9); 
	DEFINE cStatus CHAR (1);
	DEFINE cSucursal CHAR (4);
	DEFINE iNoRegistros INTEGER; 
	DEFINE cFechaInsert DATETIME YEAR TO SECOND;
	DEFINE iTotalReg INTEGER;
	DEFINE sMatches SMALLINT;
	DEFINE sDictaminados SMALLINT;
	DEFINE sTotal SMALLINT;
	DEFINE cOrigen CHAR (1);
	DEFINE iPagina INTEGER;
	DEFINE sCtesAfore SMALLINT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescMensaje = '';
	LET cNumCte = ''; 
	LET cStatus = pEstatus;
	LET cSucursal = '';
	LET iNoRegistros = 0;  
	LET cFechaInsert = '';
	LET iTotalReg = 0;
	LET sMatches = 0;
	LET sDictaminados = 0;
	LET sTotal = 0;
	LET cOrigen = '';
	LET iPagina = 0;
	LET sCtesAfore = 0;
	
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescMensaje;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_actualizastatusalerta.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTramaEnvios = '' THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
			SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			
			RETURN cCodRet, cDescMensaje;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
		INTO cCodRet;
		
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
			SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, cDescMensaje;
		END IF;
		
		DELETE FROM bdicnweb:"informix".sw_dic_statusenviobuzon WHERE usuario = pUsuario;
		
		INSERT INTO bdicnweb:"informix".sw_dic_statusenviobuzon(usuario,total_registros,status,error_proceso,error_code)
		VALUES(pUsuario, iNoRegistros,'I','', ''); 

		FOREACH 
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEnvios, '|')
			INTO cNumCte
			
			SELECT FIRST 1 sucursal, fecha_insert::DATETIME YEAR TO DAY
			INTO cSucursal, cFechaInsert
			FROM bdinteg:"informix".si_bitacora_alerta_tmp				
			WHERE numcte = cNumCte;
		
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN

				EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_actualizastatusalerta(cNumCte, cSucursal, cStatus, cFechaInsert, pUsuario)
				INTO cCodRetSp, cDescMensaje;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_actualizastatusalerta';			
				ELIF iCodRetSp = 1 THEN 
					LET cCodRet = '00003';
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RETURN cCodRet, cDescMensaje;
				ELIF iCodRetSp IN(2,3) THEN 
					LET cCodRet = '00283';
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RETURN cCodRet, cDescMensaje;
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;		
			ELSE
				SELECT {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_status)} DISTINCT (TRIM(numcte)),TRIM(status_alerta),TRIM(sucursal), num_huellas,fecha_insert,origen
				INTO cNumcte,cStatus,cSucursal,sMatches,cFechaInsert,cOrigen
				FROM bdinteg:"informix".si_bitacora_comparaciones
				WHERE numcte = cNumcte;
				
				-- CUENTA LOS MATCHES YA DICTAMINADOS.
				SELECT COUNT(*)
				INTO sDictaminados
				FROM bdinteg:"informix".si_bitacora_dictamenes
				WHERE numcte = cNumcte;
				
				-- OBTIENE EL PAGINADO MAXIMO EN TABLA
				SELECT MAX(pagina) INTO iPagina
				FROM bdinteg:"informix".si_bitacora_alerta_tmp
				WHERE user_analista = pUsuario;
				-- TRATAMIENTO VALOR NULO
				IF NVL(iPagina,0) = 0 THEN 
					LET iPagina = 1;
				END IF;
				
				-- OBTIENE EL TOTAL DE REGITROS
				SELECT COUNT(*) INTO iTotalReg
				FROM bdinteg:"informix".si_bitacora_alerta_tmp				
				WHERE user_analista = pUsuario;
			
				IF iTotalReg = 0 THEN 
					LET iTotalReg = 1;
				ELSE	
					LET iTotalReg = iTotalReg + 1;
				END IF;
				
				--VERIFICA SI CUENTA CON CLIENTES AFORE O EMPRESAS NO VALIDAS.
				SELECT COUNT(*)
				INTO sCtesAfore
				FROM bdinteg:"informix".si_huella_linea_resultado a, bdinteg:"informix".si_huella_linea b
				WHERE a.ticket = b.ticket
				AND b.numcte = cNumcte
				AND a.num_mensaje = '602'
				AND a.empresa IN ('','6');
				
				IF NVL(sCtesAfore,'') = '' THEN
					SELECT COUNT(*)
					INTO sCtesAfore
					FROM bdinteg:"informix".si_huella_linea_resultado_hist a, bdinteg:"informix".si_huella_linea b
					WHERE a.ticket = b.ticket
					AND b.numcte = cNumcte
					AND a.num_mensaje = '602'
					AND a.empresa IN ('','6');
				END IF
            
				-- RESTA EL TOTAL DE MATCHES PARA MOSTRAR EN PANTALLA LAS QUE ELIMINARAN.
				IF sCtesAfore > 0 THEN
					LET sMatches = sMatches - sCtesAfore;
				END IF;
					
				LET sMatches = sMatches - sDictaminados;
				
				--INSERTA INFORMACION EN LA TABLA DE TRABAJO.
				INSERT INTO bdinteg:"informix".si_bitacora_alerta_tmp (pagina,registro,numcte,origen,sucursal,num_huellas,status_alerta,fecha_insert,user_analista)
				VALUES (iPagina,iTotalReg,cNumcte,cOrigen,cSucursal,sMatches,cStatus,cFechaInsert,pUsuario);
					
				EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_actualizastatusalerta(cNumCte, cSucursal, pEstatus, cFechaInsert, pUsuario)
				INTO cCodRetSp, cDescMensaje;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_actualizastatusalerta';			
				ELIF iCodRetSp = 1 THEN 
					LET cCodRet = '00003';
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RETURN cCodRet, cDescMensaje;
				ELIF iCodRetSp IN(2,3) THEN 
					LET cCodRet = '00283';
					UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
					SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
					RETURN cCodRet, cDescMensaje;
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
		END FOREACH;
		
		UPDATE bdicnweb:"informix".sw_dic_statusenviobuzon
		SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
		RETURN cCodRet, cDescMensaje;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 28/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la actualizaciÃ³n del status de la ComparaciÃ³n de Huellas en LÃ­nea',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 03/09/2018',
'DESCRIPCION: ModificaciÃ³n de SPL para cambiar el status a 5 (Envio a BuzÃ³n de Pendientes)',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/10/2018',
'DESCRIPCION: ModificaciÃ³n de SPL para pasar como parametro de entrada el estatus',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 09/11/2020',
'DESCRIPCION: Se realiza ajuste a SP para realizar insercion de informacion antes de actualizar estatus de alerta.';

CREATE PROCEDURE "informix".sp_cred_grabacomplementarias(pUsuario CHAR(10), pIdFuncion CHAR(10), pCuentas_Medios CHAR(1), pCancelacion_Inac CHAR(1), pCancelacion_Vig CHAR(1), pTiempo_Cancelar CHAR(1), 
			 pSeguro_Vida CHAR(1), pCobro_Mensualidad CHAR(1), pEnvio_Mesa_Control  CHAR(1), pId_Domiciliacion CHAR(1), pConciliador CHAR(1), pHistorico_Cred CHAR(1), pPeriodo_Gracia CHAR(1), 
			 pDias_Gracia INTEGER, pCapital_Interes CHAR(1), pIntereses CHAR(1), pEstado_Cuenta CHAR(1),pTipoEdocta CHAR(1), pTipoFacturacion CHAR(1), pd_estadocuenta CHAR(3), pemision_estado_cuenta CHAR(2), 
			 prango_inicial CHAR(2),prango_final CHAR(2),pid_tipo_facturacion CHAR(2), pn_dias_facturacion CHAR(3), pdia_facturacion CHAR(2), prango_f_fecha_inic CHAR(2), prango_f_fecha_fin CHAR(2), 
			 pidcta_concentradora CHAR(1), pcta_concentradora CHAR(20))
      RETURNING CHAR(5) AS codRet;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_grabacomplementarias.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet;
        END IF;

		INSERT INTO bdicred:"informix".tmp_caracteristicas_complementarias(pcuentas_medios, pcancelacion_inac, pcancelacion_vig, ptiempo_cancelar, pseguro_vida, pcobro_mensualidad, penvio_mesa_control, pid_domiciliacion, pconciliador, phistorico_cred, pperiodo_gracia, pdias_gracia, pcapital_interes, pintereses, pestado_cuenta, ptipoedocta, ptipofacturacion, pd_estadocuenta, pemision_estado_cuenta, prango_inicial, prango_final, pid_tipo_facturacion, pn_dias_facturacion, pdia_facturacion, prango_f_fecha_inic, prango_f_fecha_fin, pidcta_concentradora, pcta_concentradora, usuario_insert) 
		VALUES(pCuentas_Medios, pCancelacion_Inac, pCancelacion_Vig, pTiempo_Cancelar, pSeguro_Vida, pCobro_Mensualidad, pEnvio_Mesa_Control, pId_Domiciliacion, pConciliador, pHistorico_Cred, pPeriodo_Gracia, 
			 pDias_Gracia, pCapital_Interes, pIntereses, pEstado_Cuenta, pTipoEdocta, pTipoFacturacion, pd_estadocuenta, pemision_estado_cuenta, prango_inicial, prango_final, pid_tipo_facturacion, pn_dias_facturacion, 
			 pdia_facturacion, prango_f_fecha_inic, prango_f_fecha_fin, pidcta_concentradora, pcta_concentradora, pUsuario);
	
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 19/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Alta Subproductos',
'DESCRIPCION: SPL encargado de grabar caracteristicas temporales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consulta_familia(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcion CHAR(3))
		RETURNING CHAR(5) AS codret,
				CHAR(3) AS cId,
				CHAR(40) AS cFamilia;

	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cId 					 CHAR(3);
	DEFINE cFamilia 			 CHAR(40);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cId 					= '';
	LET cFamilia 				= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId, cFamilia;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consulta_familia.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId, cFamilia;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId, cFamilia;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_familia(pOpcion)
			INTO cCodRetSp, cId, cFamilia

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consulta_familia";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cId, cFamilia;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cId, cFamilia;
			END IF;

			RETURN cCodRet, cId, cFamilia WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar la familia del producto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consultaproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pNombreProd CHAR(40), p_tpo_ejecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				  CHAR(100)  AS Variable1,
				  CHAR(100)  AS Variable2,
				  CHAR(100)  AS Variable3,
				  CHAR(100)  AS Variable4,
				  CHAR(100)  AS Variable5,
				  CHAR(100)  AS Variable6,
				  CHAR(100)	 AS Variable7,
				  CHAR(100)  AS Variable8;
			 
	
	DEFINE cCodRet 				   CHAR(5);
	DEFINE cCodRetSp 			   CHAR(5);
	DEFINE iSqlErr 				   INTEGER;
	DEFINE iCodRetSp 			   INTEGER;
	DEFINE vVariable1			   VARCHAR(100);
	DEFINE vVariable2			   VARCHAR(100);
	DEFINE vVariable3			   VARCHAR(100);
	DEFINE vVariable4			   VARCHAR(100);
	DEFINE vVariable5			   VARCHAR(100);
	DEFINE vVariable6			   VARCHAR(100);
	DEFINE vVariable7			   VARCHAR(100);
	DEFINE vVariable8			   VARCHAR(100);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET vVariable1			    = '';
	LET vVariable2			    = '';
	LET vVariable3			    = '';
	LET vVariable4			    = '';
	LET vVariable5			    = '';
	LET vVariable6			    = '';
	LET vVariable7			    = '';
	LET vVariable8			    = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultaproductos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pNumProducto = '' AND pNombreProd = '' AND p_tpo_ejecucion = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_productos(pNumProducto, pNombreProd, p_tpo_ejecucion)
			INTO cCodRetSp, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8
			
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_cred_consultaproductos";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			END IF;
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los productos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_insertaconvproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(2), pProducto CHAR(4), pDescripcion CHAR(40))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_insertaconvproductos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pProducto  = '' OR pDescripcion  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_conv_productos(pTipo, pProducto, pDescripcion)
			INTO cCodRetSp

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_inserta_conv_productos";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			END IF;

			RETURN cCodRet WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_grabatipofacturacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pIdFacturacion CHAR(3), pNoDias INTEGER, pDiaFijo CHAR(3), pRgoMin CHAR(3), pRgoMax CHAR(3), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(3) AS idFacturacion,
				SMALLINT AS noDias,
				CHAR(3) AS diasFijo,
				CHAR(3) AS rangoMinimo,
				CHAR(3) AS rangoMaximo;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSp 		CHAR(5);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cId_facturacion	CHAR(3);
	DEFINE cNo_dias			SMALLINT;
	DEFINE cDia_fijo		CHAR(3);
	DEFINE cRgo_min			CHAR(3);
	DEFINE cRgo_max			CHAR(3);

	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cCodRetSp 			= '';
	LET iCodRetSp 			= 0;
	LET	cId_facturacion		= '';
	LET	cNo_dias			= 0;
	LET	cDia_fijo			= '';
	LET	cRgo_min			= '';
	LET	cRgo_max			= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_grabatipofacturacion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''OR pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_grabatipofacturacion(pNumProducto, pIdFacturacion, pNoDias, pDiaFijo, pRgoMin, pRgoMax, pTipoEjecucion)
			INTO cCodRetSp, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_grabatipofacturacion";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max;
			END IF;

			RETURN cCodRet, cId_facturacion, cNo_dias, cDia_fijo, cRgo_min, cRgo_max WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de grabar los tipos de facturaciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_insertasubproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pDesc_subproducto VARCHAR(40),pNum_producto CHAR(4),pNomb_Producto CHAR(40))
		RETURNING CHAR(5) AS codret,
				CHAR(5) AS cId_subproducto;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cId_subproducto 		 VARCHAR(5);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cId_subproducto 		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId_subproducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_insertasubproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId_subproducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId_subproducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_subproducto(pDesc_subproducto, pNum_producto, pNomb_Producto)
			INTO cCodRetSp, cId_subproducto
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consulta_frecpago";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cId_subproducto;
			END IF;
			
			RETURN cCodRet, cId_subproducto WITH RESUME;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de insertar subproducto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obteneventosmsj(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				 CHAR(4) AS id_evento,
				 CHAR(40) AS descripcion;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE sIdEvento	   		 SMALLINT;
	DEFINE cDescripcion			 CHAR(30);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET sIdEvento				= 0;
	LET cDescripcion			= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sIdEvento, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obteneventosmsj.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sIdEvento, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sIdEvento, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obten_eventos_msj()
			INTO cCodRetSp, sIdEvento, cDescripcion
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obten_eventos_msj";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sIdEvento, cDescripcion;
			END IF;
			
			RETURN cCodRet, sIdEvento, cDescripcion WITH RESUME;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de garantia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtenerdoctosimprimir(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodigoDocumento CHAR(4), pDescripcionDocumento CHAR(40), pCantidad INTEGER, pNumProducto CHAR(4),  pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS codigo_documento,
				CHAR(40) AS descripcion_documento,
				INTEGER AS cantidad;

	DEFINE cCodRet 					CHAR(5);
	DEFINE iSqlErr 					INTEGER;
	DEFINE cCodRetSp 				CHAR(5);
	DEFINE iCodRetSp 				INTEGER;
	DEFINE cCodigoDocumento			CHAR(4);
	DEFINE cDescripcionDocumento	CHAR(40);
	DEFINE iCantidad				INTEGER;

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cCodigoDocumento		= '';
	LET cDescripcionDocumento	= '';
	LET iCantidad				= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento, iCantidad;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtenerdoctosimprimir.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento, iCantidad;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento, iCantidad;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_obtenerdoctosimprimir(pCodigoDocumento, pDescripcionDocumento, pCantidad, pNumProducto, pTipoEjecucion)
			INTO cCodRetSp, cCodigoDocumento, cDescripcionDocumento, iCantidad

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtenerdoctosimprimir";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento, iCantidad;
			END IF;

			RETURN cCodRet, cCodigoDocumento, cDescripcionDocumento, iCantidad WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtenerdoctosdigitalizar(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pCodigoGrupo CHAR(3), pCodigoDocto CHAR(4), pDescripcion CHAR(50), pTipoEjecucion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER, pNombreProducto CHAR(50))
		RETURNING CHAR(5) AS codret,
				CHAR(40) AS codigo,
				CHAR(50) AS descripcion,
				CHAR(4)  AS variable1,
				CHAR(4)  AS variable2,
				CHAR(50)  AS variable3;
		
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cEmpresa    	    	CHAR(4);
	DEFINE cCodigo    	    	CHAR(4);
	DEFINE cDescripcion        	CHAR(50);
	DEFINE cVariable1           CHAR(4);
	DEFINE cVariable2			CHAR(4);
	DEFINE cVariable3           CHAR(50);
	DEFINE iRecuperacion		INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa		        = '001';
	LET cCodigo		           	= '';
	LET cDescripcion           	= '';
	LET cVariable1				= '';
	LET cVariable2				= '';
	LET cVariable3				= '';
	LET iRecuperacion 			= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtenerdoctosdigitalizar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obtenerdoctosdigitalizar(cEmpresa, pNumProducto, pCodigoGrupo, pCodigoDocto, pDescripcion, pTipoEjecucion, pRegistros, pRecuperacion,pNombreProducto)
			INTO cCodRetSp, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtenerdoctosdigitalizar";
			ELIF iCodRetSp = 1 THEN
				IF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
				ELSE
					LET cCodRet = '00017';
				END IF;
				RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3 WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3;
		END IF;	

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los documentos a digitalizar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtenercanaloperacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdCanal SMALLINT, pNombreCanal CHAR(30), pIdOperaciones SMALLINT, pDescOperacion CHAR(100), pNumproducto CHAR(4), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				SMALLINT AS var1,
				CHAR(30) AS var2,
				SMALLINT AS var3,
				CHAR(30) AS var4;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE var1			SMALLINT;
	DEFINE var2			CHAR(30);
	DEFINE var3			SMALLINT;
	DEFINE var4			CHAR(30);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET var1			= 0;
	LET var2			= '';
	LET var3			= 0;
	LET var4			= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, var1, var2, var3, var4;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtenercanaloperacion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, var1, var2, var3, var4;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, var1, var2, var3, var4;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_obtenercanaloperacion(pIdCanal, pNombreCanal, pIdOperaciones, pDescOperacion, pNumproducto, pTipoEjecucion)
			INTO cCodRetSp, var1, var2, var3, var4

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtenercanaloperacion";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, var1, var2, var3, var4;
			END IF;

			RETURN cCodRet, var1, var2, var3, var4 WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 11/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los canales de operacion e insertar los canales de operacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtentipoedocta(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(3) AS id_estdocta, 
				VARCHAR(40) AS desc_estdocta; 
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cid_estdocta 		 VARCHAR(3);
	DEFINE cDesc_Estdocta 		 VARCHAR(40);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cId_Estdocta 			= '';
	LET cDesc_Estdocta 			= ''; 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId_Estdocta, cDesc_Estdocta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtentipoedocta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId_Estdocta, cDesc_Estdocta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId_Estdocta, cDesc_Estdocta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obtentipoedocta()
			INTO cCodRetSp, cId_Estdocta, cDesc_Estdocta
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtentipoedocta";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cId_Estdocta, cDesc_Estdocta;
			END IF;
			
			RETURN cCodRet, cId_Estdocta, cDesc_Estdocta WITH RESUME;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de estados de cuenta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtentipofactura(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(3) AS Id_Tpofacturacion,
				CHAR(40) AS Desc_Facturacion;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cIdTpofacturacion	CHAR(3);
	DEFINE cDescFacturacion 	CHAR(40);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cIdTpofacturacion		= '';
	LET cDescFacturacion		= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtentipofactura.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_obtentipofactura()
			INTO cCodRetSp, cIdTpofacturacion, cDescFacturacion

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtentipofactura";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
			END IF;

			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de factura',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consultatgarantia(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER AS idGarantia,
				VARCHAR(20) AS tipoGarantia,
				VARCHAR(30) AS descGarantias,
				DECIMAL(16) AS porcentajeAforo;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE iIdGarantia     		 INTEGER;
	DEFINE cTipoGarantia   		 VARCHAR(20);
	DEFINE cDescGarantias  		 VARCHAR(30);
	DEFINE dPorcentajeAforo 	 DECIMAL(16);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET iIdGarantia     		= 0;
	LET cTipoGarantia   		= '';
	LET cDescGarantias  		= '';
	LET dPorcentajeAforo 		= 0.0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultatgarantia.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_consultatgarantia()
			INTO cCodRetSp, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consultatgarantia";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo;
			END IF;
			
			RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo WITH RESUME;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de garantia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_caracteristicasproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pNumProducto CHAR(4), pMontoMinCred DECIMAL(18,2), pMontoMaxCred DECIMAL(18,2), pEdadMin INTEGER, pEdadMax INTEGER, 
		pPlazoMinCred INTEGER, pPlazoMaxCred INTEGER, pIdFrecPago SMALLINT, pCobroComisionAnual CHAR(1), pComiGastoCobranza SMALLINT, pCobroComisApertura CHAR(1), pComiDisposicionEfect SMALLINT, 
		pComiAclaracionNo SMALLINT, pComiLiquidacionAntic SMALLINT, pCodComisionApertura CHAR(4), pCodComiGastoCobranza CHAR(4), pCodComisionAnualidad CHAR(8), pCodComiDisposicionEfect CHAR(4), 
		pCodComiAclaracionNo CHAR(4), pCodComiLiquidacionAntic CHAR(4), pGarantias SMALLINT, pIdGarantia SMALLINT, pPorcentajeAforo DECIMAL(16), pObligadoSolidario CHAR(1), pNumObligados CHAR(1), pCapturaObligatoria CHAR(1), pMontoMinDisp DECIMAL(18,2), pMontoMaxDisp DECIMAL(18,2))
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS cNumProducto,
				DECIMAL(18,2) AS dMontoMinCred,
				DECIMAL(18,2) AS dMontoMaxCred,
				INTEGER AS iEdadMin,
				INTEGER AS iEdadMax,
				INTEGER AS iPlazoMinCred,
				INTEGER AS iPlazoMaxCred,
				SMALLINT AS iIdFrecPago,
				CHAR(1) AS cCobroComisionAnual,
				SMALLINT AS iComiGastoCobranza,
				CHAR(1) AS cCobroComisApertura,
				SMALLINT AS iComiDisposicionEfect,
				SMALLINT AS iComiAclaracionNo,
				SMALLINT AS iComiLiquidacionAntic,
				CHAR(4) AS cCodComisionApertura,
				CHAR(4) AS cCodComiGastoCobranza,
				CHAR(8) AS cCodComisionAnualidad,
				CHAR(4) AS cCodComiDisposicionEfect,
				CHAR(4) AS cCodComiAclaracionNo,
				CHAR(4) AS cCodComiLiquidacionAntic,
				SMALLINT AS iGarantias,
				SMALLINT AS iIdGarantia,
				DECIMAL(16) AS dPorcentajeAforo,
				CHAR(1) AS cObligadoSolidario,
				CHAR(1) AS cNumObligados,
				CHAR(1) AS cCapturaObligatoria,
				DECIMAL(18,2) AS dMontoMinDisp,
				DECIMAL(18,2) AS dMontoMaxDisp;
		
	DEFINE cCodRet 				 	CHAR(5);
	DEFINE iSqlErr 				 	INTEGER;
	DEFINE cCodRetSp 			 	CHAR(5);
	DEFINE iCodRetSp 			 	INTEGER;
	DEFINE cEmpresa              	CHAR(3);
	DEFINE cNumProducto             CHAR(4);
	DEFINE dMontoMinCred            DECIMAL(18,2);
	DEFINE dMontoMaxCred            DECIMAL(18,2);
	DEFINE iEdadMin                 INTEGER;
	DEFINE iEdadMax                 INTEGER;
	DEFINE iPlazoMinCred            INTEGER;
	DEFINE iPlazoMaxCred            INTEGER;
	DEFINE iIdFrecPago              SMALLINT;
	DEFINE cCobroComisionAnual      CHAR(1);
	DEFINE iComiGastoCobranza       SMALLINT;
	DEFINE cCobroComisApertura      CHAR(1);
	DEFINE iComiDisposicionEfect    SMALLINT;
	DEFINE iComiAclaracionNo        SMALLINT;
	DEFINE iComiLiquidacionAntic    SMALLINT;
	DEFINE cCodComisionApertura     CHAR(4);
	DEFINE cCodComiGastoCobranza   	CHAR(4);
	DEFINE cCodComisionAnualidad    CHAR(8);
	DEFINE cCodComiDisposicionEfect CHAR(4);
	DEFINE cCodComiAclaracionNo    	CHAR(4);
	DEFINE cCodComiLiquidacionAntic	CHAR(4);
	DEFINE iGarantias               SMALLINT;
	DEFINE iIdGarantia              SMALLINT;
	DEFINE dPorcentajeAforo         DECIMAL(16);
	DEFINE cObligadoSolidario       CHAR(1);
	DEFINE cNumObligados            CHAR(1);
	DEFINE cCapturaObligatoria      CHAR(1);
	DEFINE dMontoMinDisp            DECIMAL(18,2);
	DEFINE dMontoMaxDisp            DECIMAL(18,2);
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cEmpresa 					= '001';
	LET cNumProducto             	= '';
	LET dMontoMinCred           	= 0.0;
	LET dMontoMaxCred            	= 0.0;
	LET iEdadMin                 	= 0;
	LET iEdadMax                 	= 0;
	LET iPlazoMinCred            	= 0;
	LET iPlazoMaxCred            	= 0;
	LET iIdFrecPago              	= 0;
	LET cCobroComisionAnual      	= '';
	LET iComiGastoCobranza       	= 0;
	LET cCobroComisApertura      	= '';
	LET iComiDisposicionEfect    	= 0;
	LET iComiAclaracionNo        	= 0;
	LET iComiLiquidacionAntic    	= 0;
	LET cCodComisionApertura     	= '';
	LET cCodComiGastoCobranza   	= '';
	LET cCodComisionAnualidad    	= '';
	LET cCodComiDisposicionEfect 	= '';
	LET cCodComiAclaracionNo    	= '';
	LET cCodComiLiquidacionAntic	= '';
	LET iGarantias               	= 0;
	LET iIdGarantia              	= 0;
	LET dPorcentajeAforo         	= 0.0;
	LET cObligadoSolidario       	= '';
	LET cNumObligados            	= '';
	LET cCapturaObligatoria      	= '';
	LET dMontoMinDisp           	= 0.0;
	LET dMontoMaxDisp            	= 0.0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_caracteristicasproductos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pBandera = '1' THEN -- INSERTA
			DELETE FROM bdicred:"informix".tmp_sd_definicion WHERE usuario_insert = pUsuario;
			
			INSERT INTO bdicred:"informix".tmp_sd_definicion(empresa, num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, comi_aclaracion_no, comi_liquidacion_antic, 
				cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, monto_min_disp, monto_max_disp, usuario_insert) 
			VALUES(cEmpresa, pNumProducto, pMontoMinCred, pMontoMaxCred, pEdadMin, pEdadMax, pPlazoMinCred, pPlazoMaxCred, pIdFrecPago, pCobroComisionAnual, pComiGastoCobranza, pCobroComisApertura, pComiDisposicionEfect, pComiAclaracionNo, pComiLiquidacionAntic, 
				pCodComisionApertura, pCodComiGastoCobranza, pCodComisionAnualidad, pCodComiDisposicionEfect, pCodComiAclaracionNo, pCodComiLiquidacionAntic, pGarantias, pIdGarantia, pPorcentajeAforo, pObligadoSolidario, pNumObligados, pCapturaObligatoria, pMontoMinDisp, pMontoMaxDisp, pUsuario);
			
		ELIF pBandera = '2' THEN -- ACTUALIZA

			UPDATE bdicred:"informix".tmp_sd_definicion SET
			monto_min_cred = pMontoMinCred, 
			monto_max_cred = pMontoMaxCred, 
			edad_min = pEdadMin, 
			edad_max = pEdadMax, 
			plazo_min_cred = pPlazoMinCred, 
			plazo_max_cred = pPlazoMaxCred, 
			id_frec_pago = pIdFrecPago, 
			cobro_comision_anual = pCobroComisionAnual, 
			comi_gasto_cobranza = pComiGastoCobranza, 
			cobro_comis_apertura = pCobroComisApertura, 
			comi_disposicion_efect = pComiDisposicionEfect, 
			comi_aclaracion_no = pComiAclaracionNo, 
			comi_liquidacion_antic = pComiLiquidacionAntic, 
			cod_comision_apertura = pCodComisionApertura, 
			cod_comi_gasto_cobranza = pCodComiGastoCobranza, 
			cod_comision_anualidad = pCodComisionAnualidad, 
			cod_comi_disposicion_efect = pCodComiDisposicionEfect, 
			cod_comi_aclaracion_no = pCodComiAclaracionNo, 
			cod_comi_liquidacion_antic = pCodComiLiquidacionAntic, 
			garantias = pGarantias, 
			idgarantia = pIdGarantia, 
			porcentajeaforo = pPorcentajeAforo, 
			obligado_solidario = pObligadoSolidario, 
			num_obligados = pNumObligados, 
			captura_obligatoria = pCapturaObligatoria,
			monto_min_disp = pMontoMinDisp, 
			monto_max_disp = pMontoMaxDisp
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;

		
		ElIF pBandera = '3' THEN -- ELIMINA
		
			DELETE FROM bdicred:"informix".tmp_sd_definicion 
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;
		
		ElIF pBandera = '4' THEN -- CONSULTA
		
			SELECT num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, 
				comi_aclaracion_no, comi_liquidacion_antic, cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, 
				idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, monto_min_disp, monto_max_disp
			INTO cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, 
				iComiAclaracionNo, iComiLiquidacionAntic, cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, 
				iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp
			FROM bdicred:"informix".tmp_sd_definicion 
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;
		
		ElIF pBandera = '5' THEN -- ALMACENA
			SELECT num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, 
				comi_aclaracion_no, comi_liquidacion_antic, cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, 
				idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria
			INTO cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, 
				iComiAclaracionNo, iComiLiquidacionAntic, cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, 
				iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria
			FROM bdicred:"informix".tmp_sd_definicion 
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;
			
			INSERT INTO bdicred:"informix".sd_definicion(empresa, num_producto, cod_tipcred, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, comi_aclaracion_no, comi_liquidacion_antic, 
				cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria) 
			VALUES(cEmpresa, cNumProducto, '', dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic, 
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria);
		
		END IF;
		

		RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los productos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultabuscproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pNomProducto CHAR(40))
		RETURNING CHAR(5) AS codret,
				CHAR(4)  		AS Num_Producto, --NÃÂ° Producto
				CHAR(40) 		AS Nomb_Producto, --Nombre del Producto
				INTEGER	 	AS Id_subproducto, --Retorna el id del subproducto
				VARCHAR(40) 	AS pDesc_subproducto; --Nombre del Subproducto
		
	DEFINE cCodRet 				 	CHAR(5);
	DEFINE iSqlErr 				 	INTEGER;
	DEFINE cCodRetSp 			 	CHAR(5);
	DEFINE iCodRetSp 			 	INTEGER;
	DEFINE cEmpresa              	CHAR(3);
	DEFINE cNumProducto    	 		CHAR(4);
    DEFINE cNomProducto   	 		CHAR(40);
	DEFINE cNumSubProducto    	 	INTEGER;
    DEFINE cNomSubproducto   	 	CHAR(40);
	
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cEmpresa 					= '001';
	LET cNumProducto             	= '';
	LET cNomProducto   	 			= '';
	LET cNumSubProducto    	 		= 0;
    LET cNomSubproducto   	 		= '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultabuscproductos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pNumProducto = '' AND pNomProducto = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pNomProducto <> '' THEN 
		 
		 LET pNomProducto = '%'||TRIM(pNomProducto)||'%';
		 
			FOREACH
			
				SELECT num_producto, nombre_prod, id_subproducto, desc_subproducto 
				INTO cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto 
				FROM (SELECT num_producto, nombre_prod, 0 AS id_subproducto, '' AS desc_subproducto
				FROM bdicred:"informix".sd_definicion 
				WHERE empresa = cEmpresa AND nombre_prod LIKE pNomProducto
				UNION
				SELECT A.num_producto, A.nombre_prod, B.id_subproducto, B.desc_subproducto 
				FROM bdicred:"informix".sd_definicion AS A
				INNER JOIN bdicred:"informix".sd_subproducto AS B on A.empresa = B.empresa AND A.num_producto = B.num_producto 
				WHERE A.empresa = cEmpresa AND A.nombre_prod LIKE pNomProducto)
				ORDER BY 1,2,3 ASC

				RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto WITH RESUME;
			
			END FOREACH;
		ELSE
		FOREACH
			
			SELECT num_producto, nombre_prod, id_subproducto, desc_subproducto 
			INTO cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto 
			FROM (SELECT num_producto, nombre_prod, 0 AS id_subproducto, '' AS desc_subproducto
			FROM bdicred:"informix".sd_definicion 
			WHERE empresa = cEmpresa AND num_producto = pNumProducto
			UNION
			SELECT A.num_producto, A.nombre_prod, B.id_subproducto, B.desc_subproducto 
			FROM bdicred:"informix".sd_definicion AS A
			INNER JOIN bdicred:"informix".sd_subproducto AS B on A.empresa = B.empresa AND A.num_producto = B.num_producto 
			WHERE A.empresa = cEmpresa AND A.num_producto = pNumProducto) 
			ORDER BY 1,2,3 ASC

			RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto WITH RESUME;
			
		END FOREACH;
		
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumProducto, cNomProducto, cNumSubProducto, cNomSubproducto;
		END IF;
		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar la busqueda de los productos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaplantillamnsj(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera SMALLINT, pIdEvento SMALLINT)
		RETURNING CHAR(5) AS codret,
				SMALLINT AS cod_plantilla,
				CHAR(50) AS cod_msm_mail,
				CHAR(20) AS tipo_plantilla,
				CHAR(10000) AS msj_plantilla;
		
	DEFINE cCodRet 				 	CHAR(5);
	DEFINE iSqlErr 				 	INTEGER;
	DEFINE cCodRetSp 			 	CHAR(5);
	DEFINE iCodRetSp 			 	INTEGER;
	DEFINE cEmpresa              	CHAR(3);
	DEFINE iCodPlantilla    	 	SMALLINT;
    DEFINE cCodMsmMail   	 		CHAR(50);
	DEFINE cTipoPlantilla    	 	CHAR(20);
    DEFINE cMsjPlantilla   	 		CHAR(10000);
	DEFINE v_ya_existe 			    SMALLINT;
	
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cEmpresa 					= '001';
	LET iCodPlantilla    	 		= 0;
    LET cCodMsmMail   	 			= '';
	LET cTipoPlantilla    	 		= '';
    LET cMsjPlantilla   	 		= '';
	LET v_ya_existe			 	= 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaplantillamnsj.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera IS NULL AND pIdEvento IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pBandera = 1 THEN --BANDERA PARA SMS
		
			SELECT COUNT(*)
			INTO   v_ya_existe
			FROM bdicred:"informix".sd_tipo_plantilla 
			WHERE band_msj = pBandera AND id_evento = pIdEvento;
			
			IF v_ya_existe > 0 THEN
				SELECT cod_plantilla, cod_msm_mail, tipo_plantilla, msj_plantilla 
				INTO iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla
				FROM bdicred:"informix".sd_tipo_plantilla 
				WHERE band_msj = pBandera AND id_evento = pIdEvento;
				
				RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
			ELSE 
				LET cCodRet = '00017';
				RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
			END IF;
		ELSE--BANDERA PARA EMAIL
		
			SELECT COUNT(*)
			INTO   v_ya_existe
			FROM bdicred:"informix".sd_tipo_plantilla 
			WHERE band_email = pBandera AND id_evento = pIdEvento;
			
			IF v_ya_existe > 0 THEN
				SELECT cod_plantilla, cod_msm_mail, tipo_plantilla, msj_plantilla 
				INTO iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla
				FROM bdicred:"informix".sd_tipo_plantilla 
				WHERE band_email = pBandera AND id_evento = pIdEvento;
				
				RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
			ELSE 
				LET cCodRet = '00017';
				RETURN cCodRet, iCodPlantilla, cCodMsmMail, cTipoPlantilla, cMsjPlantilla;
			END IF;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar las planillas de los mensajes',
'ModificaciÃ³n: Juan RomÃ¡n VelÃ¡zquez Toledo',
'FECHA: 12/10/2020',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consultaconvproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(2) 	AS Sistema,
				CHAR(4) 	AS Num_producto,
				CHAR(40) 	AS Nombre_producto;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cNum_producto		CHAR(4);
	DEFINE cNombre_producto		CHAR(40);
	DEFINE cSistema     		CHAR(2);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cNum_producto			= '';
	LET cNombre_producto		= '';
	LET cSistema				= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cNum_producto, cNombre_producto;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultaconvproductos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pProducto = '' OR pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cNum_producto, cNombre_producto;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistema, cNum_producto, cNombre_producto;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_conv_productos(pProducto, pTipoEjecucion)
			INTO cCodRetSp, cSistema, cNum_producto, cNombre_producto

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consulta_conv_productos";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cSistema, cNum_producto, cNombre_producto;
			END IF;

			RETURN cCodRet, cSistema, cNum_producto, cNombre_producto WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_grabapoliticacreditoprod(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pRespuestaSic CHAR(1),pGrupo CHAR(1), pBcScoremin INTEGER, pBcScoremax INTEGER, pProScormin INTEGER, pProScormax INTEGER, pStatusSol CHAR(2))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_cred_grabapoliticacreditoprod.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR NVL(pNumProducto,'') = '' OR NVL(pRespuestaSic,'') = '' OR NVL(pGrupo,'') = '' OR NVL(pBcScoremin,'') = '' 
			OR NVL(pBcScoremax,'') = '' OR NVL(pProScormin,'') = '' OR NVL(pProScormax,'') = '' OR NVL(pStatusSol,'') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_graba_politicacreditoprod(pNumProducto, pRespuestaSic, pGrupo, pBcScoremin, pBcScoremax, pProScormin, pProScormax, pStatusSol)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_graba_politicacreditoprod";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de grabar las politicas de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtenctasmedioacceso(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoEjecucion CHAR(1), pNumProducto CHAR(4), pNumProdCapt CHAR(4))
		RETURNING CHAR(5) AS codret,
				CHAR(4)  AS Numero_Producto,
				CHAR(40) AS Nomb_Producto,
				CHAR(3)  AS Empresa;

	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cEmpresa         	 CHAR(3);
	DEFINE cEmpresaSp         	 CHAR(3);
	DEFINE cNum_Producto    	 CHAR(4);
    DEFINE cNomb_Producto   	 CHAR(40);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa 				= '001';
	LET cEmpresaSp 				= '';
	LET cNum_Producto 			= '';
	LET cNomb_Producto 			= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtenctasmedioacceso.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_obtenctasmedioacceso(cEmpresa, pTipoEjecucion, pNumProducto, pNumProdCapt)
			INTO cCodRetSp, cEmpresaSp, cNum_Producto, cNomb_Producto

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtenctasmedioacceso";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp;
			END IF;

			RETURN cCodRet, cNum_Producto, cNomb_Producto, cEmpresaSp WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de garantia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_elimina_tmp(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS CodRet;

	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	
	LET cCodRet 				= '00000';
	LET cCodRetSp 				= '';
	LET iSqlErr 				= 0;
	LET iCodRetSp 				= 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_elimina_tmp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_eliminatemp()	
			INTO cCodRetSp;
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_eliminatemp";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet;
			END IF;
			
			RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT 'AUTOR: Juan RomÃ¡n VelÃ¡zquez Toledo',
'FECHA: 12/10/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de eliminar informaciÃ³n de las tablas temporales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaconssubproductos(pUsuario CHAR(10),pIdFuncion CHAR(10), pProducto CHAR(4))
      RETURNING CHAR(5) AS codRet,
				INTEGER AS consecutivo;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cEmpresa 			CHAR(3);
	DEFINE iConsecutivo			INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cEmpresa 				= '001';
	LET iConsecutivo			= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iConsecutivo;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaconssubproductos.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, iConsecutivo;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet, iConsecutivo;
        END IF;

		SELECT MAX(id_subproducto)
		INTO iConsecutivo
		FROM bdicred:"informix".sd_subproducto;
				
		LET iConsecutivo = (nvl(iConsecutivo, 0)::INTEGER) + 1;
				
		RETURN cCodRet, iConsecutivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 19/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Alta Subproductos',
'DESCRIPCION: SPL encargado de consultar el consecutivo de subproducto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_faltsob(pUsuario CHAR(8), pIdFuncion CHAR(10), pcodigo_proveedor CHAR(4), pcajeroprincipal CHAR(8), pfolio_suc CHAR(16), ptransaccion CHAR(4), pdivisa CHAR(2), pmonto MONEY(14,2), pfecha DATE,
				pdeno1 CHAR(18), pdeno2 CHAR(18), pdeno3 CHAR(18), pdeno4 CHAR(18), pdeno5 CHAR(18), pdeno6 CHAR(18), pdeno7 CHAR(18), pdeno8 CHAR(18), pdeno9 CHAR(18), pdeno10 CHAR(18), pdeno11 CHAR(18), pdeno12 CHAR(18), pdeno13 CHAR(18), pdeno14 CHAR(18), pdeno15 CHAR(18), 
				pcant1 FLOAT(8), pcant2 FLOAT(8), pcant3 FLOAT(8), pcant4 FLOAT(8), pcant5 FLOAT(8), pcant6 FLOAT(8), pcant7 FLOAT(8), pcant8 FLOAT(8), pcant9 FLOAT(8), pcant10 FLOAT(8), pcant11 FLOAT(8), pcant12 FLOAT(8), pcant13 FLOAT(8), pcant14 FLOAT(8), pcant15 FLOAT(8))
		RETURNING CHAR(5) AS codret,
				VARCHAR(8) AS folio;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cEmpresa  		 	 CHAR(20);
	DEFINE cfolio 				 CHAR(8);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa   				= '001';
	LET cfolio  				= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cfolio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_faltsob.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cfolio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cfolio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisuc:"informix".sp_faltsob_cg(cEmpresa, pcodigo_proveedor, pcajeroprincipal, pfolio_suc, ptransaccion, pdivisa, pmonto, pfecha,
				pdeno1, pdeno2, pdeno3, pdeno4, pdeno5, pdeno6, pdeno7, pdeno8, pdeno9, pdeno10, pdeno11, pdeno12, pdeno13, pdeno14, pdeno15, 
				pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10, pcant11, pcant12, pcant13, pcant14, pcant15)
		INTO cCodRetSp, cfolio;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_faltsob_cg";
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cfolio;
		ELIF iCodRetSp = 105 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cfolio;
		ELIF iCodRetSp = 106 THEN
			LET cCodRet = '99999';
			RETURN cCodRet, cfolio;
		END IF;
			
			RETURN cCodRet, cfolio;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 10/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Faltante Sobrente Caja General',
'DESCRIPCION: SPL encargado de insertr la poliza',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_genreportedepositoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoEjecucion CHAR(1), pInicio DATE, pFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
					CHAR(70) AS sucursal,
					CHAR(8) AS usuario,
					CHAR(50) AS nombre,
					DATE AS fechaOperacion,
					CHAR(8) AS folioOper,
					CHAR(50) AS descripcion,
					MONEY(14,2) AS monto_Tot,
					INTEGER AS denominacion1,
					INTEGER AS denominacion2,
					INTEGER AS denominacion3,
					INTEGER AS denominacion4,
					INTEGER AS denominacion5,
					INTEGER AS denominacion6,
					INTEGER AS denominacion7,
					CHAR(70) AS cajagen,
					CHAR(10) AS comprobante,
					MONEY(14,2) AS importeComp,
					MONEY(14,2) AS faltante,
					MONEY(14,2) AS sobrante;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE cSucursal			 CHAR(70); 
	DEFINE cUsuario				 CHAR(8);
	DEFINE cNombre				 CHAR(50); 
	DEFINE dFechaOperacion		 DATE;
	DEFINE cFolioOper			 CHAR(8);		 
	DEFINE cDescripcion			 CHAR(50);
	DEFINE mMonto_Tot			 MONEY(14,2);
	DEFINE mDenominacion1		 INTEGER;
	DEFINE mDenominacion2		 INTEGER;
	DEFINE mDenominacion3		 INTEGER; 
	DEFINE mDenominacion4		 INTEGER; 
	DEFINE mDenominacion5		 INTEGER; 
	DEFINE mDenominacion6		 INTEGER; 
	DEFINE mDenominacion7		 INTEGER;
	DEFINE cCajagen				 CHAR(70); 
	DEFINE cComprobante			 CHAR(10);
	DEFINE mImporteComp			 MONEY(14,2);
	DEFINE mFaltante			 MONEY(14,2);
	DEFINE mSobrante			 MONEY(14,2);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa 				= '001';
	LET iRecuperacion 			= 0;
	LET cSucursal			 	= '';
	LET cUsuario				= '';
	LET cNombre				 	= '';
	LET dFechaOperacion		 	= DATE(1);
	LET cFolioOper			 	= '';
	LET cDescripcion			= '';
	LET mMonto_Tot			 	= 0;
	LET mDenominacion1		 	= 0;
	LET mDenominacion2		 	= 0;
	LET mDenominacion3		 	= 0; 
	LET mDenominacion4		 	= 0; 
	LET mDenominacion5		 	= 0; 
	LET mDenominacion6		 	= 0; 
	LET mDenominacion7		 	= 0;
	LET cCajagen				= '';
	LET cComprobante			= '';
	LET mImporteComp			= 0;
	LET mFaltante			 	= 0;
	LET mSobrante			 	= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_genreportedepositoscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' OR pInicio IS NULL OR pFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN
		
			FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion ((A.sucursal || " " )|| C.descripcion) AS sucursal, A.usuario, B.nombre, A.fecha_operacion, A.folio_oper, A.cod_trans || " " || D.descripcion AS descripcion, A.monto, A.cantidad_1, A.cantidad_2, A.cantidad_3, A.cantidad_4, A.cantidad_5, A.cantidad_6, A.cantidad_7 
					INTO cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7
					FROM bdisuc:"informix".ss_operaciones AS A
					INNER JOIN bdinteg:"informix".si_ejecut AS B ON A.empresa = B.empresa AND A.usuario = B.ejecutivo
					INNER JOIN bdisuc:"informix".ss_proveedores AS C ON C.cod_proveedor = A.sucursal
					INNER JOIN bdisuc:"informix".ss_param_cajagen AS D ON A.empresa = D.empresa AND D.codigo = A.cod_trans
					WHERE A.empresa = cEmpresa AND A.cod_trans IN ('0070','0071') AND A.fecha_operacion >= pInicio AND A.fecha_operacion <= pFin
					
					LET iRecuperacion = iRecuperacion + 1;
	
					RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante WITH RESUME;
					
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			
			FOREACH
					SELECT {+AVOID_FULL(bdisuc:"informix".ss_bitacora_deposito_coppel)} SKIP pRegistros FIRST pRecuperacion A.caja_general || " " || C.descripcion AS sucursal, A.usuario, A.nombre, B.fecha_operacion, B.folio_oper, A.comprobante, A.suc_coppel, A.imp_comprobante, B.monto, B.cantidad_1, B.cantidad_2, B.cantidad_3, B.cantidad_4, B.cantidad_5, B.cantidad_6, B.cantidad_7, A.faltante, A.sobrante
					INTO cCajagen, cUsuario, cNombre, dFechaOperacion, cFolioOper, cComprobante, cSucursal, mImporteComp, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, mFaltante, mSobrante
					FROM bdisuc:"informix".ss_bitacora_deposito_coppel AS A
					INNER JOIN bdisuc:"informix".ss_operaciones AS B ON A.empresa = B.empresa AND A.folio_oper = B.folio_oper AND A.caja_general = B.sucursal AND A.usuario = B.usuario
					INNER JOIN bdisuc:"informix".ss_proveedores AS C ON C.cod_proveedor = A.caja_general
					AND A.empresa = cEmpresa AND B.cod_trans = '0072' AND A.fecha >= pInicio AND A.fecha <= pFin
					
					LET iRecuperacion = iRecuperacion + 1;
	
					RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante WITH RESUME;
					
			END FOREACH;
		END IF;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		ELIF (iRecuperacion = 0 OR iRecuperacion > 0) AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cSucursal, cUsuario, cNombre, dFechaOperacion, cFolioOper, cDescripcion, mMonto_Tot, mDenominacion1, mDenominacion2, mDenominacion3, mDenominacion4, mDenominacion5, mDenominacion6, mDenominacion7, cCajagen, cComprobante, mImporteComp, mFaltante, mSobrante;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 12/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Depositos Coppel',
'DESCRIPCION: SPL encargado de generar el reporte de bitacoras',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_grabadepositoscoppel(pUsuario CHAR(10),pIdFuncion CHAR(10), pHora CHAR(5))
      RETURNING CHAR(5) AS codRet;

	DEFINE cCodRet 				CHAR(5);
	DEFINE cClave_transaccion 	CHAR(4);
	DEFINE cDesc_transaccion 	CHAR(50);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cEmpresa 			CHAR(3);
	DEFINE iRecuperacion 		INTEGER;
	DEFINE dFecha				DATE;
	DEFINE cComprobante			CHAR(10);
	DEFINE cSucCoppel			CHAR(10);
	DEFINE cNombreEmp			CHAR(80);
	DEFINE cNombreSuc			CHAR(40);
	DEFINE cCajaGeneral			CHAR(4);
	DEFINE cPlaza				CHAR(20);
	DEFINE mImpComprobante		MONEY(14,2);
	DEFINE mImpFicha			MONEY(14,2);
	DEFINE iCantidad1			INTEGER;
	DEFINE iCantidad2			INTEGER;
	DEFINE iCantidad3			INTEGER;
	DEFINE iCantidad4			INTEGER;
	DEFINE iCantidad5			INTEGER;
	DEFINE iCantidad6			INTEGER;
	DEFINE iCantidad7			MONEY(14,2);
	DEFINE mFaltante			MONEY(14,2);
	DEFINE mSobrante			MONEY(14,2);
	DEFINE iTotReg				INTEGER;
	DEFINE cMensaje				CHAR(60);
	DEFINE cFolioOper			CHAR(8);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cEmpresa 				= '001';
	LET cClave_transaccion 		= '';
	LET cDesc_transaccion 		= '';
	LET iRecuperacion 			= 0;
	LET dFecha					= DATE(1);
	LET cComprobante			= '';
	LET cSucCoppel				= '';
	LET cNombreSuc				= '';
	LET cNombreEmp				= '';
	LET cCajaGeneral			= '';
	LET cPlaza					= '';
	LET mImpComprobante			= 0;
	LET mImpFicha				= 0;
	LET iCantidad1				= 0;
	LET iCantidad2				= 0;
	LET iCantidad3				= 0;
	LET iCantidad4				= 0;
	LET iCantidad5				= 0;
	LET iCantidad6				= 0;
	LET iCantidad7				= 0;
	LET mFaltante				= 0;
	LET mSobrante				= 0;
	LET iTotReg					= 0;
	LET cFolioOper				= '';
	LET cMensaje				= '';
	LET iRecuperacion 			= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_grabadepositoscoppel.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' OR pHora = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet;
        END IF;

        FOREACH
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_temp_deposito_coppel)} folio_oper, fecha, comprobante, suc_coppel, nombre_suc, caja_general, plaza, imp_comprobante, imp_ficha, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, faltante, sobrante
                INTO cFolioOper, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante
                FROM bdisuc:"informix".ss_temp_deposito_coppel 
				
				INSERT INTO bdisuc:"informix".ss_operaciones(empresa, cod_trans, fecha_operacion, sucursal, folio_sucursal, folio_oper, reversado, usuario, divisa, monto, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6, denominacion_7, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7) 
				VALUES(cEmpresa, '0072', CURRENT, cCajaGeneral, pUsuario || cFolioOper, cFolioOper, '0', pUsuario, '01', mImpFicha, '1000', '500', '200', '100', '50', '20', '-1', iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7);

				INSERT INTO bdisuc:"informix".ss_mae_entradasalida(empresa, cod_proveedor, folio_oper, sucursal, folio_sucursal, fecha_envio, hora_envio, usuario_envio, status, monto) 
				VALUES(cEmpresa, cCajaGeneral, cFolioOper, '9765', pUsuario || cFolioOper, CURRENT, pHora , pUsuario, '04', mImpFicha);

				UPDATE bdisuc:"informix".ss_cajageneral 
				SET cantidad_1 = cantidad_1 + iCantidad1,
				cantidad_2 = cantidad_2 + iCantidad2,
				cantidad_3 = cantidad_3 + iCantidad3,
				cantidad_4 = cantidad_4 + iCantidad4,
				cantidad_5 = cantidad_5 + iCantidad5,
				cantidad_6 = cantidad_6 + iCantidad6,
				cantidad_7 = cantidad_7 + iCantidad7,
				saldo_total =  saldo_total + mImpFicha
				WHERE  cod_proveedor = cCajaGeneral; 
				
				
				SELECT nombre 
				INTO cNombreEmp
				FROM bdinteg:"informix".si_ejecut 
				WHERE ejecutivo = pUsuario;
				
				INSERT INTO  bdisuc:"informix".ss_bitacora_deposito_coppel(empresa, caja_general, plaza, usuario, nombre, fecha, folio_oper, comprobante, suc_coppel, nombre_suc, imp_comprobante, imp_ficha, faltante, sobrante) 
				VALUES(cEmpresa, cCajaGeneral, cPlaza, pUsuario, cNombreEmp, CURRENT, cFolioOper, cComprobante, cSucCoppel, cNombreSuc, mImpComprobante, mImpFicha, mFaltante, mSobrante);

        END FOREACH;
		
		RETURN cCodRet;
				
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 10/09/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de grabar los depositos coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_polizafaltsob(pUsuario CHAR(8), pIdFuncion CHAR(10), vfolio_oper CHAR(8))
     RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	
	DEFINE wfecha_hoy DATE;
	DEFINE wtesoreria 					CHAR(4);
	DEFINE pempresa   CHAR(3);
	DEFINE vtranenvio                    CHAR(4);
	DEFINE wsucursal                     CHAR(4);
	DEFINE wdivisa 						CHAR(2);
	DEFINE wprocedencia					CHAR(4);
	DEFINE vnaturaleza                   CHAR(1);
	DEFINE vtipo_tran                    CHAR(2);
	DEFINE wmonto                        MONEY(14,2);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultatgarantia.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR vfolio_oper = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		--EXECUTE PROCEDURE bdisuc:"informix".sp_poliza_faltsob(vfolio_oper)
		--INTO cCodRetSp;
		
		SELECT fecha_hoy
		INTO wfecha_hoy
		FROM bdinteg:"informix".si_fechas;

	   	SELECT empresa,cod_trans,sucursal,divisa,sucursal,monto
         INTO pempresa,vtranenvio,wsucursal,wdivisa,wprocedencia,wmonto
         FROM bdisuc:"informix".ss_operaciones 
        WHERE cod_trans IN ("0070","0071")
	      AND fecha_operacion = wfecha_hoy
          AND reversado NOT IN ('1','SI','si')
          AND monto > 0
          AND folio_oper = vfolio_oper;
		  
		SELECT valor INTO wtesoreria
		FROM   ss_param_cajagen
		WHERE  codigo = "0034" AND empresa=pempresa;
		
		SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
             FROM   bdinteg:si_transacc
             WHERE  sistema='02' AND se_contabiliza='S' 
             AND    empresa = pempresa AND numero = vtranenvio;
		
		EXECUTE PROCEDURE bdisuc:"informix". sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
                             wprocedencia,vnaturaleza,wmonto,vtipo_tran) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_poliza_faltsob";
		END IF;
			
		RETURN cCodRet;
			

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de garantia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadepositoscoppel(pUsuario CHAR(10),pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
      RETURNING CHAR(5) AS codRet,
                DATE AS dFecha,
				CHAR(10) AS cComprobante,
				CHAR(10) AS cSucCoppel,
				CHAR(40) AS cNombreSuc,
				CHAR(4) AS cCajaGeneral,
				CHAR(20) AS cPlaza,
				MONEY(14,2) AS mImpComprobante,
				MONEY(14,2) AS mImpFicha,
				INTEGER AS iCantidad1,
				INTEGER AS iCantidad2,
				INTEGER AS iCantidad3,
				INTEGER AS iCantidad4,
				INTEGER AS iCantidad5,
				INTEGER AS iCantidad6,
				MONEY(14,2) AS iCantidad7,
				MONEY(14,2) AS mFaltante,
				MONEY(14,2) AS mSobrante;

	DEFINE cCodRet 				CHAR(5);
	DEFINE cClave_transaccion 	CHAR(4);
	DEFINE cDesc_transaccion 	CHAR(50);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cEmpresa 			CHAR(3);
	DEFINE iRecuperacion 		INTEGER;
	DEFINE dFecha				DATE;
	DEFINE cComprobante			CHAR(10);
	DEFINE cSucCoppel			CHAR(10);
	DEFINE cNombreSuc			CHAR(40);
	DEFINE cCajaGeneral			CHAR(4);
	DEFINE cPlaza				CHAR(20);
	DEFINE mImpComprobante		MONEY(14,2);
	DEFINE mImpFicha			MONEY(14,2);
	DEFINE iCantidad1			INTEGER;
	DEFINE iCantidad2			INTEGER;
	DEFINE iCantidad3			INTEGER;
	DEFINE iCantidad4			INTEGER;
	DEFINE iCantidad5			INTEGER;
	DEFINE iCantidad6			INTEGER;
	DEFINE iCantidad7			MONEY(14,2);
	DEFINE mFaltante			MONEY(14,2);
	DEFINE mSobrante			MONEY(14,2);
	DEFINE iTotReg				INTEGER;
	DEFINE cMensaje				CHAR(60);
	DEFINE iConsecutivo			INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cEmpresa 				= '001';
	LET cClave_transaccion 		= '';
	LET cDesc_transaccion 		= '';
	LET iRecuperacion 			= 0;
	LET dFecha					= DATE(1);
	LET cComprobante			= '';
	LET cSucCoppel				= '';
	LET cNombreSuc				= '';
	LET cCajaGeneral			= '';
	LET cPlaza					= '';
	LET mImpComprobante			= 0;
	LET mImpFicha				= 0;
	LET iCantidad1				= 0;
	LET iCantidad2				= 0;
	LET iCantidad3				= 0;
	LET iCantidad4				= 0;
	LET iCantidad5				= 0;
	LET iCantidad6				= 0;
	LET iCantidad7				= 0;
	LET mFaltante				= 0;
	LET mSobrante				= 0;
	LET iTotReg					= 0;
	LET iConsecutivo			= 0;
	LET cMensaje				= '';
	LET iRecuperacion 			= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadepositoscoppel.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
        END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN  cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
		END IF;
		
        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet,	dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
        END IF;

        FOREACH
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_temp_deposito_coppel)} SKIP pRegistros FIRST pRecuperacion fecha, comprobante, suc_coppel, nombre_suc, caja_general, plaza, imp_comprobante, imp_ficha, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, faltante, sobrante
                INTO dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante
                FROM bdisuc:"informix".ss_temp_deposito_coppel 
				
				LET iRecuperacion = iRecuperacion + 1;

                RETURN cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante WITH RESUME;
				
        END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
		ELIF (iRecuperacion = 0 OR iRecuperacion > 0) AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 10/09/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de obtener los registros de los depositos coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatotalesdepositoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10))
      RETURNING CHAR(5) AS codRet,
                MONEY(14,2) AS total_ficha,
				INTEGER AS no_registro;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cEmpresa 	CHAR(3);
	DEFINE mImpFicha	MONEY(14,2);
	DEFINE iTotReg		INTEGER;
	
	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;
	LET cEmpresa 	= '001';
	LET mImpFicha	= 0;
	LET iTotReg		= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, mImpFicha, iTotReg;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotalesdepositoscoppel.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, mImpFicha, iTotReg;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet, mImpFicha, iTotReg;
        END IF;

				
		SELECT {+AVOID_FULL(bdisuc:"informix".ss_temp_deposito_coppel)} COUNT(*) 
		INTO iTotReg 
		FROM bdisuc:"informix".ss_temp_deposito_coppel; 
		
		
		SELECT {+AVOID_FULL(bdisuc:"informix".ss_temp_deposito_coppel)} SUM(imp_ficha) 
		INTO mImpFicha
		FROM bdisuc:"informix".ss_temp_deposito_coppel; 
		

		RETURN cCodRet, mImpFicha, iTotReg;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 10/09/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de obtener los totales de los depositos coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusdotacioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS totales;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError, iTotalReg;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusdotacioncaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError, iTotalReg;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso, cError, iTotalReg;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, error_proceso, error, totalRegistros
		INTO cStatus, cErrorProceso, cError, iTotalReg
		FROM "informix".sw_verificastatusdotacioncaja WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',0; 
		ELSE 			
			RETURN cCodRet, cStatus, cErrorProceso, cError, iTotalReg;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 13/10/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ENVIO DOTACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado verificar el status dotacion caja.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfarchivodotacaja (pUsuario      CHAR(8),
															pIdFuncion    CHAR(10),
															pTipoSucursal CHAR(2),
															pIdSucursal   CHAR(4),
															pIdProvCaja   CHAR(4),
															pRegistros    INTEGER,
															pRecuperacion INTEGER)

	RETURNING CHAR(5) AS codret, CHAR(8) AS folio_operacion, DATE AS fecha_operacion, DATE AS fecha_solicitud, DATE AS fecha_envio, CHAR(4) AS id_sucursal, CHAR(40) AS desc_sucursal,
                  MONEY(14,2) AS monto, CHAR(30) AS caja_general, INTEGER AS id_registro;

	DEFINE cCodRet CHAR(5);
    DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
    DEFINE iSqlErr INTEGER;
	DEFINE cTrans1 CHAR(30);
	DEFINE cTrans2 CHAR(30);
	DEFINE cTrans3 CHAR(30);
	DEFINE cFolioOperacion CHAR(8);
	DEFINE dFechaOperacion DATE;
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaEnvio DATE;
	DEFINE cIdSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE mMonto MONEY(14,2);
	DEFINE cCajaGeneral CHAR(30);
	DEFINE status CHAR(1);
	DEFINE iIdRegistro INTEGER;
    DEFINE iNoRegistros INTEGER;
    DEFINE iRecuperacion INTEGER;
    DEFINE iRegistros INTEGER;

	LET cCodRet = '00000';
    LET cCodRetSp = '';
	LET iCodRetSp = 0;
    LET iSqlErr = 0;
	LET cTrans1 = '';
	LET cTrans2 = '';
	LET cTrans3 = '';
	LET cFolioOperacion = '';
	LET dFechaOperacion = '';
	LET dFechaSolicitud = '';
	LET dFechaEnvio = '';
	LET cIdSucursal = '';
	LET cDescSucursal = '';
	LET mMonto = '';
	LET cCajaGeneral = '';
	LET status = '';
	LET iIdRegistro = 0;
    LET iNoRegistros = 0;
    LET iRecuperacion = 0;
    LET iRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, iIdRegistro;
		END EXCEPTION;
	
		SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfarchivodotacaja.out';
		TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pIdSucursal = '' OR pIdProvCaja = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, iIdRegistro;
		END IF;
	
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, iIdRegistro;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, iIdRegistro;
		END IF;
	
		SET LOCK MODE TO WAIT 6;
	
		
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion folio_operacion, fecha_operacion, fecha_solicitud, fecha_envio, id_sucursal, desc_sucursal, monto, caja_general, id_registro
			INTO cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, iIdRegistro
			FROM bdicnweb:'informix'.sw_cg_envioarchivos
			WHERE id_usuario = pUsuario
		
			RETURN cCodRet, NVL(cFolioOperacion,''), NVL(dFechaOperacion,''), NVL(dFechaSolicitud,''), NVL(dFechaEnvio,''), NVL(cIdSucursal,''), NVL(UPPER(cDescSucursal),''),
			NVL(mMonto,''), NVL(UPPER(cCajaGeneral),''), iIdRegistro WITH RESUME;
		
			LET iRecuperacion = iRecuperacion + 1;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		END IF;
		
	END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 16/02/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el detalle de las transacciones pendientes.',
'FUNCIONALIDAD: EnvÃ­o de Archivos Dotaciones Sucursales Caja General',
'MODULO: Caja General',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 17/02/2015',
'DESCRIPCION: se optimiza el procedimiento para SOC.';

CREATE PROCEDURE "informix".sp_totalesarchivodotacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2), pIdSucursal CHAR(4), pIdProvCaja CHAR(4))
		
		RETURNING CHAR(5) AS codret,
			INTEGER AS totalRegistros;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cTrans1 CHAR(30);
		DEFINE cTrans2 CHAR(30);
		DEFINE cTrans3 CHAR(30);
		DEFINE cFolioOperacion CHAR(8);
		DEFINE dFechaOperacion DATE;
		DEFINE dFechaSolicitud DATE;
		DEFINE dFechaEnvio DATE;
		DEFINE cIdSucursal CHAR(4);
		DEFINE cDescSucursal CHAR(40);
		DEFINE mMonto MONEY(14,2);
		DEFINE cCajaGeneral CHAR(30);
		DEFINE status CHAR(1);
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cTrans1 = '';
		LET cTrans2 = '';
		LET cTrans3 = '';
		LET cFolioOperacion = '';
		LET dFechaOperacion = '';
		LET dFechaSolicitud = '';
		LET dFechaEnvio = '';
		LET cIdSucursal = '';
		LET cDescSucursal = '';
		LET mMonto = '';
		LET cCajaGeneral = '';
		LET status = '';
		LET iTotalRegistros = 0;	

	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;

				UPDATE "informix".sw_verificastatusdotacioncaja
				SET status = 'E', error = cCodRet
				WHERE usuario_insert = pUsuario;

                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesarchivodotacaja.out';
            --TRACE ON;
            
			DELETE FROM "informix".sw_verificastatusdotacioncaja WHERE usuario_insert = pUsuario;
			INSERT INTO "informix".sw_verificastatusdotacioncaja (usuario_insert, status, error_proceso, error, totalRegistros) VALUES(pUsuario,'I','','', 0);
		
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pIdSucursal = '' OR pIdProvCaja = '' THEN
				LET cCodRet = '00003';

				UPDATE "informix".sw_verificastatusdotacioncaja
				SET status = 'E', error = cCodRet
				WHERE usuario_insert = pUsuario;

				RETURN cCodRet, iTotalRegistros;
            END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				
				UPDATE "informix".sw_verificastatusdotacioncaja
				SET status = 'E', error = cCodRet
				WHERE usuario_insert = pUsuario;

				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;			
			SELECT valor INTO cTrans1 FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0001'; 
			SET ISOLATION TO DIRTY READ;
			SELECT valor INTO cTrans2 FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0010';
			SET ISOLATION TO DIRTY READ;			
			SELECT valor INTO cTrans3 FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0036'; 

			DELETE FROM bdicnweb:'informix'.sw_cg_envioarchivos; 
			
			IF pIdSucursal = '0000' THEN
				IF pIdProvCaja = '0000' THEN
					FOREACH
						SELECT a.folio_oper, a.fecha_operacion, b.fecha_solicitud, b.fecha_envio, s.sucursal, s.nombre, b.monto, p.descripcion
						INTO cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral
						FROM bdisuc:'informix'.ss_operaciones a, bdisuc:'informix'.ss_mae_entradasalida b, bdisuc:'informix'.ss_proveedores p, bdinteg:'informix'.si_sucursales s
						WHERE a.cod_trans IN (cTrans1, cTrans2, cTrans3) AND
								a.fecha_operacion BETWEEN '01/01/2007' AND DATE(CURRENT) AND
								a.sucursal IN (SELECT sucursal
											FROM bdinteg:'informix'.si_sucursales
											WHERE sucursal        != '0'            AND
													empresa         = '001'           AND
													tpo_sucursal    = pTipoSucursal)  AND
													a.reversado     IN ('0')          AND
													a.folio_oper    = b.folio_oper    AND
													--b.cod_proveedor = pIdProvCaja     AND
													b.status        = '03'            AND
													p.cod_proveedor = b.cod_proveedor AND
													s.empresa       = '001'           AND
													s.sucursal      = a.sucursal
		
						SET LOCK MODE TO WAIT 3;
						
						INSERT INTO bdicnweb:'informix'.sw_cg_envioarchivos(id_usuario, folio_operacion, fecha_operacion, fecha_solicitud, fecha_envio, id_sucursal, desc_sucursal, monto, caja_general, status)
						VALUES (pUsuario, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, 'E');
					END FOREACH;
				ELSE
					FOREACH
						SELECT a.folio_oper, a.fecha_operacion, b.fecha_solicitud, b.fecha_envio, s.sucursal, s.nombre, b.monto, p.descripcion
						INTO cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral
						FROM bdisuc:'informix'.ss_operaciones a, bdisuc:'informix'.ss_mae_entradasalida b, bdisuc:'informix'.ss_proveedores p, bdinteg:'informix'.si_sucursales s
						WHERE a.cod_trans IN (cTrans1, cTrans2, cTrans3) AND
								a.fecha_operacion BETWEEN '01/01/2007' AND DATE(CURRENT) AND
								a.sucursal IN (SELECT sucursal
											FROM bdinteg:'informix'.si_sucursales
											WHERE sucursal        != '0'            AND
													empresa         = '001'           AND
													tpo_sucursal    = pTipoSucursal)  AND
													a.reversado     IN ('0')          AND
													a.folio_oper    = b.folio_oper    AND
													b.cod_proveedor = pIdProvCaja     AND
													b.status        = '03'            AND
													p.cod_proveedor = b.cod_proveedor AND
													s.empresa       = '001'           AND
													s.sucursal      = a.sucursal
		
						SET LOCK MODE TO WAIT 3;
						
						INSERT INTO bdicnweb:'informix'.sw_cg_envioarchivos(id_usuario, folio_operacion, fecha_operacion, fecha_solicitud, fecha_envio, id_sucursal, desc_sucursal, monto, caja_general, status)
						VALUES (pUsuario, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral, 'E');
					END FOREACH;
				END IF;
			ELSE
				IF pIdProvCaja = '0000' THEN
					FOREACH
						SELECT a.folio_oper, a.fecha_operacion, b.fecha_solicitud, b.fecha_envio, s.sucursal, s.nombre, b.monto, p.descripcion
						INTO cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral
						FROM bdisuc:'informix'.ss_operaciones a, bdisuc:'informix'.ss_mae_entradasalida b, bdisuc:'informix'.ss_proveedores p, bdinteg:'informix'.si_sucursales s
						WHERE a.cod_trans       IN (cTrans1, cTrans2, cTrans3)          AND
								a.fecha_operacion BETWEEN '01/01/2007'  AND DATE(CURRENT) AND
								a.sucursal        = pIdSucursal                           AND
								a.reversado       IN ('0')                                AND
								a.folio_oper      = b.folio_oper                          AND
								--b.cod_proveedor   = pIdProvCaja                           AND
								b.status          = '03'                                  AND
								p.cod_proveedor   = b.cod_proveedor                       AND
								s.empresa         = '001'                                 AND
								s.sucursal        = a.sucursal
		
						SET LOCK MODE TO WAIT 3;
		
						INSERT INTO bdicnweb:'informix'.sw_cg_envioarchivos(id_usuario, folio_operacion, fecha_operacion, fecha_solicitud, fecha_envio, id_sucursal, desc_sucursal, monto, caja_general)
						VALUES (pUsuario, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral);
					END FOREACH;
				ELSE
					FOREACH
						SELECT a.folio_oper, a.fecha_operacion, b.fecha_solicitud, b.fecha_envio, s.sucursal, s.nombre, b.monto, p.descripcion
						INTO cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral
						FROM bdisuc:'informix'.ss_operaciones a, bdisuc:'informix'.ss_mae_entradasalida b, bdisuc:'informix'.ss_proveedores p, bdinteg:'informix'.si_sucursales s
						WHERE a.cod_trans       IN (cTrans1, cTrans2, cTrans3)          AND
							a.fecha_operacion BETWEEN '01/01/2007'  AND DATE(CURRENT) AND
							a.sucursal        = pIdSucursal                           AND
							a.reversado       IN ('0')                                AND
							a.folio_oper      = b.folio_oper                          AND
							b.cod_proveedor   = pIdProvCaja                           AND
							b.status          = '03'                                  AND
							p.cod_proveedor   = b.cod_proveedor                       AND
							s.empresa         = '001'                                 AND
							s.sucursal        = a.sucursal
		
						SET LOCK MODE TO WAIT 3;
		
						INSERT INTO bdicnweb:'informix'.sw_cg_envioarchivos(id_usuario, folio_operacion, fecha_operacion, fecha_solicitud, fecha_envio, id_sucursal, desc_sucursal, monto, caja_general)
						VALUES (pUsuario, cFolioOperacion, dFechaOperacion, dFechaSolicitud, dFechaEnvio, cIdSucursal, cDescSucursal, mMonto, cCajaGeneral);
					END FOREACH;
				END IF;
			END IF;
			
			SET ISOLATION TO DIRTY READ;

			SELECT COUNT(*) INTO iTotalRegistros
			FROM bdicnweb:'informix'.sw_cg_envioarchivos
			WHERE id_usuario = pUsuario;
									
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				UPDATE "informix".sw_verificastatusdotacioncaja
				SET status = 'E', error = cCodRet
				WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			UPDATE "informix".sw_verificastatusdotacioncaja
			SET status = 'T', error = cCodRet, totalRegistros = iTotalRegistros
			WHERE usuario_insert = pUsuario;
			
			RETURN cCodRet, iTotalRegistros;	
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 17/02/2015',
'DESCRIPCION: SPL que consulta el nÃºmero total de registros de las transacciones pendientes de envÃ­o de archivos.',
'FUNCIONALIDAD: EnvÃ­o de Archivos Dotaciones Sucursales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 17/02/2015',
'DESCRIPCION: se optimiza el procedimiento para SOC.';

CREATE PROCEDURE "informix".sp_bccc_verificastatusmonitor(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS total_reg,
		INTEGER AS total_exitosas,
		CHAR(1) AS existe_error,
		CHAR(2) AS estatus,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(1);
	DEFINE iTotalRegistros INTEGER;
	DEFINE itotalExitosas INTEGER;
	DEFINE cExisteError CHAR(1);
	DEFINE cEstatus CHAR(2);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';
	LET iTotalRegistros = 0;
	LET itotalExitosas = 0;
	LET cExisteError = '';
	LET cEstatus = '';
	LET cErrorProceso = '';
	LET cError = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_verificastatusmonitor.out';
		--TRACE ON;

		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;

		IF pIdConsulta = '1' THEN
			
			IF EXISTS (SELECT 1	FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario AND status = 'I') THEN
				UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
				SET status = 'T'
				WHERE usuario = pUsuario;
			END IF;

			--IF EXISTS (SELECT 1	FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE status = 'I') THEN
				--RETURN cCodRet, 'I', iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
			--ELSE

				IF EXISTS (SELECT 1	FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario) THEN

					--SET LOCK MODE TO WAIT 3;
					UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
					SET status = 'I', altas_total = 0, total_exitosas = 0, existe_error = '', estatus = '', error_proceso = '', error = ''
					WHERE usuario = pUsuario;

				ELSE

					--SET LOCK MODE TO WAIT 3;
					INSERT INTO bdicnweb:"informix".sw_buro_statusmonitorbccc(usuario,status,altas_total,total_exitosas,existe_error,estatus,error_proceso,error)
					VALUES(pUsuario, 'I', 0, 0, '', '', '', '');

				END IF;

				RETURN cCodRet, 'T', iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;

			--END IF;

		ELIF pIdConsulta = '2' THEN

			SELECT status, altas_total, total_exitosas, existe_error, estatus, error_proceso, error
			INTO cStatus,iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError
			FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario;

			--IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
				--RETURN cCodRet, cStatus, iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;

				--RETURN cCodRet, 'I', iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
			--ELSE
				RETURN cCodRet, cStatus, iTotalRegistros, itotalExitosas, cExisteError, cEstatus, cErrorProceso, cError;
			--END IF;

		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 30/11/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: Monitor de Situacion de Envios Bc y Cc',
'DESCRIPCION: SPL que consulta el Estatus del proceso de Consulta del Monitor de Situacion Envios BC y CC.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 22/02/2017',
'DESCRIPCION: Se modifica el SPL para agregar una bandera que controle el monitoreo de las ejecuciones en proceso (general y por usuario).',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 30/05/2017',
'DESCRIPCION: Se modifica el SPL para agrega validación encargada de liberar solicitudes que se queden en proceso de consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consultasubproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pNombreProd CHAR(40), pIdSubProducto CHAR(4), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret, 
				  CHAR(100)  AS Variable1,
				  CHAR(100)  AS Variable2,
				  CHAR(100)  AS Variable3,
				  CHAR(100)  AS Variable4,
				  CHAR(100)  AS Variable5,
				  CHAR(100)  AS Variable6,
				  CHAR(100)	 AS Variable7,
				  CHAR(100)  AS Variable8;
	
	DEFINE cCodRet 				   CHAR(5);
	DEFINE cCodRetSp 			   CHAR(5);
	DEFINE iSqlErr 				   INTEGER;
	DEFINE iCodRetSp 			   INTEGER;
	DEFINE vVariable1			   VARCHAR(100);
	DEFINE vVariable2			   VARCHAR(100);
	DEFINE vVariable3			   VARCHAR(100);
	DEFINE vVariable4			   VARCHAR(100);
	DEFINE vVariable5			   VARCHAR(100);
	DEFINE vVariable6			   VARCHAR(100);
	DEFINE vVariable7			   VARCHAR(100);
	DEFINE vVariable8			   VARCHAR(100);
	DEFINE iRecuperacion 		   INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET vVariable1			    = '';
	LET vVariable2			    = '';
	LET vVariable3			    = '';
	LET vVariable4			    = '';
	LET vVariable5			    = '';
	LET vVariable6			    = '';
	LET vVariable7			    = '';
	LET vVariable8			    = '';
	LET iRecuperacion 			= 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultasubproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR ( pNumProducto = '' AND pNombreProd = '') AND pTipoEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_subproducto(pNumProducto, pNombreProd,pIdSubProducto,pTipoEjecucion)
			INTO cCodRetSp, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consulta_subproducto";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, vVariable1, vVariable2, vVariable3,vVariable4, vVariable5, vVariable6, vVariable7,vVariable8 WITH RESUME;
			
		END FOREACH;
		
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar subproducto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_grabacomplementarias(pUsuario CHAR(10), pIdFuncion CHAR(10), pCuentas_Medios CHAR(1), pCancelacion_Inac CHAR(1), pCancelacion_Vig CHAR(1), pTiempo_Cancelar CHAR(1), 
			 pSeguro_Vida CHAR(1), pCobro_Mensualidad CHAR(1), pEnvio_Mesa_Control  CHAR(1), pId_Domiciliacion CHAR(1), pConciliador CHAR(1), pHistorico_Cred CHAR(1), pPeriodo_Gracia CHAR(1), 
			 pDias_Gracia INTEGER, pCapital_Interes CHAR(1), pIntereses CHAR(1), pCapital CHAR(1), pEstado_Cuenta CHAR(1),pTipoEdocta CHAR(1), pTipoFacturacion CHAR(1), pd_estadocuenta CHAR(20), pemision_estado_cuenta CHAR(2), 
			 prango_inicial CHAR(2),prango_final CHAR(2),pid_tipo_facturacion CHAR(2), pn_dias_facturacion CHAR(3), pdia_facturacion CHAR(2), prango_f_fecha_inic CHAR(2), prango_f_fecha_fin CHAR(2), 
			 pidcta_concentradora CHAR(1), pcta_concentradora CHAR(20))
      RETURNING CHAR(5) AS codRet;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_grabacomplementarias.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			RETURN cCodRet;
        END IF;

		INSERT INTO bdicred:"informix".tmp_caracteristicas_complementarias(pcuentas_medios, pcancelacion_inac, pcancelacion_vig, ptiempo_cancelar, pseguro_vida, pcobro_mensualidad, penvio_mesa_control, pid_domiciliacion, pconciliador, phistorico_cred, pperiodo_gracia, pdias_gracia, pcapital_interes, pintereses, pcapital, pestado_cuenta, ptipoedocta, ptipofacturacion, pd_estadocuenta, pemision_estado_cuenta, prango_inicial, prango_final, pid_tipo_facturacion, pn_dias_facturacion, pdia_facturacion, prango_f_fecha_inic, prango_f_fecha_fin, pidcta_concentradora, pcta_concentradora, usuario_insert) 
		VALUES(pCuentas_Medios, pCancelacion_Inac, pCancelacion_Vig, pTiempo_Cancelar, pSeguro_Vida, pCobro_Mensualidad, pEnvio_Mesa_Control, pId_Domiciliacion, pConciliador, pHistorico_Cred, pPeriodo_Gracia, 
			 pDias_Gracia, pCapital_Interes, pIntereses, pCapital, pEstado_Cuenta, pTipoEdocta, pTipoFacturacion, pd_estadocuenta, pemision_estado_cuenta, prango_inicial, prango_final, pid_tipo_facturacion, pn_dias_facturacion, 
			 pdia_facturacion, prango_f_fecha_inic, prango_f_fecha_fin, pidcta_concentradora, pcta_concentradora, pUsuario);
	
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 19/09/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Alta Subproductos',
'DESCRIPCION: SPL encargado de grabar caracteristicas temporales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_mensajesactivos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pCveCanal SMALLINT, pIdEvento SMALLINT, pCodPlantilla SMALLINT, pCodMsmMail CHAR(50), pActivoSms CHAR(1), pActivoEmail CHAR(1), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				 CHAR(4) AS id_evento,
				 CHAR(40) AS descripcion,
				 CHAR(50) AS variable1,
				 CHAR(50) AS variable2,
				 CHAR(50) AS variable3,
				 CHAR(50) AS variable4,
				 CHAR(50) AS variable5,
				 CHAR(4) AS variable6;
		
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE sIdEvento	   		SMALLINT;
	DEFINE cDescripcion			CHAR(40);
	DEFINE cCveCanal 			CHAR(50);
	DEFINE cActivoSms 			CHAR(50);
	DEFINE cActivoEmail			CHAR(50);
	DEFINE cCodPlantilla 		CHAR(50);
	DEFINE cCodMsmMail 			CHAR(50);
	DEFINE sCveEvento			CHAR(4);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET sIdEvento				= 0;
	LET cDescripcion			= '';
	LET cCveCanal 				= '';
	LET cActivoSms 				= '';
	LET cActivoEmail			= '';
	LET cCodPlantilla 			= '';
	LET cCodMsmMail 			= '';
	LET sCveEvento				= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_mensajesactivos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pCveCanal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_mensajes_activos(pNumProducto, pCveCanal, pIdEvento, pCodPlantilla, pCodMsmMail, pActivoSms, pActivoEmail, pTipoEjecucion)	
			INTO cCodRetSp, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento
		
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_mensajes_activos";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento;
			END IF;
			
			RETURN cCodRet, sIdEvento, cDescripcion, cCveCanal, cCodPlantilla, cCodMsmMail, cActivoSms, cActivoEmail, sCveEvento WITH RESUME;
			
		END FOREACH;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los mensajes activos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_obtenerdoctosdigitalizar(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pCodigoGrupo CHAR(3), pCodigoDocto CHAR(4), pDescripcion CHAR(50), pTipoEjecucion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER, pNombreProducto CHAR(50), pligar CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(40) AS codigo,
				CHAR(50) AS descripcion,
				CHAR(4)  AS variable1,
				CHAR(4)  AS variable2,
				CHAR(50)  AS variable3,
                CHAR(1) AS cVariable4;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cEmpresa    	    	CHAR(4);
	DEFINE cCodigo    	    	CHAR(4);
	DEFINE cDescripcion        	CHAR(50);
	DEFINE cVariable1           CHAR(4);
	DEFINE cVariable2			CHAR(4);
	DEFINE cVariable3           CHAR(50);
    DEFINE cVariable4           CHAR(1);
	DEFINE iRecuperacion		INTEGER;

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa		        = '001';
	LET cCodigo		           	= '';
	LET cDescripcion           	= '';
	LET cVariable1				= '';
	LET cVariable2				= '';
	LET cVariable3				= '';
    LET cVariable4              = '';
	LET iRecuperacion 			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3,cVariable4;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_obtenerdoctosdigitalizar.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoEjecucion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_obtenerdoctosdigitalizar(cEmpresa, pNumProducto, pCodigoGrupo, pCodigoDocto, pDescripcion, pTipoEjecucion, pRegistros, pRecuperacion,pNombreProducto, pligar)
			INTO cCodRetSp, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_obtenerdoctosdigitalizar";
			ELIF iCodRetSp = 1 THEN
				IF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
				ELSE
					LET cCodRet = '00017';
				END IF;
				RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
			END IF;

			LET iRecuperacion = iRecuperacion + 1;

			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4 WITH RESUME;

		END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCodigo, cDescripcion,cVariable1, cVariable2, cVariable3, cVariable4;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los documentos a digitalizar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_tasasdiferenciadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pFechaTasa DATE, pNumProducto CHAR(4), pGrupo CHAR(1),
		pModeloHitBuenoOrdnario DECIMAL(11,6), pModeloHitMaloOrdnario DECIMAL(11,6), pModeloNoHitOrdinario DECIMAL(11,6), pModeloHitBuenoMoratorio DECIMAL(11,6), pModeloHitMaloMoratorio DECIMAL(11,6), pModeloNoHitMoratorio DECIMAL(11,6) , pNumSubProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
				DATE AS fecha_tasa,
				CHAR(4) AS NumProducto,
				CHAR(1) AS Grupo,
				DECIMAL(11,6) AS ModeloHitBuenoOrdnario,
				DECIMAL(11,6) AS ModeloHitMaloMoratorio,
				DECIMAL(11,6) AS ModeloNoHitOrdinario,
				DECIMAL(11,6) AS ModeloHitBuenoMoratorio,
				DECIMAL(11,6) AS ModeloHitMaloOrdnario,
				DECIMAL(11,6) AS ModeloNoHitMoratorio;

	DEFINE cCodRet 				 	CHAR(5);
	DEFINE iSqlErr 				 	INTEGER;
	DEFINE cCodRetSp 			 	CHAR(5);
	DEFINE iCodRetSp 			 	INTEGER;
	DEFINE cEmpresa              	CHAR(3);
	DEFINE dFechaTasa          		DATE;
	DEFINE cNumProducto        		CHAR(4);
	DEFINE cGrupo              		CHAR(1);
	DEFINE dModeloHitBuenoOrdnario  DECIMAL(11,6);
	DEFINE dModeloHitMaloOrdnario  	DECIMAL(11,6);
	DEFINE dModeloNoHitOrdinario  	DECIMAL(11,6);
	DEFINE dModeloHitBuenoMoratorio	DECIMAL(11,6);
	DEFINE dModeloHitMaloMoratorio  DECIMAL(11,6);
	DEFINE dModeloNoHitMoratorio  	DECIMAL(11,6);
	DEFINE dFechaInsert      		DATETIME YEAR to FRACTION(5);
	DEFINE iTotReg		      		INTEGER;

	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cEmpresa 					= '001';
	LET dFechaTasa          		= DATE(1);
	LET cNumProducto        		= '';
	LET cGrupo              		= '';
	LET dModeloHitBuenoOrdnario  	= 0;
	LET dModeloHitMaloOrdnario  	= 0;
	LET dModeloNoHitOrdinario  		= 0;
	LET dModeloHitBuenoMoratorio	= 0;
	LET dModeloHitMaloMoratorio  	= 0;
	LET dModeloNoHitMoratorio  		= 0;
	LET dFechaInsert				= DATE(1);
	LET iTotReg		      			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		END EXCEPTION;

		--SET DEBUG FILE TO '/ifxsif01/Male/sp_cred_tasasdiferenciadas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pBandera = '1' THEN -- INSERTA
			--DELETE FROM bdicred:"informix".tmp_sd_tasas_disposiciones_diferenciadas WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = pGrupo AND evalua_cc = pEvaluaCc AND usuario_insert = pUsuario;

			INSERT INTO bdicred:"informix".tmp_tasas_diferenciadas(empresa, num_producto, grupo, modelo_hit_bueno_ordnario, modelo_hit_malo_ordnario, modelo_no_hit_ordinario, modelo_hit_bueno_moratorio, modelo_hit_malo_moratorio, modelo_no_hit_moratorio, fecha_insert)
			VALUES(cEmpresa, pNumProducto, pGrupo, pModeloHitBuenoOrdnario, pModeloHitMaloOrdnario, pModeloNoHitOrdinario, pModeloHitBuenoMoratorio, pModeloHitMaloMoratorio, pModeloNoHitMoratorio, CURRENT);

			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;

		ELIF pBandera = '2' THEN -- ACTUALIZA

			UPDATE bdicred:"informix".tmp_tasas_diferenciadas SET
			modelo_hit_bueno_ordnario = pModeloHitBuenoOrdnario,
			modelo_hit_malo_ordnario = pModeloHitMaloOrdnario,
			modelo_no_hit_ordinario = pModeloNoHitOrdinario,
			modelo_hit_bueno_moratorio = pModeloHitBuenoMoratorio,
			modelo_hit_malo_moratorio = pModeloHitMaloMoratorio,
			modelo_no_hit_moratorio = pModeloNoHitMoratorio,
			fecha_insert = CURRENT
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = pGrupo;

			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		ElIF pBandera = '3' THEN -- ELIMINA

			DELETE FROM bdicred:"informix".tmp_tasas_diferenciadas
			WHERE empresa = cEmpresa AND num_producto = pNumProducto;

			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		ElIF pBandera = '4' THEN -- CONSULTA
			FOREACH
				SELECT fecha_insert, num_producto, grupo, modelo_hit_bueno_ordnario, modelo_hit_malo_ordnario, modelo_no_hit_ordinario, modelo_hit_bueno_moratorio, modelo_hit_malo_moratorio, modelo_no_hit_moratorio
				INTO dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloOrdnario, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloMoratorio, dModeloNoHitMoratorio
				FROM bdicred:"informix".tmp_tasas_diferenciadas
				WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario

				IF NVL(dModeloHitBuenoMoratorio,0) > 0 THEN
					LET dModeloHitBuenoMoratorio = dModeloHitBuenoMoratorio - dModeloHitBuenoOrdnario;
				ELIF NVL(dModeloHitMaloMoratorio,0) > 0 THEN
					LET dModeloHitMaloMoratorio = dModeloHitMaloMoratorio - dModeloHitMaloOrdnario;
				ELIF NVL(dModeloNoHitMoratorio,0) > 0 THEN
					LET dModeloNoHitMoratorio = dModeloNoHitMoratorio - dModeloNoHitOrdinario;
				END IF;

				RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio WITH RESUME;
			END FOREACH;
		ElIF pBandera = '5' THEN -- ALMACENA
			FOREACH
				SELECT fecha_insert, num_producto, grupo, modelo_hit_bueno_ordnario, modelo_hit_malo_ordnario, modelo_no_hit_ordinario, modelo_hit_bueno_moratorio, modelo_hit_malo_moratorio, modelo_no_hit_moratorio
				INTO dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloOrdnario, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloMoratorio, dModeloNoHitMoratorio
				FROM bdicred:"informix".tmp_tasas_diferenciadas
				WHERE empresa = cEmpresa AND num_producto = pNumProducto

				IF NVL(dModeloHitBuenoMoratorio,0) > 0 AND NVL(dModeloHitBuenoMoratorio,0) < NVL(dModeloHitBuenoOrdnario,0) THEN
					LET dModeloHitBuenoMoratorio = dModeloHitBuenoMoratorio + dModeloHitBuenoOrdnario;
				END IF;
				IF NVL(dModeloHitMaloMoratorio,0) > 0 AND NVL(dModeloHitMaloMoratorio,0) < NVL(dModeloHitMaloOrdnario,0) THEN
					LET dModeloHitMaloMoratorio = dModeloHitMaloMoratorio + dModeloHitMaloOrdnario;
				END IF;
				IF NVL(dModeloNoHitMoratorio,0) > 0 AND NVL(dModeloNoHitMoratorio,0) < NVL(dModeloNoHitOrdinario,0) THEN
					LET dModeloNoHitMoratorio = dModeloNoHitMoratorio + dModeloNoHitOrdinario;
				END IF;

				SELECT COUNT (*) INTO iTotReg
				FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
				WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = pGrupo;

				IF iTotReg = 0 THEN
					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					VALUES(cEmpresa, cNumProducto, cGrupo, '1', dModeloHitMaloOrdnario, dModeloHitMaloMoratorio, 0, 0, CURRENT, NULL);

					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					VALUES(cEmpresa, cNumProducto, cGrupo, '0', dModeloHitBuenoOrdnario, dModeloHitBuenoMoratorio, 0, 0, CURRENT, NULL);

					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					VALUES(cEmpresa, cNumProducto, cGrupo, 'X', dModeloNoHitOrdinario, dModeloNoHitMoratorio, 0, 0, CURRENT, NULL);
				ELSE
					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET
					fecha_tasa = CURRENT,
					tasa_int_ordinaria = dModeloHitMaloOrdnario,
					tasa_int_moratoria = dModeloHitMaloMoratorio
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '1';

					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET
					fecha_tasa = CURRENT,
					tasa_int_ordinaria = dModeloHitBuenoOrdnario,
					tasa_int_moratoria = dModeloHitBuenoMoratorio
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '0';

					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET
					fecha_tasa = CURRENT,
					tasa_int_ordinaria = dModeloNoHitOrdinario,
					tasa_int_moratoria = dModeloNoHitMoratorio
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = 'X';
				END IF;
			END FOREACH;

			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;

		ElIF pBandera = '6' THEN -- CONSULTA ORIGINAL
			FOREACH
				SELECT DISTINCT grupo
				INTO cGrupo
				FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
				WHERE empresa = cEmpresa AND num_producto = pNumProducto

				IF NVL(pNumSubProducto,'0') = '0' THEN
					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloHitMaloOrdnario, dModeloHitMaloMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '1' AND NVL(id_subproducto,'0') = '0';

					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloHitBuenoOrdnario,dModeloHitBuenoMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '0' AND NVL(id_subproducto,'0') = '0';

					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloNoHitOrdinario, dModeloNoHitMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = 'X' AND NVL(id_subproducto,'0') = '0';
				ELSE
					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloHitMaloOrdnario, dModeloHitMaloMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '1' AND id_subproducto = pNumSubProducto;

					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloHitBuenoOrdnario, dModeloHitBuenoMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = '0' AND id_subproducto = pNumSubProducto;

					SELECT tasa_int_ordinaria, tasa_int_moratoria
					INTO dModeloNoHitOrdinario, dModeloNoHitMoratorio
					FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas
					WHERE empresa = cEmpresa AND num_producto = pNumProducto AND grupo = cGrupo AND evalua_cc = 'X' AND id_subproducto = pNumSubProducto;

				END IF;

				IF NVL(dModeloHitBuenoMoratorio,0) > 0 AND NVL(dModeloHitBuenoMoratorio,0) > NVL(dModeloHitBuenoOrdnario,0) THEN
					LET dModeloHitBuenoMoratorio = dModeloHitBuenoMoratorio - dModeloHitBuenoOrdnario;
				END IF;
				IF NVL(dModeloHitMaloMoratorio,0) > 0 AND NVL(dModeloHitMaloMoratorio,0) > NVL(dModeloHitMaloOrdnario,0) THEN
					LET dModeloHitMaloMoratorio = dModeloHitMaloMoratorio - dModeloHitMaloOrdnario;
				END IF;
				IF NVL(dModeloNoHitMoratorio,0) > 0 AND NVL(dModeloNoHitMoratorio,0) > NVL(dModeloNoHitOrdinario,0) THEN
					LET dModeloNoHitMoratorio = dModeloNoHitMoratorio - dModeloNoHitOrdinario;
				END IF;

				RETURN cCodRet, CURRENT, pNumProducto, cGrupo, dModeloHitBuenoOrdnario,dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio WITH RESUME;
			END FOREACH;
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00017';  -- No hay informacion
			RETURN cCodRet, dFechaTasa, cNumProducto, cGrupo, dModeloHitBuenoOrdnario, dModeloHitMaloMoratorio, dModeloNoHitOrdinario, dModeloHitBuenoMoratorio, dModeloHitMaloOrdnario, dModeloNoHitMoratorio;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de operar las tasas diferenciadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_caracteristicasproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pNumProducto CHAR(4), pMontoMinCred DECIMAL(18,2), pMontoMaxCred DECIMAL(18,2), pEdadMin INTEGER, pEdadMax INTEGER,
		pPlazoMinCred INTEGER, pPlazoMaxCred INTEGER, pIdFrecPago SMALLINT, pCobroComisionAnual CHAR(1), pComiGastoCobranza SMALLINT, pCobroComisApertura CHAR(1), pComiDisposicionEfect SMALLINT,
		pComiAclaracionNo SMALLINT, pComiLiquidacionAntic SMALLINT, pCodComisionApertura CHAR(4), pCodComiGastoCobranza CHAR(4), pCodComisionAnualidad CHAR(8), pCodComiDisposicionEfect CHAR(4),
		pCodComiAclaracionNo CHAR(4), pCodComiLiquidacionAntic CHAR(4), pGarantias SMALLINT, pIdGarantia SMALLINT, pPorcentajeAforo DECIMAL(16), pObligadoSolidario CHAR(1), pNumObligados CHAR(1), pCapturaObligatoria CHAR(1), pMontoMinDisp DECIMAL(18,2), pMontoMaxDisp DECIMAL(18,2),
		pFormApliComiGasCob CHAR(1), pFormApliComiAper CHAR(1), pFormApliComiDispo CHAR(1), pFormApliComiAnual CHAR(1), pFormApliComiAclara CHAR(1), pFormApliComiLiqAnt CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS cNumProducto,
				DECIMAL(18,2) AS dMontoMinCred,
				DECIMAL(18,2) AS dMontoMaxCred,
				INTEGER AS iEdadMin,
				INTEGER AS iEdadMax,
				INTEGER AS iPlazoMinCred,
				INTEGER AS iPlazoMaxCred,
				SMALLINT AS iIdFrecPago,
				CHAR(1) AS cCobroComisionAnual,
				SMALLINT AS iComiGastoCobranza,
				CHAR(1) AS cCobroComisApertura,
				SMALLINT AS iComiDisposicionEfect,
				SMALLINT AS iComiAclaracionNo,
				SMALLINT AS iComiLiquidacionAntic,
				CHAR(4) AS cCodComisionApertura,
				CHAR(4) AS cCodComiGastoCobranza,
				CHAR(8) AS cCodComisionAnualidad,
				CHAR(4) AS cCodComiDisposicionEfect,
				CHAR(4) AS cCodComiAclaracionNo,
				CHAR(4) AS cCodComiLiquidacionAntic,
				SMALLINT AS iGarantias,
				SMALLINT AS iIdGarantia,
				DECIMAL(16) AS dPorcentajeAforo,
				CHAR(1) AS cObligadoSolidario,
				CHAR(1) AS cNumObligados,
				CHAR(1) AS cCapturaObligatoria,
				DECIMAL(18,2) AS dMontoMinDisp,
				DECIMAL(18,2) AS dMontoMaxDisp,
				CHAR(1) AS cFormApliComiGasCob,
				CHAR(1) AS cFormApliComiAper,
				CHAR(1) AS cFormApliComiDispo,
				CHAR(1) AS cFormApliComiAnual,
				CHAR(1) AS cFormApliComiAclara,
				CHAR(1) AS cFormApliComiLiqAnt;

	DEFINE cCodRet 				 	CHAR(5);
	DEFINE iSqlErr 				 	INTEGER;
	DEFINE cCodRetSp 			 	CHAR(5);
	DEFINE iCodRetSp 			 	INTEGER;
	DEFINE cEmpresa              	CHAR(3);
	DEFINE cNumProducto             CHAR(4);
	DEFINE dMontoMinCred            DECIMAL(18,2);
	DEFINE dMontoMaxCred            DECIMAL(18,2);
	DEFINE iEdadMin                 INTEGER;
	DEFINE iEdadMax                 INTEGER;
	DEFINE iPlazoMinCred            INTEGER;
	DEFINE iPlazoMaxCred            INTEGER;
	DEFINE iIdFrecPago              SMALLINT;
	DEFINE cCobroComisionAnual      CHAR(1);
	DEFINE iComiGastoCobranza       SMALLINT;
	DEFINE cCobroComisApertura      CHAR(1);
	DEFINE iComiDisposicionEfect    SMALLINT;
	DEFINE iComiAclaracionNo        SMALLINT;
	DEFINE iComiLiquidacionAntic    SMALLINT;
	DEFINE cCodComisionApertura     CHAR(4);
	DEFINE cCodComiGastoCobranza   	CHAR(4);
	DEFINE cCodComisionAnualidad    CHAR(8);
	DEFINE cCodComiDisposicionEfect CHAR(4);
	DEFINE cCodComiAclaracionNo    	CHAR(4);
	DEFINE cCodComiLiquidacionAntic	CHAR(4);
	DEFINE iGarantias               SMALLINT;
	DEFINE iIdGarantia              SMALLINT;
	DEFINE dPorcentajeAforo         DECIMAL(16);
	DEFINE cObligadoSolidario       CHAR(1);
	DEFINE cNumObligados            CHAR(1);
	DEFINE cCapturaObligatoria      CHAR(1);
	DEFINE dMontoMinDisp            DECIMAL(18,2);
	DEFINE dMontoMaxDisp            DECIMAL(18,2);
	DEFINE cFormApliComiGasCob		CHAR(1);
	DEFINE cFormApliComiAper		CHAR(1);
	DEFINE cFormApliComiDispo		CHAR(1);
	DEFINE cFormApliComiAnual		CHAR(1);
	DEFINE cFormApliComiAclara		CHAR(1);
	DEFINE cFormApliComiLiqAnt 		CHAR(1);

	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cEmpresa 					= '001';
	LET cNumProducto             	= '';
	LET dMontoMinCred           	= 0.0;
	LET dMontoMaxCred            	= 0.0;
	LET iEdadMin                 	= 0;
	LET iEdadMax                 	= 0;
	LET iPlazoMinCred            	= 0;
	LET iPlazoMaxCred            	= 0;
	LET iIdFrecPago              	= 0;
	LET cCobroComisionAnual      	= '';
	LET iComiGastoCobranza       	= 0;
	LET cCobroComisApertura      	= '';
	LET iComiDisposicionEfect    	= 0;
	LET iComiAclaracionNo        	= 0;
	LET iComiLiquidacionAntic    	= 0;
	LET cCodComisionApertura     	= '';
	LET cCodComiGastoCobranza   	= '';
	LET cCodComisionAnualidad    	= '';
	LET cCodComiDisposicionEfect 	= '';
	LET cCodComiAclaracionNo    	= '';
	LET cCodComiLiquidacionAntic	= '';
	LET iGarantias               	= 0;
	LET iIdGarantia              	= 0;
	LET dPorcentajeAforo         	= 0.0;
	LET cObligadoSolidario       	= '';
	LET cNumObligados            	= '';
	LET cCapturaObligatoria      	= '';
	LET dMontoMinDisp           	= 0.0;
	LET dMontoMaxDisp            	= 0.0;
	LET cFormApliComiGasCob         = 0;
	LET cFormApliComiAper           = 0;
	LET cFormApliComiDispo          = 0;
	LET cFormApliComiAnual          = 0;
	LET cFormApliComiAclara         = 0;
	LET cFormApliComiLiqAnt         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp,
				cFormApliComiGasCob, cFormApliComiAper, cFormApliComiDispo, cFormApliComiAnual, cFormApliComiAclara, cFormApliComiLiqAnt;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_caracteristicasproductos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp,
				cFormApliComiGasCob, cFormApliComiAper, cFormApliComiDispo, cFormApliComiAnual, cFormApliComiAclara, cFormApliComiLiqAnt;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp,
				cFormApliComiGasCob, cFormApliComiAper, cFormApliComiDispo, cFormApliComiAnual, cFormApliComiAclara, cFormApliComiLiqAnt;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pBandera = '1' THEN -- INSERTA
			DELETE FROM bdicred:"informix".tmp_sd_definicion WHERE usuario_insert = pUsuario;

			INSERT INTO bdicred:"informix".tmp_sd_definicion(empresa, num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, comi_aclaracion_no, comi_liquidacion_antic,
				cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, monto_min_disp, monto_max_disp, usuario_insert,
				formapli_comigascob, formapli_comiaper, formapli_comidispo, formapli_comianual, formapli_comiaclara, formapli_comiliqant)
			VALUES(cEmpresa, pNumProducto, pMontoMinCred, pMontoMaxCred, pEdadMin, pEdadMax, pPlazoMinCred, pPlazoMaxCred, pIdFrecPago, pCobroComisionAnual, pComiGastoCobranza, pCobroComisApertura, pComiDisposicionEfect, pComiAclaracionNo, pComiLiquidacionAntic,
				pCodComisionApertura, pCodComiGastoCobranza, pCodComisionAnualidad, pCodComiDisposicionEfect, pCodComiAclaracionNo, pCodComiLiquidacionAntic, pGarantias, pIdGarantia, pPorcentajeAforo, pObligadoSolidario, pNumObligados, pCapturaObligatoria, pMontoMinDisp, pMontoMaxDisp, pUsuario,
				pFormApliComiGasCob, pFormApliComiAper, pFormApliComiDispo, pFormApliComiAnual, pFormApliComiAclara, pFormApliComiLiqAnt);

		ELIF pBandera = '2' THEN -- ACTUALIZA

			UPDATE bdicred:"informix".tmp_sd_definicion SET
			monto_min_cred = pMontoMinCred,
			monto_max_cred = pMontoMaxCred,
			edad_min = pEdadMin,
			edad_max = pEdadMax,
			plazo_min_cred = pPlazoMinCred,
			plazo_max_cred = pPlazoMaxCred,
			id_frec_pago = pIdFrecPago,
			cobro_comision_anual = pCobroComisionAnual,
			comi_gasto_cobranza = pComiGastoCobranza,
			cobro_comis_apertura = pCobroComisApertura,
			comi_disposicion_efect = pComiDisposicionEfect,
			comi_aclaracion_no = pComiAclaracionNo,
			comi_liquidacion_antic = pComiLiquidacionAntic,
			cod_comision_apertura = pCodComisionApertura,
			cod_comi_gasto_cobranza = pCodComiGastoCobranza,
			cod_comision_anualidad = pCodComisionAnualidad,
			cod_comi_disposicion_efect = pCodComiDisposicionEfect,
			cod_comi_aclaracion_no = pCodComiAclaracionNo,
			cod_comi_liquidacion_antic = pCodComiLiquidacionAntic,
			garantias = pGarantias,
			idgarantia = pIdGarantia,
			porcentajeaforo = pPorcentajeAforo,
			obligado_solidario = pObligadoSolidario,
			num_obligados = pNumObligados,
			captura_obligatoria = pCapturaObligatoria,
			monto_min_disp = pMontoMinDisp,
			monto_max_disp = pMontoMaxDisp,
			formapli_comigascob = pFormApliComiGasCob,
			formapli_comiaper = pFormApliComiAper,
			formapli_comidispo = pFormApliComiDispo,
			formapli_comianual = pFormApliComiAnual,
			formapli_comiaclara = pFormApliComiAclara,
			formapli_comiliqant = pFormApliComiLiqAnt
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;


		ElIF pBandera = '3' THEN -- ELIMINA

			DELETE FROM bdicred:"informix".tmp_sd_definicion
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;

		ElIF pBandera = '4' THEN -- CONSULTA

			SELECT num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect,
				comi_aclaracion_no, comi_liquidacion_antic, cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias,
				idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, monto_min_disp, monto_max_disp, formapli_comigascob, formapli_comiaper, formapli_comidispo, formapli_comianual, formapli_comiaclara, formapli_comiliqant
			INTO cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect,
				iComiAclaracionNo, iComiLiquidacionAntic, cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias,
				iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp, cFormApliComiGasCob, cFormApliComiAper, cFormApliComiDispo, cFormApliComiAnual, cFormApliComiAclara, cFormApliComiLiqAnt
			FROM bdicred:"informix".tmp_sd_definicion
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;

		ElIF pBandera = '5' THEN -- ALMACENA
			SELECT num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect,
				comi_aclaracion_no, comi_liquidacion_antic, cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias,
				idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria
			INTO cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect,
				iComiAclaracionNo, iComiLiquidacionAntic, cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias,
				iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria
			FROM bdicred:"informix".tmp_sd_definicion
			WHERE empresa = cEmpresa AND num_producto = pNumProducto AND usuario_insert = pUsuario;

			INSERT INTO bdicred:"informix".sd_definicion(empresa, num_producto, cod_tipcred, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura, comi_disposicion_efect, comi_aclaracion_no, comi_liquidacion_antic,
				cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_aclaracion_no, cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria)
			VALUES(cEmpresa, cNumProducto, '', dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria);

		END IF;


		RETURN cCodRet, cNumProducto, dMontoMinCred, dMontoMaxCred, iEdadMin, iEdadMax, iPlazoMinCred, iPlazoMaxCred, iIdFrecPago, cCobroComisionAnual, iComiGastoCobranza, cCobroComisApertura, iComiDisposicionEfect, iComiAclaracionNo, iComiLiquidacionAntic,
				cCodComisionApertura, cCodComiGastoCobranza, cCodComisionAnualidad, cCodComiDisposicionEfect, cCodComiAclaracionNo, cCodComiLiquidacionAntic, iGarantias, iIdGarantia, dPorcentajeAforo, cObligadoSolidario, cNumObligados, cCapturaObligatoria, dMontoMinDisp, dMontoMaxDisp,
				cFormApliComiGasCob, cFormApliComiAper, cFormApliComiDispo, cFormApliComiAnual, cFormApliComiAclara, cFormApliComiLiqAnt;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los productos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_conspoliticacreditoprod(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumProducto CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS Num_Producto,
				CHAR(1) AS Respuesta_Sic,
				CHAR(50) AS modelo,
				CHAR(1) AS Grupo,
				INTEGER AS ScoreMin_grupo1,
				INTEGER AS ScoreMax_grupo1,
				INTEGER AS ProScoreMin_grupo1,
				INTEGER AS ProScoreMax_grupo1,
				CHAR(2) AS Status_Sol;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRetSp 			CHAR(5);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cEmpresa				CHAR(3);
	DEFINE cNumProducto			CHAR(4);
	DEFINE cRespuestaSic		CHAR(1);
	DEFINE cGrupo				CHAR(1);
	DEFINE cModelo				CHAR(50);
	DEFINE cStatusSol			CHAR(2);
	DEFINE iBcScoreMin1			INTEGER;
	DEFINE iBcScoreMax1			INTEGER;
	DEFINE iProScoreMin1		INTEGER;
	DEFINE iProScoreMax1		INTEGER;
	DEFINE iRecuperacion 		INTEGER;

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cEmpresa				= '001';
	LET cNumProducto			= '';
	LET cRespuestaSic			= '';
	LET cGrupo					= '';
	LET cModelo					= '';
	LET cStatusSol				= '';
	LET iBcScoreMin1			= 0;
	LET iBcScoreMax1			= 0;
	LET iProScoreMin1			= 0;
	LET iProScoreMax1			= 0;
	LET iRecuperacion 			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_conspoliticacreditoprod.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_conspoliticacreditoprod(cEmpresa, pNumProducto, pRegistros, pRecuperacion)
			INTO cCodRetSp, cNumProducto, cRespuestaSic, cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol WITH RESUME;

		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumProducto, cRespuestaSic, cModelo, cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1, cStatusSol;
		END IF;	

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar politicas del producto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cred_consultafrecpago(pUsuario CHAR(8), pIdFuncion CHAR(10), pValor CHAR(2), pTipoPago VARCHAR(20), pNumProducto CHAR(4), pTipoEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret,
				CHAR(2) AS Valor,
				VARCHAR(20) AS TipoPago;

	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	DEFINE cValor 				 CHAR(2);
	DEFINE cTipoPago 			 VARCHAR(20);

	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cValor 					= '';
	LET cTipoPago 				= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor, cTipoPago;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cred_consultafrecpago.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor, cTipoPago;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor, cTipoPago;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH

			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_frecpago(pValor, pTipoPago, pNumProducto, pTipoEjecucion)
			INTO cCodRetSp, cValor, cTipoPago

			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_consulta_frecpago";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cValor, cTipoPago;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cValor, cTipoPago;
			END IF;

			RETURN cCodRet, cValor, cTipoPago WITH RESUME;

		END FOREACH;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de consultar los tipos de pago',
'BD: bdicnweb',
'FECHA: 30/11/2020',
'DESCRIPCION: Se realiza ajuste a procedimiento para agregar un nuevo parametro de entrada y para tratamiento de error 00002';

CREATE PROCEDURE "informix".sp_cred_insertaproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFamilia CHAR(3), pNum_Producto CHAR(4), pNomb_Producto CHAR(40), psub_producto INTEGER)
		RETURNING CHAR(5) AS codret; 
		
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE cEmpresa     CHAR(3);
    
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET cEmpresa 		= '001';  	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_cred_insertaproductos_2021.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFamilia = '' OR pNum_Producto = ''  OR pNomb_Producto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_inserta_productos(cEmpresa, pUsuario, pFamilia, pNum_Producto, pNomb_Producto, psub_producto)
		INTO cCodRetSp;
		
			
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_inserta_productos";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
			
		RETURN cCodRet;
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Taller de Productos',
'DESCRIPCION: SPL encargado de insertar los productos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_detsolicitudeslincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion SMALLINT, pTipoSolicitud CHAR(2),
pNumSolicitud CHAR(20), pNumCliente CHAR(20), pFechaInicio DATE, pFechaFin DATE, pEstatus CHAR(2), pProducto CHAR(4), pCveGrupo CHAR(2), 
pSegmento CHAR(2), pEtiqueta CHAR(2), pAnalista CHAR(8), pComentario CHAR(100), pTramaEjecucion CHAR(250), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(30) AS tipo_solicitud,
		CHAR(20) AS num_solicitud,
		DATE AS fecha,
		DATETIME HOUR TO FRACTION AS hora,
		CHAR(20) AS cliente,
		CHAR(2) AS estatus,
		CHAR(100) AS comentario,
		INTEGER AS total_registros,
		CHAR(2) AS cve_grupo,
		CHAR(2) AS segmento,
		CHAR(2) AS etiqueta,
		CHAR(4) AS producto,
		CHAR(1) AS tipo_mov,
		CHAR(1) AS en_proceso,
		INTEGER AS id_registro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoSolicitud CHAR(30);
	DEFINE cNumsolicitud CHAR(20);
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION;
	DEFINE cCliente CHAR(20);
	DEFINE cEstatus CHAR(2);
	DEFINE cComentario CHAR(100);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cClaveGrupo CHAR(2);
	DEFINE cSegmento CHAR(2);
	DEFINE cEtiqueta CHAR(2);
	DEFINE iIdRegistro INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cPuesto CHAR(2);
	DEFINE cEnProceso CHAR(1);
	DEFINE cProducto CHAR(4);
	DEFINE cTipoMov CHAR(1);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cTipoSolicitud = '';
	LET cNumsolicitud = '';
	LET dFecha = '';
	LET dHora = '';
	LET cCliente = '';
	LET cEstatus = '';
	LET cComentario = '';
	LET iTotalRegistros = 0;
	LET cClaveGrupo = '';
	LET cSegmento = '';
	LET cEtiqueta = '';
	LET iIdRegistro = 0;
	LET dFechaHoy = DATE(CURRENT);
	LET cPuesto = '';
	LET cEnProceso = '';
	LET cProducto = '';
	LET cTipoMov = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_detsolicitudeslincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion IS NULL OR pTipoSolicitud = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEjecucion = 1 THEN
		
			SELECT DISTINCT puesto INTO cPuesto FROM bdicred:"informix".sd_perfiles_cac_aumlincred WHERE ejecutivo = pUsuario;
			
			IF (NVL(cPuesto,'') IN ('01','03','04')) AND pNumSolicitud = '' AND pNumCliente = '' THEN
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion tipo_solicitud, num_solicitud, fecha, hora, cliente, estatus, comentario, 
					total_registros, clave_grupo, segmento, etiqueta, producto, tipo_mov, id_serial
					INTO cTipoSolicitud, cNumSolicitud, dFecha, dHora, cCliente, cEstatus, cComentario, 
					iTotalRegistros, cClaveGrupo, cSegmento, cEtiqueta, cProducto, cTipoMov, iIdRegistro
					FROM bdicnweb:"informix".sw_buro_conslineacred
					WHERE UPPER(TRIM(comentario)) <> 'EN PROCESO DE CONSULTA'
					AND usuario_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy ORDER BY id_serial ASC
					--WHERE LOWER(TRIM(comentario)) <> LOWER('En proceso de Consulta')
				
					IF EXISTS(SELECT 1 FROM bdicnweb:"informix".sw_buro_cteprocesando 
							  WHERE num_cliente = cCliente AND num_solicitud = cNumSolicitud AND user_insert <> pUsuario) THEN
						LET cEnProceso = '1';
					ELSE
						LET cEnProceso = '0';
					END IF;

					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,UPPER(cTipoSolicitud),cNumSolicitud,dFecha,dHora,cCliente,cEstatus,UPPER(cComentario),iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,NVL(cProducto,''),NVL(cTipoMov,''),cEnProceso,iIdRegistro WITH RESUME;
				END FOREACH;
				
			ELSE 
			
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
			
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion tipo_solicitud, num_solicitud, fecha, hora, cliente, estatus, comentario, 
					total_registros, clave_grupo, segmento, etiqueta, producto, tipo_mov, id_serial
					INTO cTipoSolicitud, cNumSolicitud, dFecha, dHora, cCliente, cEstatus, cComentario, 
					iTotalRegistros, cClaveGrupo, cSegmento, cEtiqueta, cProducto, cTipoMov, iIdRegistro
					FROM bdicnweb:"informix".sw_buro_conslineacred
					WHERE usuario_insert = TRIM(pUsuario) AND fecha_insert = dFechaHoy ORDER BY id_serial ASC
				
					IF EXISTS(SELECT 1 FROM bdicnweb:"informix".sw_buro_cteprocesando 
							  WHERE num_cliente = cCliente AND num_solicitud = cNumSolicitud AND user_insert <> pUsuario) THEN
						LET cEnProceso = '1';
					ELSE
						LET cEnProceso = '0';
					END IF;
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,UPPER(cTipoSolicitud),cNumSolicitud,dFecha,dHora,cCliente,cEstatus,UPPER(cComentario),iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,NVL(cProducto,''),NVL(cTipoMov,''),cEnProceso,iIdRegistro WITH RESUME;

				END FOREACH;
				
			END IF;			
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,cProducto,cTipoMov,cEnProceso,iIdRegistro;
			END IF;
		
		--ELSE
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 22/11/2016',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÓN DE LOS ENVÍOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar el detalle de las solicitudes de los envíos a BC y CC.',
'AUTOR: L. Montserrat León Amador',
'FECHA 01/02/2017',
'DESCRIPCION: Se modifica SPL para agregar filtro por usuario_insert al momento de hacer consultas y/o fectaciones a la tabla sw_buro_conslineacred.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_adm_consultabitacora_usuarios(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdUsuario CHAR(8), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING
		CHAR(5) AS codret,
		CHAR(8) AS usuario,
		CHAR(150) AS nombreUusuario,
		CHAR(1) AS idStatus,
		CHAR(10) AS descStatus,
		CHAR(200) AS movimiento,
		DATE AS fechaMovimiento;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE vIdUsuario CHAR(8);
	DEFINE cNombreUusuario CHAR(150);
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	DEFINE cMovimiento CHAR(200);
	DEFINE dFechaMovimiento DATE;
	DEFINE iRecuperacion INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iTotales = 0;
	LET vIdUsuario = '';
	LET cNombreUusuario = '';
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET cMovimiento = '';
	LET dFechaMovimiento = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_adm_consultabitacora_usuarios.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdUsuario = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pStatus = '' THEN
			FOREACH
				SELECT {+INDEX (bdirst:bitacora idx_bitacora)}  SKIP pRegistros FIRST pRecuperacion T1.id_usuario , T2.nombre, T1.status, DECODE(T1.status, '1', 'ACTIVO', '0', 'INACTIVO'), T3.bit_accion, T3.bit_alta_fecha
				INTO vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento
				FROM bdinteg:"informix".si_seg_usuarios AS T1
				INNER JOIN bdinteg:"informix".si_ejecut AS T2 ON T2.ejecutivo = T1.id_usuario
				INNER JOIN bdirst:"informix".bitacora AS T3 ON T1.id_usuario = T3.bit_usu_id_fk::VARCHAR(8)
				WHERE T1.id_usuario = pIdUsuario 
				AND T3.bit_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento WITH RESUME;
			END FOREACH;
		ELSE 
			FOREACH
				SELECT {+INDEX (bdirst:bitacora idx_bitacora)}  SKIP pRegistros FIRST pRecuperacion T1.id_usuario , T2.nombre, T1.status, DECODE(T1.status, '1', 'ACTIVO', '0', 'INACTIVO'), T3.bit_accion, T3.bit_alta_fecha
				INTO vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento
				FROM bdinteg:"informix".si_seg_usuarios AS T1
				INNER JOIN bdinteg:"informix".si_ejecut AS T2 ON T2.ejecutivo = T1.id_usuario
				INNER JOIN bdirst:"informix".bitacora AS T3 ON T1.id_usuario = T3.bit_usu_id_fk::VARCHAR(8)
				WHERE T1.id_usuario = pIdUsuario 
				AND T3.bit_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				AND T1.status = pStatus
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento WITH RESUME;
				
			END FOREACH;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, vIdUsuario, cNombreUusuario, cIdStatus, cDescStatus, cMovimiento, dFechaMovimiento;
		END IF;	
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: REPORTE BITACORA USUSARIOS',
'DESCRIPCION: SP encargado de obtener la informaciÃ³n de la tabla bitacora',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_adm_consultabitacora_usuarios_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdUsuario CHAR(8), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1))
	RETURNING
		CHAR(5) AS codret,
		INTEGER AS numRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iTotales = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_adm_consultabitacora_usuarios.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdUsuario = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pStatus = '' THEN
			SELECT {+INDEX (bdirst:bitacora idx_bitacora)} COUNT(*) INTO iTotales
			FROM bdinteg:"informix".si_seg_usuarios AS T1
			INNER JOIN bdinteg:"informix".si_ejecut AS T2 ON T2.ejecutivo = T1.id_usuario
			INNER JOIN bdirst:"informix".bitacora AS T3 ON T1.id_usuario = T3.bit_usu_id_fk::VARCHAR(8)
			WHERE T1.id_usuario = pIdUsuario 
			AND T3.bit_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		ELSE 
			SELECT {+INDEX (bdirst:bitacora idx_bitacora)} COUNT(*) INTO iTotales
			FROM bdinteg:"informix".si_seg_usuarios AS T1
			INNER JOIN bdinteg:"informix".si_ejecut AS T2 ON T2.ejecutivo = T1.id_usuario
			INNER JOIN bdirst:"informix".bitacora AS T3 ON T1.id_usuario = T3.bit_usu_id_fk::VARCHAR(8)
			WHERE T1.id_usuario = pIdUsuario 
			AND T3.bit_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
			AND T1.status = pStatus;
		END IF;
		
		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: REPORTE BITACORA USUSARIOS',
'DESCRIPCION: SP encargado de obtener el total de registros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_adm_validacampos(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pCampo CHAR(100))
	RETURNING CHAR(5) AS codRet,
		CHAR(150) AS nomCliente;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE cNomCliente CHAR(150);
	DEFINE cExiste CHAR(20);
	DEFINE cCampo CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);

	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cCampo = TRIM(pCampo);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;
	LET cNomCliente = '';
	LET cExiste = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomCliente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_adm_validacampos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pCampo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomCliente;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomCliente;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
		
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) INTO iTotales 
			FROM bdirst:"informix".claves_retiro WHERE cr_foliooperacion = cCampo;
			
			IF NVL(iTotales,0) = 0 THEN
				LET cCodRet = '99999';
			END IF;
			
		ELIF pBandera = '2' THEN 
		
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} DISTINCT(CR.cr_cliente) AS iExiste
			INTO cExiste
			FROM bdinteg:"informix".si_cliente AS CL
			INNER JOIN bdirst:"informix".claves_retiro AS CR ON CL.numcte = CR.cr_cliente 
			WHERE CR.cr_cliente = cCampo;
			
			IF NVL(cExiste,0) = 0 THEN
				LET cCodRet = '00088';
			ELSE
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} FIRST 1 nombre1, nombre2, apell_paterno, apell_materno
				INTO cNombre1, cNombre2, cApell_paterno, cApell_materno
				FROM bdinteg:"informix".si_cliente AS CL
				INNER JOIN bdirst:"informix".claves_retiro AS CR ON CL.numcte = CR.cr_cliente 
				WHERE CR.cr_cliente = cCampo;
				
				LET cNomCliente = TRIM(cNombre1)||' '||TRIM(cNombre2)||' '||TRIM(cApell_paterno)||' '||TRIM(cApell_materno);
			END IF;
			
		ELIF pBandera = '3' THEN 
			
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) INTO iTotales 
			FROM bdirst:"informix".claves_retiro WHERE TRIM(cr_cuenta) = cCampo;
			
			IF NVL(iTotales,0) = 0 THEN
				LET cCodRet = '99999';
			END IF;
			
		ELIF pBandera = '4' THEN 
			
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) INTO iTotales 
			FROM bdirst:"informix".claves_retiro WHERE cr_tarjeta = cCampo;
			
			IF NVL(iTotales,0) = 0 THEN
				LET cCodRet = '99999';
			END IF;
			
		ELSE
			LET cCodRet = '99999';
		END IF	

		RETURN cCodRet, cNomCliente;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: CONSULTA CLAVES RETIROS',
'DESCRIPCION: SPL encargado de consular si existe en la tabla claves_retiro: cliente, cuenta, tarjeta o folio de operacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancela_detalle_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), pFoliooperacion CHAR(100), pIp CHAR(20))
	RETURNING
		CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE crespaldo CHAR(50);
	DEFINE iExiste INTEGER;
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAccion = 'CANCELACION CLAVE RETIRO';
	LET cEntidad = 'claves_retiro';
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/informix/calizarraga/sp_cancela_detalle_retiro.out';
		 --TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFoliooperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		LET cCmd1 ="";	
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'cr_id', 'cr_alta_fecha', 'cr_ultima_mod_fecha', 'cr_status', 'cr_transaction_id', 'cr_foliooperacion', 'cr_canal_inicial', 'cr_canal_final', 'cr_cliente', 'cr_cuenta', 'cr_tarjeta,', 'cr_monto', ";
		LET cCmd1 =""||TRIM(cCmd1)||"'cr_modalidad', 'cr_concepto', 'cr_vigencia_fecha', 'cr_cajero', 'cr_aut_oper_retiro', 'cr_aut_oper_reverso', 'cr_codigoiso_retiro', 'cr_codigoiso_reverso', 'cr_cobrado_fecha','cr_canc_fecha', ";
		LET cCmd1 =""||TRIM(cCmd1)||"'cr_reverso_fecha', 'cr_rechazo_fecha' FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT cr_id::VARCHAR(20), cr_alta_fecha::VARCHAR(30), cr_ultima_mod_fecha::VARCHAR(30), cr_status, cr_transaction_id, cr_foliooperacion, cr_canal_inicial, cr_canal_final, cr_cliente, cr_cuenta, cr_tarjeta, ";
		LET cCmd1 =""||TRIM(cCmd1)||"cr_monto::VARCHAR(20), cr_modalidad, cr_concepto, cr_vigencia_fecha::VARCHAR(30), cr_cajero, cr_aut_oper_retiro, cr_aut_oper_reverso, cr_codigoiso_retiro, cr_codigoiso_reverso, cr_cobrado_fecha::VARCHAR(30), ";
		LET cCmd1 =""||TRIM(cCmd1)||"cr_canc_fecha::VARCHAR(30), cr_reverso_fecha::VARCHAR(30), cr_rechazo_fecha::VARCHAR(30) FROM bdirst:""informix"".claves_retiro WHERE cr_foliooperacion = '"||trim(pFoliooperacion)||"')";
		
		EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
		IF cCodRet = '00000' THEN 
			EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
			
			UPDATE bdirst:"informix".claves_retiro
			SET cr_status = 'X'
			WHERE cr_foliooperacion = pFoliooperacion;
		END IF;

		RETURN cCodRet;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 18/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: CANCELACION DE DETALLE RETIRO',
'DESCRIPCION: SPL para la cancelacion de un detalle retiro detalle del retiro',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_cat_status_combo(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS cdret,
			CHAR(2) AS id_status,
			CHAR(30) AS desc_status,
			CHAR(2) AS cve_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cId_status CHAR(2);
	DEFINE cDesc_status CHAR(30);
	DEFINE cCve_Status CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	
	LET cId_status = '';
	LET cDesc_status = '';
	LET cCve_Status = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_status_combo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT {+INDEX (bdirst:cat_status idx_cat_status)} SKIP pRegistros FIRST pRecuperacion cat_id_status, cat_descripcion_status, cat_cod_status 
			INTO cId_status, cDesc_status, cCve_Status
			FROM bdirst: "informix".cat_status
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cId_status, cDesc_status, cCve_Status;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 27/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: âREPORTE DE CANTIDADES DE CLAVES DERETIRO',
'DESCRIPCION: SPL encargado de consular el combo parametros status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cat_status_combo_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS cdret,
		INTEGER AS totales;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotsles INTEGER;
	
	DEFINE cId_status CHAR(2);
	DEFINE cDesc_status CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotsles = 0;
	
	LET cId_status = '';
	LET cDesc_status = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotsles;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_status_combo_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotsles;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotsles;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdirst:cat_status idx_cat_status)} COUNT(*) 
		INTO iTotsles 
		FROM bdirst: "informix".cat_status;
			
		IF iTotsles = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotsles;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 27/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: REPORTE DE CANTIDADES DE CLAVES DERETIRO',
'DESCRIPCION: SPL encargado de consular el combo parametros status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cat_statususuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS cdret,
			CHAR(2) AS id_status,
			CHAR(10) AS desc_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cId_status CHAR(2);
	DEFINE cDesc_status CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	
	LET cId_status = '';
	LET cDesc_status = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cId_status, cDesc_status;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_statususuario.out';
		--*TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId_status, cDesc_status;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId_status, cDesc_status;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT {+INDEX (bdinteg:si_seg_usuarios idxsegidusu)} DISTINCT (status) 
			INTO cId_status
			FROM bdinteg:si_seg_usuarios
			
			IF cId_status = '1' THEN 
				LET cDesc_status = 'ACTIVO';
			ELIF cId_status = '0' THEN
				LET cDesc_status = 'INACTIVO';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cId_status, cDesc_status WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cId_status, cDesc_status;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: REPORYE BITACORA USUARIOS',
'DESCRIPCION: SPL encargado de consular el combo estatus del usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_claves_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(19), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pIp CHAR(20),
	pRegistros INTEGER, pRecuperacion INTEGER )

		RETURNING
		CHAR(5) AS codret,
		CHAR(100) AS Foliooperacion,
		DATE AS AltaFecha,
		CHAR(20) AS Cliente,
		CHAR(20) AS Cuenta,
		CHAR(20) AS Tarjeta,
		MONEY(16,2) AS Monto,
		CHAR(1) AS  Status,
		CHAR(40) AS DescStatus,
		CHAR(10) AS canalGeneracion,
		CHAR(10) AS canalCobro;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cFoliooperacion CHAR(100);
	DEFINE dAltaFecha DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE cMonto INTEGER;
	DEFINE cStatus CHAR(2);
	DEFINE cDescStatus CHAR(40);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE vCanalGeneracion CHAR(10);
	DEFINE vCanalCobro CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cFoliooperacion ='';
	LET dAltaFecha = '';
	LET cCliente ='';
	LET cCuenta ='';
	LET cTarjeta ='';
	LET cMonto = 0;
	LET cStatus ='';
	LET cDescStatus ='';
	LET cAccion = 'CONSULTA CLAVES DE RETIRO';
	LET cEntidad = 'claves_retiro';
	LET vCanalGeneracion = '';
	LET vCanalCobro = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto, cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_claves_retiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END IF;
		
		IF NVL(pFecha_inicial,'') = '' AND NVL(pFecha_final,'') = '' THEN
		
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion
				cr.cr_foliooperacion, cr.cr_alta_fecha, cr.cr_cliente, cr.cr_cuenta, cr.cr_tarjeta, cr.cr_monto,  cr.cr_status, cs.cat_descripcion_status, cr.cr_canal_inicial, cr.cr_canal_final
				INTO cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
				WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr_foliooperacion ELSE pFoliooperacion END
				AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END 
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END 
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
					
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro WITH RESUME;

			END FOREACH;
			
		ELSE 
			
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion
				cr.cr_foliooperacion, cr.cr_alta_fecha, cr.cr_cliente, cr.cr_cuenta, cr.cr_tarjeta, cr.cr_monto,  cr.cr_status, cs.cat_descripcion_status, cr.cr_canal_inicial, cr.cr_canal_final
				INTO cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
				WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr_foliooperacion ELSE pFoliooperacion END
				AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END 
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END 
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
				AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
					
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro WITH RESUME;

			END FOREACH;
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFoliooperacion, dAltaFecha, cCliente, cCuenta, cTarjeta, cMonto,  cStatus, cDescStatus, vCanalGeneracion, vCanalCobro;
		END IF;	
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Consulta de Claves de Retiro',
'DESCRIPCION: SPL encargado de extraer informaciÃ³n en tabla claves_retiro',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/01/2021',
'DESCRIPCION:Se realiza ajuste a procedimiento para colocar los parametros Fecha Inicio y Fecha fin como opcionales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_claves_retiro_totales( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(19), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1))
	RETURNING
	CHAR(5) AS codret,
	INTEGER AS numRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_claves_retiro_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pFecha_inicial,'') = '' AND NVL(pFecha_final,'') = '' THEN
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) INTO iNoRegistros
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr_foliooperacion ELSE pFoliooperacion END
			AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END 
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END 
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END;
		ELSE
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) INTO iNoRegistros
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr_foliooperacion ELSE pFoliooperacion END
			AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END 
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END 
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
			AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Consulta Claves de Retiro',
'DESCRIPCION: SPL encargado de obtener el total de registro de la tabla claves_retiro',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para colocar los parametros Fecha Inicio y Fecha fin como opcionales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_reporte_cantidades_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pOpcionCanal CHAR(1), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20))
	RETURNING
		CHAR(5) AS codret,
		INTEGER AS totRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iTotales = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_reporte_cantidades_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcionCanal = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcionCanal = '1' THEN
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS TOTALES
			INTO iTotales
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
			INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
			WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
			AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		ELIF pOpcionCanal = '2' THEN 
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS TOTALES
			INTO iTotales
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
			INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
			WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
			AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final;
		END IF;
		
		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Reporte de CancelaciÃ³n Claves Retiro',
'DESCRIPCION: SPL encargado de obtener el total del reporte cantidades totales.',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 30/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para devolver las descripciones de Canal de Cobro y Canal de GeneraciÃ³n dependiendo de la opciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detalle_clave_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), pFoliooperacion CHAR(100))

	RETURNING
		CHAR(5) AS codret,
		CHAR (2) AS status,
		CHAR (40) AS descripcionStatus,
		CHAR (100) AS foliooperacion, 
		DATE AS alta_fecha, 
		DATE AS ultima_mod_fecha, 
		CHAR (20) AS cliente, 
		CHAR (20) AS cuenta, 
		CHAR (20) AS tarjeta, 
		MONEY AS monto, 
		CHAR (45) AS concepto, 
		CHAR (1) AS modalidad;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;

	DEFINE cCr_status CHAR(20);
	DEFINE cDes_status CHAR(20);
	DEFINE cFoliooperacion CHAR(6);
	DEFINE dAlta_fecha DATE;
	DEFINE dUltima_mod_fecha DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE iMonto INTEGER;
	DEFINE cConcepto CHAR(45);
	DEFINE cModalidad CHAR(1);
	
	LET cCr_status = '';
	LET cDes_status = '';
	LET cFoliooperacion = '';
	LET dAlta_fecha = '';
	LET dUltima_mod_fecha = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET iMonto = 0;
	LET cConcepto = '';
	LET cModalidad = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detalle_clave_retiro.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFoliooperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT cr_status, cr_foliooperacion, cr_alta_fecha,cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
		INTO cCr_status , cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad , cDes_status
		FROM  bdirst:"informix".claves_retiro as cr
		inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
		WHERE cr_foliooperacion = pFoliooperacion;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad;
		
	END;

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 26/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: DETALLE DE OPERACION',
'DESCRIPCION: SPL obtener detalle de CLAVES DE RETIRO',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_detalle_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), pFoliooperacion CHAR(100), pStatus CHAR(2) )

	RETURNING
		CHAR(5) AS codret,
		CHAR (2) AS status,
		CHAR (40) AS descripcionStatus,
		CHAR (100) AS foliooperacion, 
		DATE AS alta_fecha, 
		DATE AS ultima_mod_fecha, 
		CHAR (20) AS cliente, 
		CHAR (20) AS cuenta, 
		CHAR (20) AS tarjeta, 
		MONEY AS monto, 
		CHAR (45) AS concepto, 
		CHAR (1) AS modalidad,
		CHAR (8) AS cajero,
		CHAR (8) AS aut_oper_retiro,
		DATE AS cobrado_fecha,
		DATE AS rechazo_fecha,
		CHAR (2) AS codigoiso_reverso,
		DATE AS canc_fecha;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;

	DEFINE cCr_status CHAR(20);
	DEFINE cDes_status CHAR(20);
	DEFINE cFoliooperacion CHAR(100);
	DEFINE dAlta_fecha DATE;
	DEFINE dUltima_mod_fecha DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE iMonto INTEGER;
	DEFINE cConcepto CHAR(45);
	DEFINE cModalidad CHAR(1);
	DEFINE cCajero CHAR(8);
	DEFINE cAut_oper_retiro CHAR(8);
	DEFINE dCobrado_fecha DATE;
	DEFINE dRechazo_fecha DATE;
	DEFINE cCodigoiso_reverso CHAR(2);
	DEFINE dCanc_fecha DATE;

	LET cCr_status = '';
	LET cDes_status = '';
	LET cFoliooperacion = '';
	LET dAlta_fecha = '';
	LET dUltima_mod_fecha = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET iMonto = 0;
	LET cConcepto = '';
	LET cModalidad = '';
	LET cCajero = '';
	LET cAut_oper_retiro = '';
	LET dCobrado_fecha = '';
	LET dRechazo_fecha = '';
	LET cCodigoiso_reverso = '';
	LET dCanc_fecha = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_sistema.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFoliooperacion = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pFoliooperacion = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		END IF;

		--Pantalla Detalle de Consulta de Retiro.--
		IF pStatus = 'P' AND pFoliooperacion <> ''  THEN
			-- Estatus: X Cobrar -- 
			SELECT
			cr_status, cr_foliooperacion, cr_alta_fecha, cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
			INTO 
			cCr_status,cFoliooperacion, dAlta_fecha, dUltima_mod_fecha, cCliente, cCuenta, cTarjeta, iMonto, cConcepto, cModalidad, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			--  AND cr_status = 'P';
		END IF;
		
		IF pStatus = 'V' AND pFoliooperacion <> '' THEN
			-- Estatus: Vencido -- 
			SELECT 
			cr_status, cr_foliooperacion, cr_alta_fecha, cr_ultima_mod_fecha, cr_cliente, cr_cuenta, cr_tarjeta, cr_monto, cr_concepto, cr_modalidad, cs.cat_descripcion_status
			INTO
			cCr_status, cFoliooperacion, dAlta_fecha, dUltima_mod_fecha, cCliente, cCuenta, cTarjeta, iMonto, cConcepto, cModalidad, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			--  AND cr_status = 'V';
		END IF;

		IF pStatus = 'X' AND pFoliooperacion <> '' THEN
			-- Estatus: Cancelado -- 
			SELECT
			cr_status, cr_ultima_mod_fecha, cs.cat_descripcion_status
			INTO
			cCr_status, dUltima_mod_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'X';
		END IF;

		IF pStatus = 'C' AND pFoliooperacion <> '' THEN
			-- Estatus: Cobrado -- 
			SELECT 
			cr_status, cr_foliooperacion, cr_cajero, cr_aut_oper_retiro, cr_cobrado_fecha, cs.cat_descripcion_status
			INTO
			cCr_status, cFoliooperacion, cCajero, cAut_oper_retiro, dCobrado_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'C';
		END IF;

		IF pStatus = 'R' AND pFoliooperacion <> '' THEN
			-- Estatus: Rechazado -- 
			SELECT 
			cr_status, cr_cajero, cr_rechazo_fecha, cr_codigoiso_reverso, cs.cat_descripcion_status
			INTO
			cCr_status, cCajero, dRechazo_fecha, cCodigoiso_reverso, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'R';
		END IF;

		IF pStatus = 'T' AND pFoliooperacion <> '' THEN
			-- Estatus: Transito --
			-- preguntar a Bancoppel si se va a ocupar el Estatus T	
			SELECT
			cr_status, cr_canc_fecha, cs.cat_descripcion_status
			INTO 
			cCr_status, dCanc_fecha, cDes_status
			FROM  bdirst:"informix".claves_retiro as cr
			inner join bdirst:"informix".cat_status as cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr_foliooperacion = pFoliooperacion;
			-- AND cr_status = 'T';
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cCr_status ,cDes_status ,cFoliooperacion ,dAlta_fecha ,dUltima_mod_fecha ,cCliente ,cCuenta ,cTarjeta ,iMonto,cConcepto ,cModalidad ,cCajero ,cAut_oper_retiro ,dCobrado_fecha ,dRechazo_fecha ,cCodigoiso_reverso ,dCanc_fecha;
		
	END;

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 18/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL obtener el detalle del retiro',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_generararchivo_rst(pNombreArchivo CHAR(255), pCmdRespaldo CHAR(2000))
	RETURNING 
		CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSql CHAR(2500);
	DEFINE cArchivoTemp CHAR(50);
	DEFINE cRutaArchivo CHAR(255);
	DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = '';
	LET cSql = '';
	LET cArchivoTemp = 'query_'||TO_CHAR(CURRENT, '%d%m%Y')||'.sql';
	LET cRutaArchivo = '/RESPALDOSNEW/archivosRST/';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF ven_transacc = 1 THEN
				ROLLBACK;		
			END IF;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT;
			BEGIN;
		END EXCEPTION WITH RESUME;
		
		BEGIN;
		IF bInTransaction = 'f' THEN
			COMMIT;
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_generararchivo_rst.out';
		--TRACE ON;
		
		-- GENERACION DE ARCHIVO TXT

		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '''||TRIM(cRutaArchivo)||TRIM(pNombreArchivo)||'.txt'' DELIMITER '||'''	'' '||TRIM(pCmdRespaldo)||' " >  /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/ifxsif01/bin/dbaccess bdirst /tmp/mfinis/'||cArchivoTemp;
		--LET cSql = '/informix/bin/dbaccess bdirst /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf /tmp/mfinis/'||cArchivoTemp;
		SYSTEM TRIM(cSql);
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de generar archivo para respaldar la informaciÃ³n sobre la tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_retiros( pUsuario CHAR(8), pIdFuncion CHAR(10), pip CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(20) AS monto_minimo,
		CHAR(20) AS monto_maximo,
		CHAR(20) AS codigos_activos,
		CHAR(20) AS vigencia;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cMontominimo CHAR(20);
	DEFINE cMontomaximo CHAR(20);
	DEFINE cCodigosActivos CHAR(20);
	DEFINE cVigencia CHAR(20);
	
	DEFINE campo CHAR(20);
	DEFINE valorCampo CHAR(20);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
		
	LET cAccion = 'CONSULTA RETIRO SIN TARJETA';
	LET cEntidad = 'parametros_sistema';
	LET cIp = pip;
	
	LET cMontominimo = '';
	LET cMontomaximo = '';
	LET cCodigosActivos = '';
	LET cVigencia = '';
	
	LET campo = '';
	LET valorCampo = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_rertiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN
			FOREACH

				SELECT {+INDEX (bdirst:parametro_sistema idx_nombre_param)} par_nombre, par_valor INTO campo, valorCampo FROM bdirst:"informix".parametro_sistema WHERE par_status = 'A'

				IF campo = 'MONTO_MINIMO' THEN
					LET cMontominimo = valorCampo;
				END IF;
				IF campo = 'MONTO_MAXIMO' THEN
					LET cMontomaximo = valorCampo;
				END IF;
				IF campo = 'CODIGOS_ACTIVOS' THEN
					LET cCodigosActivos = valorCampo;
				END IF;
				IF campo = 'VIGENCIA' THEN
					LET cVigencia = valorCampo;
				END IF;
				
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '01222';
			ELIF NVL(cMontominimo,'') = '' AND NVL(cMontomaximo,'') = '' AND NVL(cCodigosActivos,'') = '' AND NVL(cVigencia,'') = '' THEN 
				LET cCodRet = '01222';
			END IF;
		
			RETURN cCodRet,cMontominimo,cMontomaximo,cCodigosActivos,cVigencia;
			
		END IF;
		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 26/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: PARAMETROS DE RETIRO',
'DESCRIPCION: SPL encargado de obtener el listado de parametros de retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_status( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS id_status,
		CHAR(1) AS cod_status,
		CHAR(30) AS descripcion_status;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cIdStatus CHAR(2);
	DEFINE cCodStatus CHAR(1);
	DEFINE cDescricpiconStatus CHAR(30);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
		
	LET cAccion = 'CONSULTA PARAMETROS STATUS';
	LET cEntidad = 'cat_status';
	LET cip = pip;
	LET crespaldo = '';
	
	LET cCodStatus = '';
	LET cDescricpiconStatus = '';
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdStatus, cCodStatus,cDescricpiconStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_status.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN 
			FOREACH
				SELECT cat_id_status, cat_cod_status, cat_descripcion_status 
				INTO cIdStatus, cCodStatus, cDescricpiconStatus 
				FROM bdirst: "informix".cat_status
				ORDER BY cat_id_status
				
				RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, cCodStatus,cDescricpiconStatus;
		END IF;	
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ParÃ¡metros de Estatus',
'DESCRIPCION: SPL encargado de extraer informaciÃ³n en tabla cat_status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_parametros_status_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_parametros_status_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst:"informix".cat_status;
		
		IF NVL(iTotales,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ParÃ¡metros de Estatus',
'DESCRIPCION: SPL encargado de obtener el total de registros sobre ls tsbls cat_status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporte_cantidades_claves_retiro(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pOpcionCanal CHAR(1), pFecha_inicial DATE, pFecha_final DATE, pStatus CHAR(1), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20), pIp CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING
		CHAR(5) AS codret,
		CHAR(20) AS canal_inicial,
		CHAR(20) AS desc_inicial,
		CHAR(20) AS canal_final,
		CHAR(20) AS desc_final,
		MONEY(16,2) AS monto;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCanalInicial CHAR(10);
	DEFINE cCanalFinal CHAR(10);
	DEFINE iMonto MONEY;
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cDescCanalInicial CHAR(50);
	DEFINE cDescCanalFinal CHAR(50);
	DEFINE mMonto MONEY(16,2);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCanalInicial = '';
	LET cCanalFinal = '';
	LET mMonto = 0;
	LET cAccion = 'CONSULTA CANTIDADES CLAVES RETIROS';
	LET cEntidad = 'claves_retiro';
	LET cDescCanalInicial = '';
	LET cDescCanalFinal = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_claves_retiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pOpcionCanal = ''OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcionCanal = '1' THEN
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_canal_inicial, ci.par_nombre_canal, cr.cr_canal_final, cf.par_nombre_canal, cr.cr_monto
				INTO cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
				INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
				WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
				AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto WITH RESUME;
			END FOREACH;
		ELIF pOpcionCanal = '2' THEN 
			FOREACH
				SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_canal_final, cf.par_nombre_canal, cr.cr_canal_inicial, ci.par_nombre_canal, cr.cr_monto
				INTO cCanalFinal, cDescCanalFinal, cCanalInicial, cDescCanalInicial, mMonto
				FROM bdirst:"informix".claves_retiro AS cr
				INNER JOIN bdirst:"informix".par_canal_final AS cf ON UPPER(cf.par_cve_canal_final) = UPPER(cr.cr_canal_final)
				INNER JOIN bdirst:"informix".par_canal_inicial AS ci ON UPPER(ci.par_cve_canal_inicial) = UPPER(cr.cr_canal_inicial)
				WHERE cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
				AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
				AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
				AND cr.cr_status = CASE WHEN pStatus = '' THEN cr.cr_status ELSE pStatus END
				AND cr.cr_alta_fecha BETWEEN pFecha_inicial AND pFecha_final
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto WITH RESUME;
			END FOREACH;
		END IF;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCanalInicial, cDescCanalInicial, cCanalFinal, cDescCanalFinal, mMonto;
		END IF;				
		
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Reporte de Cantidades de Retiro',
'DESCRIPCION: SPL encargado de extraer informaciÃ³n sobre tabla claves_retiro',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 29/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para devolver las descripciones de Canal de Cobro y Canal de GeneraciÃ³n dependiendo de la opciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bitacora(pAccion CHAR(50), pEntidad CHAR(100), pIp CHAR(20), pArchivoRespaldo CHAR(100), pUsuario CHAR(10), pBandera CHAR(1))
	RETURNING 
		CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE dAlta_Fecha DATE;
	DEFINE cOrigen CHAR(150);
	DEFINE last_bit_id INTEGER;
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE vBitEntidad CHAR(1);
	DEFINE cRutaArchivo CHAR(150);
	
	LET cCmd1 = '';
	LET cSql = '';
	LET dAlta_Fecha = CURRENT;
	LET cOrigen = 'RETIRO SIN TARJETA';
	LET cCodRet = '00000';
	LET vBitEntidad = '2';
	LET cRutaArchivo = '/RESPALDOSNEW/archivosRST/';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bitacora.out';
		--TRACE ON;
		
		SELECT MAX(bit_id) INTO last_bit_id FROM bdirst:"informix".bitacora;
		IF last_bit_id IS NULL THEN
			LET last_bit_id = 1;
		ELSE 
			LET last_bit_id = last_bit_id + 1;
		END IF;
		
		IF pBandera = 1 THEN
			INSERT INTO bdirst:"informix".bitacora (bit_id, bit_accion, bit_entidad, bit_alta_fecha, bit_id_entidad, bit_ip, bit_origen, bit_usu_id_fk) 
			VALUES(last_bit_id, pAccion, pEntidad, dAlta_Fecha, vBitEntidad, pIp, cOrigen, pUsuario);
		ELIF pBandera = 2 THEN 
		
			SELECT MAX(bit_id) INTO last_bit_id FROM bdirst:"informix".bitacora;
			IF last_bit_id IS NULL THEN
				LET last_bit_id = 1;
			ELSE 
				LET last_bit_id = last_bit_id + 1;
			END IF;
		
			INSERT INTO bdirst:"informix".bitacora (bit_id, bit_accion, bit_entidad, bit_alta_fecha, bit_id_entidad, bit_ip, bit_origen, respaldo, bit_usu_id_fk) 
			VALUES(last_bit_id, pAccion, pEntidad, dAlta_Fecha, vBitEntidad, pIp, cOrigen, FILETOBLOB(TRIM(cRutaArchivo)||TRIM(pArchivoRespaldo)||'.txt', 'server'), pUsuario);
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2021',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargdo de realizar la insercion en tabla bdirst:"informix".bitacora para registrar la operacion: select, update, delete',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_spei_ctasinretencion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pBandera CHAR(1))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		CHAR(10) AS usuario,
		CHAR(1) AS estatus,
		DATE as fecha_alt,
		DATE as fecha_baj;
		
	DEFINE cCodRet CHAR(5);	
	DEFINE cCuenta CHAR(20);
	DEFINE cUsuario CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE dFecha_alt DATE;
	DEFINE dFecha_baj DATE;
	DEFINE iSqlErr INTEGER;
	DEFINE cBandera CHAR(1);
	
	LET cCodRet = '00000';
	LET cCuenta  = '';
	LET cUsuario = '';
	LET cEstatus = '';
	LET dFecha_alt = DATE(1);
	LET dFecha_baj = DATE(1);
	LET iSqlErr = 0;
	LET cBandera = 0;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END EXCEPTION;
			
			
		--- SET ISOLATION TO CURSOR STABILITY;		
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_spei_ctasinretencion.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
		END IF;
		
		LET cBandera = pBandera;
		
		CASE cBandera
		
		--CASO 1 INDICA SI LA CUENTA EXISTE Y TRAE EL CAMPO DE ESTATUS'
		WHEN '1' THEN
			SELECT COUNT(*), estatus, fecha_alt,fecha_baj
			INTO cCuenta, cEstatus, dFecha_alt,dFecha_baj
			FROM bdicheq:"informix".sc_spei_cta_sin_retencion
			WHERE cuenta = pCuenta 
			GROUP BY estatus, fecha_alt,fecha_baj;
				
			IF cCuenta = 1 THEN
				LET cCuenta ='Verdadero';
			ELSE
				LET cCUenta ='Falso';
			END IF;
		
		--CASO 2 ACTUALIZA EL REGISTRO DE UNA CUENTA ACTIVA PARA DARLA DE BAJA Y ACTUALIZA LA FECHA EN QUE SE DIO DE BAJA
		WHEN '2' THEN 
			UPDATE bdicheq:"informix".sc_spei_cta_sin_retencion SET 
			estatus = 'B', 
			usuario =pUsuario, 
			fecha_baj = CURRENT 
			WHERE cuenta = pCuenta AND estatus = 'A';
		
		--CASO 3 ACTUALIZA EL REGISTRO DE UNA CUENTA INACTIVA PARA DARLA DE ALTA Y ACTUALIZA LA FECHA EN QUE SE DIO DE ALTA
		WHEN '3' THEN 
			UPDATE bdicheq:"informix".sc_spei_cta_sin_retencion SET 
			estatus = 'A', 
			usuario = pUsuario, 
			fecha_alt = CURRENT 
			WHERE cuenta = pCuenta AND estatus = 'B';
		
		--CASO 4 INSERTA UN REGISTRO NUEVO CON EL ESTATUS ACTIVO 'A' Y EL USUARIO QUE LO REGISTRO 
		WHEN '4' THEN 
			INSERT INTO bdicheq:"informix".sc_spei_cta_sin_retencion (cuenta,estatus,usuario,fecha_alt) 
			VALUES (pCuenta,'A',pUsuario,CURRENT);
		ELSE
	
		END CASE;	
		
		RETURN cCodRet,cCuenta,cUsuario,cEstatus,dFecha_alt,dFecha_baj;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes',
'FECHA: 29/12/2020',
'MODULO: EXCEPCION RETENIDOS SPEI | SOC',
'FUNCIONALIDAD: Nueva funcionalidad en el sistema SOC que permita agregar o quitar cuentas para excepciones de retenciÃ³n de saldo',
'DESCRIPCION: SPL encargado de Consultar-Dar de alta- Dar de baja cuentas sin retenciÃ³n para SPEI ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_detsolicitudeslincred_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion SMALLINT, pTipoSolicitud CHAR(2),
pNumSolicitud CHAR(20), pNumCliente CHAR(20), pFechaInicio DATE, pFechaFin DATE, pEstatus CHAR(2), pProducto CHAR(4), pCveGrupo CHAR(2), 
pSegmento CHAR(2), pEtiqueta CHAR(2), pAnalista CHAR(8), pComentario CHAR(100), pTramaEjecucion CHAR(250))
    RETURNING CHAR(5) AS codRet,
		INTEGER AS operaciones_enviadas,
		INTEGER AS operaciones_exitosas,
		CHAR(1) AS hay_errores,
		CHAR(2) AS estatus;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoSolicitud CHAR(30);
	DEFINE cNumsolicitud CHAR(20);
	DEFINE vNumsolicitud CHAR(20);
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION;
	DEFINE cCliente CHAR(20);
	DEFINE cEstatus CHAR(2);
	DEFINE cComentario CHAR(100);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cClaveGrupo CHAR(2);
	DEFINE cSegmento CHAR(2);
	DEFINE cEtiqueta CHAR(2);
	DEFINE dFechaHoy DATE;
	DEFINE cPuesto CHAR(2);
	DEFINE iNumRegistros INTEGER;
	
	DEFINE cIdRegistro CHAR(11);
	DEFINE iIdRegistro INTEGER;
	DEFINE iRegMixtos INTEGER;
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iTotalExitosas INTEGER;
	DEFINE cDescIdCodRet CHAR(100);
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cProducto CHAR(4);
	DEFINE cTipoMov CHAR(1);
	DEFINE cHayErrores CHAR(1);
	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cTipoSolicitud = '';
	LET cNumsolicitud = '';
	LET vNumsolicitud = '';
	LET dFecha = '';
	LET dHora = '';
	LET cCliente = '';
	LET cEstatus = '';
	LET cComentario = '';
	LET iTotalRegistros = 0;
	LET cClaveGrupo = '';
	LET cSegmento = '';
	LET cEtiqueta = '';
	LET dFechaHoy = DATE(CURRENT);
	LET cPuesto = '';
	LET iNumRegistros = 0;

	LET cIdRegistro = '';
	LET iIdRegistro = 0;
	LET iRegMixtos = 0;
	LET iTotalEnviadas = 0;
	LET iTotalExitosas = 0;
	LET cDescIdCodRet = '';
	LET dHoraHoy = CURRENT;
	LET cProducto = '';
	LET cTipoMov = '';
	LET cHayErrores = 'N';
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/gpe/sp_bccc_detsolicitudeslincred_totales.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				--SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
                SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				
				RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
			END IF;
		END EXCEPTION;
		

		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion IS NULL OR pTipoSolicitud = '' THEN
			LET cCodRet = '00003';
			
			--SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			--SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Consulta Grid
		IF pEjecucion = 1 THEN
		
			-- SE LIMPIA TABLA POR USUARIO VALIDACION DE ESTATUS DEL PROCESO 
            SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            DELETE FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario;
            
            -- SE INSERTA A TABLA PARA EL MONITOREO DEL ESTATUS DEL PROCESO
            SET LOCK MODE TO WAIT 3; 
            INSERT INTO bdicnweb:"informix".sw_buro_statusmonitorbccc(usuario,status,altas_total,total_exitosas,existe_error,estatus,error_proceso,error)
            VALUES(pUsuario, 'I', iTotalEnviadas, iTotalExitosas, cHayErrores, '', '', '');  
			
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM bdicnweb:"informix".sw_buro_conslineacred WHERE usuario_insert = pUsuario;
			
			-- SE LIMPIA TABLA POR USUARIO (PRODUCTIVA)
			SET LOCK MODE TO WAIT 3; 
			DELETE FROM bdicred:"informix".sd_numsolici_datos_tmp2 WHERE user_insert = pUsuario;
			
			FOREACH
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(1, pTipoSolicitud, pNumSolicitud, pNumCliente, 
				pFechaInicio, pFechaFin, pEstatus, pProducto, pCveGrupo, pSegmento, pEtiqueta, pUsuario, pComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
			
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER > 0 THEN
					
						IF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
						ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
						ELIF cCodRetSp::INTEGER = 3 THEN
							LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 4 THEN
							LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
						ELIF cCodRetSp::INTEGER = 5 THEN
							LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
						ELIF cCodRetSp::INTEGER = 6 THEN
							LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 7 THEN
							LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
						ELIF cCodRetSp::INTEGER = 8 THEN
							LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
							LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
							LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
						ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
							LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
						END IF;	
						
						--
						UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
						SET status = 'E', error_proceso = 'S', altas_total = NVL(iTotalEnviadas,0), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores, error = cCodRet WHERE usuario = pUsuario;	
					
						RETURN cCodRet,iTotalEnviadas,iTotalExitosas,cHayErrores,'';
						
					END IF;
					
				END IF;
				
				SELECT sol.num_producto,res.tipo_movimiento INTO cProducto,cTipoMov
				FROM bdisolic:"informix".ss_solicitudes AS sol, bdisolic:"informix".ss_resum_scor_fin AS res
				WHERE sol.numcte = cCliente AND sol.num_solicitud = res.num_solicitud AND sol.num_solicitud = cNumSolicitud;
				
				INSERT INTO bdicnweb:"informix".sw_buro_conslineacred(tipo_solicitud,num_solicitud,fecha,hora,cliente,estatus,comentario,total_registros,clave_grupo,segmento,etiqueta,producto,tipo_mov,usuario_insert,fecha_insert)
				VALUES (cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta,NVL(cProducto,''),NVL(cTipoMov,''),pUsuario,dFechaHoy);
				
/*				IF NVL(cCliente,'') IN (SELECT cliente FROM bdicnweb:"informix".sw_buro_conslineacred
									   WHERE tipo_mov = 'M' AND usuario_insert = TRIM(pUsuario)
									   GROUP BY cliente,estatus
									   HAVING COUNT(*) > 0) AND NVL(cProducto,'') <> '6001' THEN*/
				--Omite las solicitudes generadas de forma mixta con producto diferente a 6001
				IF cProducto = '6500' AND cTipoMov = 'M' THEN
					SELECT num_solicitud_ref INTO vNumSolicitud
					FROM bdisolic:"informix".ss_resum_scor_fin 
					WHERE empresa = '001' AND num_solicitud = cNumSolicitud;

					IF EXISTS (SELECT 1 FROM bdisolic:"informix".ss_solicitudes WHERE empresa = "001" AND num_solicitud = vNumSolicitud AND status_solicitud = cEstatus) THEN
						DELETE FROM bdicnweb:"informix".sw_buro_conslineacred WHERE num_solicitud = cNumSolicitud AND tipo_mov = 'M' AND usuario_insert = pUsuario;
					END IF;
				END IF;
				
			END FOREACH;
			
			SELECT DISTINCT puesto INTO cPuesto FROM bdicred:"informix".sd_perfiles_cac_aumlincred WHERE ejecutivo = pUsuario;
			IF (NVL(cPuesto,'') IN ('01','03','04')) AND pNumSolicitud = '' AND pNumCliente = '' THEN
			
				SELECT COUNT(*)
				INTO iTotalEnviadas
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE UPPER(comentario) <> 'EN PROCESO DE CONSULTA'
				AND usuario_insert = pUsuario AND fecha_insert = dFechaHoy;
				--WHERE LOWER(TRIM(comentario)) <> LOWER('En proceso de Consulta')
			
			ELSE
				
				SELECT COUNT(*)
				INTO iTotalEnviadas
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy;
			
			END IF;
			
			IF (NVL(iTotalEnviadas,0) - 1) = 0 THEN
				LET cCodRet = '00017';
			END IF;
			
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'T', error_proceso = 'N', altas_total = (NVL(iTotalEnviadas,0) - 1), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores WHERE usuario = pUsuario;
			
			RETURN cCodRet,(NVL(iTotalEnviadas,0) - 1),NVL(iTotalExitosas,0),cHayErrores,'';
			
		--Reenvio Solicitudes (pantalla principal)
		ELIF pEjecucion = 2 THEN		
		
			-- SE LIMPIA TABLA POR USUARIO VALIDACION DE ESTATUS DEL PROCESO 
            SET LOCK MODE TO WAIT 3;
            DELETE FROM bdicnweb:"informix".sw_buro_statusmonitorbccc WHERE usuario = pUsuario;
            
            -- SE INSERTA A TABLA PARA EL MONITOREO DEL ESTATUS DEL PROCESO
            SET LOCK MODE TO WAIT 3; 
            INSERT INTO bdicnweb:"informix".sw_buro_statusmonitorbccc(usuario,status,altas_total,total_exitosas,existe_error,estatus,error_proceso,error)
            VALUES(pUsuario, 'I', iTotalEnviadas, iTotalExitosas, cHayErrores, '', '', '');  
			
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM bdicnweb:"informix".sw_buro_bitacoraerror WHERE user_insert = pUsuario;
			
			FOREACH
			
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEjecucion, '|')
				INTO cIdRegistro				
				
				LET iIdRegistro = cIdRegistro::INTEGER;
				SELECT num_solicitud, estatus, comentario, clave_grupo, segmento, etiqueta
				INTO cNumSolicitud, cEstatus, cComentario, cClaveGrupo, cSegmento, cEtiqueta
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy AND id_serial = cIdRegistro::INTEGER;
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET iTotalEnviadas = iTotalEnviadas + 1;
				END IF;
				FOREACH
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(2, pTipoSolicitud, TRIM(cNumSolicitud), '',
				'', '', cEstatus, '', cClaveGrupo, cSegmento, cEtiqueta, pUsuario, cComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
			END FOREACH;
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER = 1 THEN
						--LET cCodRet = '00003';
						LET cDescIdCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 2 THEN
						--LET cCodRet = '00450';
						LET cDescIdCodRet = 'VALOR DE PARAMETRO INVALIDO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 3 THEN
						--LET cCodRet = '00914';
						LET cDescIdCodRet = 'EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 4 THEN
						--LET cCodRet = '00426';
						LET cDescIdCodRet = 'EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 5 THEN
						--LET cCodRet = '00017';
						LET cDescIdCodRet = 'NO SE OBTUVIERON RESULTADOS';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 6 THEN
						--LET cCodRet = '00914';
						LET cDescIdCodRet = 'EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 7 THEN
						--LET cCodRet = '00003';
						LET cDescIdCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 8 THEN
						--LET cCodRet = '00017';
						LET cDescIdCodRet = 'NO SE OBTUVIERON RESULTADOS';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
						--LET cCodRet = '00283';
						LET cDescIdCodRet = 'ERROR AL ACTUALIZAR EL REGISTRO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
						--LET cCodRet = '00915';
						LET cDescIdCodRet = 'EL ESTATUS DE LA SOLICITUD ES INCORRECTO';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
						--LET cCodRet = '00917';
						LET cDescIdCodRet = 'OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito';
						INSERT INTO bdicnweb:"informix".sw_buro_bitacoraerror(tipo_solicitud,num_solicitud,mensaje_error,user_insert,fecha_insert,hora_insert)
						VALUES(cTipoSolicitud,cNumSolicitud,cDescIdCodRet,pUsuario,dFechaHoy,dHoraHoy);
					END IF;	

					IF cCodRetSp::INTEGER = 0 THEN
						LET iTotalExitosas = iTotalExitosas + 1;
					END IF;
					
				END IF;
			
			END FOREACH;
			
			--SET LOCK MODE TO WAIT 3;
			
			IF NVL(iTotalEnviadas,0) <> NVL(iTotalExitosas,0) THEN
				LET cHayErrores = 'S';
			END IF;
			
			UPDATE bdicnweb:"informix".sw_buro_statusmonitorbccc
            SET status = 'T', error_proceso = 'N', altas_total = NVL(iTotalEnviadas,0), total_exitosas = NVL(iTotalExitosas,0), existe_error = cHayErrores WHERE usuario = pUsuario;
			
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'';
		
		--Actualiza Estatus		
		ELIF pEjecucion = 3 THEN

            FOREACH
		
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(3, pTipoSolicitud, pNumSolicitud, '', 
			'', '', '', '', '', '', '', '', '')
			INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
		
			IF cCodRetSp <> 'TOTAL' THEN
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 7 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 8 THEN
					LET cCodRet = '00916'; --NO HAY RESPUESTA DE BURO DE CREDITO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
					LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
					LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
					LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
				END IF;
				
			END IF;
		
            
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,UPPER(cEstatus) WITH RESUME;
			
            END FOREACH;
		--ActualizaciÃ³n a tabla como enviada (no retorna nada)	
		ELIF pEjecucion = 4 THEN
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(4, '0', pNumSolicitud, '', 
			'', '', '', '', '', '', '', '', '')
			INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta
		
			IF cCodRetSp <> 'TOTAL' THEN
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
				ELIF cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 7 THEN
					LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
				ELIF cCodRetSp::INTEGER = 8 THEN
					LET cCodRet = '00916'; --NO HAY RESPUESTA DE BURO DE CREDITO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
					LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
					LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
				ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
					LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
				END IF;
				
			END IF;
		
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'' WITH RESUME;
		END FOREACH;
		--Reenvio Solicitudes (pantalla modal)
		ELIF pEjecucion = 5 THEN		
		
			FOREACH
			
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEjecucion, '|')
				INTO cIdRegistro				
				
				LET iIdRegistro = cIdRegistro::INTEGER;
				SELECT num_solicitud, estatus, comentario, clave_grupo, segmento, etiqueta
				INTO cNumSolicitud, cEstatus, cComentario, cClaveGrupo, cSegmento, cEtiqueta
				FROM bdicnweb:"informix".sw_buro_conslineacred
				WHERE usuario_insert = pUsuario AND fecha_insert = dFechaHoy AND id_serial = cIdRegistro::INTEGER;
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET iTotalEnviadas = iTotalEnviadas + 1;
				END IF;
				
				EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_conssolcredlincred2(2, pTipoSolicitud, TRIM(cNumSolicitud), '',
				'', '', cEstatus, '', cClaveGrupo, cSegmento, cEtiqueta, pUsuario, cComentario)
				INTO cCodRetSp,cTipoSolicitud,cNumSolicitud,dFecha,dHora,cCliente,cEstatus,cComentario,iTotalRegistros,cClaveGrupo,cSegmento,cEtiqueta;
			
				IF cCodRetSp <> 'TOTAL' THEN
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_mon_buro_conssolcredlincred';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00450'; --'VALOR DE PARAMETRO INVALIDO
					ELIF cCodRetSp::INTEGER = 3 THEN
						LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 4 THEN
						LET cCodRet = '00426'; --EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
					ELIF cCodRetSp::INTEGER = 5 THEN
						LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
					ELIF cCodRetSp::INTEGER = 6 THEN
						LET cCodRet = '00914'; --EL TIPO DE SOLICITUD NO EXISTE O ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 7 THEN
						LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
					ELIF cCodRetSp::INTEGER = 8 THEN
						LET cCodRet = '00017'; --NO SE OBTUVIERON RESULTADOS
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo = '08' THEN
						LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'CC' THEN
						LET cCodRet = '00915'; --EL ESTATUS DE LA SOLICITUD ES INCORRECTO
					ELIF cCodRetSp::INTEGER = 9 AND pCveGrupo <> '08' AND pEstatus = 'BC' THEN
						LET cCodRet = '00917'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdiburo:"informix".ins_buro_credito
					END IF;	

					IF cCodRetSp::INTEGER = 0 THEN
						LET iTotalExitosas = iTotalExitosas + 1;
					END IF;
					
				END IF;
			
			END FOREACH;
			
			--SET LOCK MODE TO WAIT 3;
			
			IF NVL(iTotalEnviadas,0) <> NVL(iTotalExitosas,0) THEN
				LET cHayErrores = 'S';
			END IF;
		
			RETURN cCodRet,NVL(iTotalEnviadas,0),NVL(iTotalExitosas,0),cHayErrores,'';		
		END IF;		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 22/11/2016',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: MONITOR DE LA SITUACIÃN DE LOS ENVÃOS A BC Y CC',
'DESCRIPCION: Spl encargado de consultar el nÃºmero total de solicitudes de los envÃ­os a BC y CC.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 01/02/2017',
'DESCRIPCION: Se modifica SPL para agregar filtro por usuario_insert al momento de hacer consultas y/o fectaciones a la tabla sw_buro_conslineacred.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 16/02/2017',
'DESCRIPCION: Se modifica SPL para agregar filtro por pUsuario al momento de generar la consulta del grid.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizareportespendientesarqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNombreReporte CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizareportespendientesarqueosuc.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		UPDATE {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} bdicnweb:"informix".sw_ctrlgenreportesarqueos set status='1' WHERE usuario_insert = pUsuario and nombre_reporte = pNombreReporte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '01005';		--ERROR AL ACTUALIZAR EL ESTATUS DEL REPORTE
			RETURN cCodRet; 
		ELSE 			
			RETURN cCodRet;
		END IF;		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ACTUALIZA EL ESTATUS DEL REPORTE A 1 PARA INDICAR QUE YA FUE DESCARGADO',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizareportespendientesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10),pNombreReporte CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_actualizareportespendientesentradasalida.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		UPDATE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} bdicnweb:"informix".sw_ctrlgenreportesentradasalida set status='1' WHERE usuario_insert = pUsuario and nombre_reporte = pNombreReporte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '01005';		--ERROR AL ACTUALIZAR EL ESTATUS DEL REPORTE
			RETURN cCodRet; 
		ELSE 			
			RETURN cCodRet;
		END IF;		
		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ACTUALIZA EL ESTATUS DEL REPORTE A 1 PARA INDICAR QUE YA FUE DESCARGADO',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportearqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte,
		CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;
	LET cStatus ='0';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportearqueosuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte, status
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus
			FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el detalle de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportearqueosuc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportearqueosuc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte,
		CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;
	LET cStatus='0';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesentradasalida.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte, status
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus
			FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte,cStatus;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el detalle de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesentradasalida_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesentradasalida_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ARQUEO DE SUCURSALES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los reportes generados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pIdSucursal CHAR(4), 
			pIdPlaza CHAR(3), pFechaInic DATE, pFechaFin DATE, pMes CHAR(2), pAnio CHAR(4), pIdStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,  			
		         CHAR(50) AS caja_general,     	
                 CHAR(8) AS folio_ope,	     	
		         CHAR(40) AS status,		    
                 CHAR(50) AS sucursal,	      	
                 CHAR(16) AS folio_suc,	     	
		         DATE AS fecha_solicitud,       
		         CHAR(8) AS us_solicito,     	
		         DATE AS fecha_envio,	      	
		         CHAR(8) AS us_envio,	     	
		         DATE AS fecha_recepcion,     	
		         CHAR(8) AS us_recepcion,  	   	
		         MONEY(14,2) AS monto,	     	
		         DATE AS fecha_reversion,      	
		         CHAR(8) AS us_reversion,          	
		         CHAR(40) AS plaza,				
				 CHAR(10) AS tpo_suc;  	     	
		
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		
		DEFINE cCajaGeneral CHAR(50);
		DEFINE cFolioOpe CHAR(8);
		DEFINE cStatus CHAR(40);
        DEFINE cSucursal CHAR(50);
        DEFINE cFolioSuc CHAR(16);
		DEFINE dFechaSolicitud DATE;
		DEFINE cUsSolicitud CHAR(8); 
		DEFINE dFechaEnvio DATE;
		DEFINE cUsEnvio CHAR(8);     
		DEFINE dFechaRecepcion DATE;
		DEFINE cUsRecepcion CHAR(8); 
		DEFINE cOtroStatus CHAR(40); 
		DEFINE mMonto MONEY(14,2);
		DEFINE dFechaReversion DATE; 
		DEFINE cUsReversion CHAR(8);   
		DEFINE cPlaza CHAR(40);
		DEFINE cTpoSucRSP CHAR(1); 
		DEFINE cTpoSuc CHAR(10); 
		DEFINE iExisteSuc INTEGER;
		DEFINE iExisteATM INTEGER;
		
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER; 
        DEFINE iRecuperacion INTEGER;
        DEFINE iRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		
		LET cCajaGeneral = '';
		LET cFolioOpe = '';
		LET cStatus = '';
		LET cSucursal = '';
		LET cFolioSuc = '';
		LET dFechaSolicitud = '';
		LET cUsSolicitud = '';   
		LET dFechaEnvio = ''; 	 
		LET cUsEnvio = '';       
		LET dFechaRecepcion = '';
		LET cUsRecepcion = '';   
		LET cOtroStatus = '';    
		LET mMonto = '';         
		LET dFechaReversion = '';   
		LET cUsReversion = '';   
		LET cPlaza = '';   
		LET cTpoSuc = '';
		LET cTpoSucRSP = '';
		LET iExisteSuc = 0;
		LET iExisteATM = 0;
		
		LET cEmpresa = '001';
        LET iNoRegistros = 0; 
        LET iRecuperacion = 0;
        LET iRegistros = 0;


		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfentradasalidacaja.out';
            --TRACE ON;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pIdPlaza = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					   dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSuc;
			END IF;
			
			IF pTipoSucursal = 'S' OR pTipoSucursal = 'C' THEN
					
				FOREACH SELECT {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} SKIP pRegistros FIRST pRecuperacion codproveedor, foloper, desstatus, sucursal, folsuc, fecsol, usuariosol,
							fecenvio,usuarioenv, fecrecepcion, usuariorecep, monto, fecrever, vusuariorever, nomplaza, tipo_suc
					INTO cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSucRSP
					FROM bdicnweb:"informix".tmp_entradasalida  
					WHERE id_usuario = pUsuario
				
					-- RENOMBRA TIPO
					IF cTpoSucRSP = 'S' THEN
						LET cTpoSuc = 'SUCURSAL';
					ELIF cTpoSucRSP = 'C' THEN
						LET cTpoSuc = 'ATM';
					END IF;
				
					RETURN cCodRet, UPPER(cCajaGeneral), cFolioOpe, UPPER(cStatus), UPPER(cSucursal), cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					       dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, UPPER(cPlaza), UPPER(cTpoSuc) WITH RESUME;
					LET iRecuperacion = iRecuperacion + 1;
														
				END FOREACH;
				
				IF iRecuperacion = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				END IF;			
				
			ELIF pTipoSucursal = 'A' THEN
						
				
				FOREACH SELECT {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} SKIP pRegistros FIRST pRecuperacion codproveedor, foloper, desstatus, sucursal, folsuc, fecsol, usuariosol,
							fecenvio,usuarioenv, fecrecepcion, usuariorecep, monto, fecrever, vusuariorever, nomplaza, tipo_suc
					INTO cCajaGeneral, cFolioOpe, cStatus, cSucursal, cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, cPlaza, cTpoSucRSP
					FROM bdicnweb:"informix".tmp_entradasalida  
					WHERE id_usuario = pUsuario
				
					-- RENOMBRA TIPO
					IF cTpoSucRSP = 'S' THEN
						LET cTpoSuc = 'SUCURSAL';
					ELIF cTpoSucRSP = 'C' THEN
						LET cTpoSuc = 'ATM';
					END IF;
				
					RETURN cCodRet, UPPER(cCajaGeneral), cFolioOpe, UPPER(cStatus), UPPER(cSucursal), cFolioSuc, dFechaSolicitud, cUsSolicitud, 
					       dFechaEnvio, cUsEnvio, dFechaRecepcion, cUsRecepcion, mMonto, dFechaReversion, cUsReversion, UPPER(cPlaza), UPPER(cTpoSuc) WITH RESUME;
					LET iRecuperacion = iRecuperacion + 1;
														
				END FOREACH;
				
				IF iRecuperacion = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';	
				END IF;			
			
			
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2020',
'DESCRIPCION: SPL que realiza la consulta para el llenado del grid Listado de Registros y Detalle de Saldo por Plaza, Consultas Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pIdSucursal CHAR(4), 
        pIdPlaza CHAR(3), pFechaInic DATE, pFechaFin DATE, pMes CHAR(2), pAnio CHAR(4), pIdStatus CHAR(2),
        pMac CHAR(18), pIp VARCHAR(16))
        RETURNING CHAR(5) AS codret,
                INTEGER AS totalRegistros;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cEmpresa CHAR(3);
        DEFINE iTotalRegistros_S INTEGER;
        DEFINE iTotalRegistros_C INTEGER;
        DEFINE iTotalRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cEmpresa = '001';
        LET iTotalRegistros_S = 0;
        LET iTotalRegistros_C = 0;
        LET iTotalRegistros = 0;

        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iTotalRegistros;
                END EXCEPTION;
				
				SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
            
                --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesentradasalidacaja.out';
                --TRACE ON;
                
                -- SE LIMPIA TABLA POR USUARIO
                DELETE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} FROM bdicnweb:"informix".sw_verificastatusentradasalida WHERE usuario_insert = TRIM(pUsuario);
                
                -- SE INSERTA PROCESO
                INSERT INTO bdicnweb:"informix".sw_verificastatusentradasalida(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);

                DELETE {+INDEX (bdicnweb:tmp_entradasalida idx_tmp_entradasalida)} FROM bdicnweb:"informix".tmp_entradasalida  where id_usuario = pUsuario;
				
                IF pUsuario = '' OR pIdFuncion = '' OR pIdPlaza = '' THEN
                        LET cCodRet = '00003';
                        --Actualiza proceso erroneo
                         UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
					     SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                
                        RETURN cCodRet, iTotalRegistros;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        --Actualiza proceso erroeo
                          UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						  SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                        
                        RETURN cCodRet, iTotalRegistros;
                END IF;
				
                IF pTipoSucursal = 'S' OR pTipoSucursal = 'C' THEN
                
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '1')
                                        INTO cCodRetSp, iTotalRegistros
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        ELIF cCodRetSp::INTEGER = 0 THEN 
                                                        ---Actualiza proceso exitoso
                                                      UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
													  SET status = 'T', error_proceso = 'N', num_registros = iTotalRegistros WHERE usuario_insert = pUsuario;
                                                      RETURN cCodRet, iTotalRegistros;
                                        END IF;
                        END FOREACH;
                
                ELIF pTipoSucursal = 'A' THEN
                
                        LET pTipoSucursal = 'S';
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '1')
                                        INTO cCodRetSp, iTotalRegistros_S
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        END IF;
                        END FOREACH;
                        
                        LET pTipoSucursal = 'C';
                        FOREACH EXECUTE PROCEDURE bdisuc:"informix".sp_entrada_salida(pUsuario,pIdFuncion,cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus, '2')
                                        INTO cCodRetSp, iTotalRegistros_C
                                        
                                        IF cCodRetSp::INTEGER < 0 THEN
                                                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_entrada_salida';
                                        END IF;
                        END FOREACH;
                        
                        LET iTotalRegistros = (iTotalRegistros_S + iTotalRegistros_C);
                        TRACE iTotalRegistros;
                        
                        --Actualiza proceso exitoso
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						SET status = 'T', error_proceso = 'N', num_registros = iTotalRegistros WHERE usuario_insert = pUsuario;
                        RETURN cCodRet, iTotalRegistros;
                
                END IF;
                
                IF iTotalRegistros = 0 THEN
                        LET cCodRet = '00017';
                        --Actualiza proceso erroneo
                        UPDATE {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} bdicnweb:"informix".sw_verificastatusentradasalida
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

                        RETURN cCodRet, iTotalRegistros;
                END IF;
 
    END;

END PROCEDURE 
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'DESCRIPCION: SPL que consulta el total de registros para el llenado del grid Listado de registros y detalle de saldo por plaza, Consultas Entrada Salida Caja General',
'AUTOR: Saul Ortiz Baeza',
'FECHA: 26/04/2016',
'DESCRIPCION: Se realizo el ajuste para consultar el total de registros por monitoreo de proceso.',
'AUTOR: Julio Martinez',
'FECHA: 05/04/2017',
'DESCRIPCION: Se realiza el tratamiento de la inserccion de totales en el monitor de procesos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificareportespendientesarqueosuc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificareportespendientesarqueosuc.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select {+INDEX (bdicnweb:sw_ctrlgenreportesarqueos idx_sw_ctrlgenreportesarqueos)} count (status) as filas 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesarqueos WHERE usuario_insert = pUsuario and status ='0';
		
	    RETURN cCodRet,iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA SI EL USUARIO TIENE REPORTES POR DESCARGAR --ESTATUS 0 ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificareportespendientesentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificareportespendientesentradasalida.out';
		-- TRACE ON;
		
		
		--VALIDACION PARAMETROS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} count (status) as filas 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE usuario_insert = pUsuario and status ='0';
		
	    RETURN cCodRet,iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 12/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA SI EL USUARIO TIENE REPORTES POR DESCARGAR --ESTATUS 0 ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusentradasalida(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusentradasalida.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_verificastatusentradasalida idx_sw_verificastatusentradasalida)} status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:sw_verificastatusentradasalida WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_ejecutaquery(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasa CHAR(20),pUsEjecuta CHAR(8),pIdEjecucion CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	DEFINE cTipo_clienteTit CHAR(1);
	DEFINE cTipo_clienteTras CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_ejecutaquery.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdEjecucion = '1' THEN
--Inicio CC 49391
/*
			UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = '1' WHERE numcte = pCteTitular AND empresa = cEmpresa;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
*/
			--Se consulta el tipo de cliente de ambos clientes
			SELECT {+AVOID_FULL (bdinteg:"informix".si_cliente)}
			tipo_cliente
			INTO cTipo_clienteTit
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pCteTitular
			;
			
			SELECT {+AVOID_FULL (bdinteg:"informix".si_cliente)}
			tipo_cliente
			INTO cTipo_clienteTras
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pCteTraspasa
			;
			
			IF cTipo_clienteTras IS NULL THEN
				SELECT {+AVOID_FULL (bdinteg:"informix".si_fuscliente)}
				tipo_cliente
				INTO cTipo_clienteTras
				FROM bdinteg:"informix".si_fuscliente
				WHERE numcte = pCteTraspasa
				;
			END IF;
			
			IF (cTipo_clienteTit = '2' AND cTipo_clienteTras = '1') THEN
				UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = '1' WHERE numcte = pCteTitular AND empresa = cEmpresa;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				END IF;
			END IF;
--Fin CC 49391
		ELIF pIdEjecucion = '2' THEN
			INSERT INTO bdinteg:"informix".si_fusclientes_ide (cliente_tit, cliente_tras, fecha) VALUES (pCteTitular,pCteTraspasa,CURRENT);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			END IF;
		END IF;

		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de ejecutar una instruccion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancelacion_claves_retiro( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(19), pFecha_inicial DATE, pFecha_final DATE, pIp CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	
	RETURNING
		CHAR(5) AS codret,
		CHAR(100) AS folio,
		DATETIME YEAR TO SECOND AS fecha,
		CHAR(20) AS numCliente,
		CHAR(20) AS numCuenta,
		CHAR(20) AS numTarjeta,
		MONEY(16,2) AS monto,
		CHAR(10) AS canalCobro,
		CHAR(1) AS status,
		CHAR(20) AS descStatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE condition CHAR(200);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE vFolio CHAR(100);
	DEFINE dFecha DATETIME YEAR TO FRACTION(3);
	DEFINE vNumCliente CHAR(20);
	DEFINE vNumCuenta CHAR(20);
	DEFINE vNumTarjeta CHAR(20);
	DEFINE mMonto MONEY(16,2);
	DEFINE vCanalCobro CHAR(10);
	DEFINE cStatus CHAR(1);
	DEFINE vDescStatus CHAR(20);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET condition = '';
	LET cAccion = 'CONSULTA CANCELACION CLAVES RETIROS';
	LET cEntidad = 'claves_retiro';
	LET vFolio = '';
	LET dFecha = '';
	LET vNumCliente = '';
	LET vNumCuenta = '';
	LET vNumTarjeta = '';
	LET mMonto = 0;
	LET vCanalCobro = '';
	LET cStatus = '';
	LET vDescStatus = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cancelacion_claves_retiro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pIp = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus;
		END IF;

		FOREACH
			SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} SKIP pRegistros FIRST pRecuperacion cr.cr_foliooperacion, cr.cr_alta_fecha, cr.cr_cliente, cr.cr_cuenta, cr.cr_tarjeta, cr.cr_monto, cr.cr_canal_final, cr.cr_status, cs.cat_descripcion_status 
			INTO vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus
			FROM bdirst:"informix".claves_retiro AS cr
			INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
			WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr.cr_foliooperacion ELSE pFoliooperacion END
			AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
			AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
			AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
			AND DATE(cr.cr_alta_fecha) BETWEEN DATE(pFecha_inicial) AND DATE(pFecha_final)
			AND cr.cr_status = 'P'
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		END FOREACH;

		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, vFolio, dFecha, vNumCliente, vNumCuenta, vNumTarjeta, mMonto, vCanalCobro, cStatus, vDescStatus WITH RESUME;
		END IF;
		
	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACION DE ATM',
'FUNCIONALIDAD: Cancelacion Claves Retiro',
'DESCRIPCION: SPL encargado de extraer informaciÃÂ³n sobre la tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cancelacion_claves_retiro_totales( pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pFoliooperacion CHAR(100), pCliente CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20), pFecha_inicial DATE, pFecha_final DATE)
	
	RETURNING
		CHAR(5) AS codret,
		INTEGER AS 	totRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotales = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cancelacion_claves_retiro_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT {+INDEX (bdirst:claves_retiro idx_folionumcte)} COUNT(*) AS totales
		INTO iTotales
		FROM bdirst:"informix".claves_retiro AS cr
		INNER JOIN bdirst:"informix".cat_status AS cs ON cs.cat_cod_status = cr.cr_status
		WHERE cr.cr_foliooperacion = CASE WHEN pFoliooperacion = '' THEN cr.cr_foliooperacion ELSE pFoliooperacion END
		AND cr.cr_cliente = CASE WHEN pCliente = '' THEN cr.cr_cliente ELSE pCliente END
		AND cr.cr_cuenta = CASE WHEN pCuenta = '' THEN cr.cr_cuenta ELSE pCuenta END
		AND cr.cr_tarjeta = CASE WHEN pTarjeta = '' THEN cr.cr_tarjeta ELSE pTarjeta END
		AND DATE(cr.cr_alta_fecha) BETWEEN DATE(pFecha_inicial) AND DATE(pFecha_final)
		AND cr.cr_status = 'P';
		

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;

	END;		

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR',
'FECHA: 19/12/2020',
'MODULO: ADMINISTRACION DE ATM',
'FUNCIONALIDAD: CancelaciÃÂ³n Claves Retiro',
'DESCRIPCION: SPL encargado de obtener el total de registros en tabla claves_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abm_canal_cobro( pUsuario CHAR(8), pIdFuncion CHAR(10), pid_canal_final VARCHAR(2), pcve_canal_final VARCHAR(30), pnombre_canal VARCHAR(30), pcobrar_otp VARCHAR(1), pBandera integer, pIp VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE pcodigoStatus CHAR(2);
	DEFINE pdescripcionstatus CHAR(20);
	DEFINE calta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE cCodigoStatusExistente CHAR(2);
	DEFINE iExiste INTEGER;
	DEFINE lastIdCanalFinal CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET calta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cAccion = '';
	LET cEntidad = 'par_canal_final';
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_canal_cobro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pcve_canal_final = '' OR pnombre_canal= ''  OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			LET cAccion = 'AGREGA CANAL DE COBRO';
			
			SELECT COUNT(par_cve_canal_final) INTO iExiste 
			FROM bdirst:"informix".par_canal_final
			WHERE UPPER(par_nombre_canal) = UPPER(pnombre_canal); --par_cve_canal_final = pcve_canal_final OR 
			
			IF NVL(iexiste,0) > 0 THEN
				UPDATE bdirst:"informix".par_canal_final
						SET 
						par_cobrar_otp = 'V',
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE UPPER(par_nombre_canal) = UPPER(pnombre_canal);
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
				FOREACH
					SELECT  first 1 par_id_canal_final INTO lastIdCanalFinal FROM bdirst:"informix".par_canal_final order by par_id_canal_final::INTEGER desc
					END FOREACH;
					IF NVL(lastIdCanalFinal,'') = '' THEN
						LET lastIdCanalFinal = 1;
					ELSE
						LET lastIdCanalFinal = lastIdCanalFinal + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".par_canal_final (par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha, par_cobrar_otp, par_usuario_alta_id_fk )
					VALUES(lastIdCanalFinal, pcve_canal_final, pnombre_canal, calta_fecha, pcobrar_otp , pUsuario);
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			END IF;
		END IF;
		
		IF pBandera = 2 THEN
			LET cAccion = 'MODIFICA CANAL DE COBRO';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_final','par_cve_canal_final', 'par_nombre_canal', 'par_alta_fecha', 'par_cobrar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_cobrar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_final WHERE par_id_canal_final = '"||TRIM(pid_canal_final)||"' AND par_cve_canal_final = '"||TRIM(pcve_canal_final)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF (pid_canal_final <> '' AND pcve_canal_final <> '') OR (pcve_canal_final IS NOT NULL AND pid_canal_final IS NOT NULL) THEN -- VALIDAR CON JOHN SI SE REALIZA LA VALIDACION CON NULL
					IF pcobrar_otp <>'' THEN
						UPDATE bdirst:"informix".par_canal_final
						SET par_nombre_canal = pnombre_canal,
						par_cobrar_otp = pcobrar_otp,
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final AND par_id_canal_final = pid_canal_final;
					ELSE
						UPDATE bdirst:"informix".par_canal_final
						SET par_nombre_canal = pnombre_canal,
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final AND par_id_canal_final = pid_canal_final;
					END IF;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		IF pBandera = 3 THEN
			LET cAccion = 'ELIMINA CANAL DE COBRO';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_final','par_cve_canal_final', 'par_nombre_canal', 'par_alta_fecha', 'par_cobrar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_cobrar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_final WHERE par_id_canal_final = '"||TRIM(pid_canal_final)||"' AND par_cve_canal_final = '"||TRIM(pcve_canal_final)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF pid_canal_final <> '' THEN
					UPDATE bdirst:"informix".par_canal_final
						SET 
						par_cobrar_otp = 'F',
						par_ultima_mod_fecha = cultima_mod_fecha, 
						par_usuario_mod_id_fk = pUsuario 
						WHERE par_cve_canal_final = pcve_canal_final;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00862';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD:  Cabales de cobro',
'DESCRIPCION: SPL de la Alta, Actualizacion y delete de Canales de cobro',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_abm_canal_generacion( pUsuario CHAR(8), pIdFuncion CHAR(10), pId_canal_inicial VARCHAR(2), pCve_canal_inicial VARCHAR(30), pNombre_canal VARCHAR(30), pGenerar_otp VARCHAR(1), pBandera INTEGER, pIp VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE pcodigoStatus CHAR(2);
	DEFINE pdescripcionstatus CHAR(20);
	DEFINE calta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE cCodigoStatusExistente CHAR(2);
	DEFINE iExiste INTEGER;
	DEFINE lastIdCanalInicial CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	DEFINE cNombre_canal CHAR(30);
	
	LET cNombre_canal = TRIM(pNombre_canal);	
	LET cAccion = '';
	LET cEntidad = 'par_canal_inicial';
	LET cIp = pIp;
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET calta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_canal_generacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCve_canal_inicial = ''  OR pNombre_canal= '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} COUNT(par_cve_canal_inicial) INTO iExiste 
			FROM bdirst:"informix".par_canal_inicial
			WHERE UPPER(par_nombre_canal) = UPPER(cNombre_canal);			
			LET cAccion = 'AGREGA CANAL DE GENERACION';
			
			IF NVL(iexiste,0) > 0 THEN
				
				UPDATE bdirst:"informix".par_canal_inicial
							SET 
							par_generar_otp = 'V',
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE UPPER(par_nombre_canal) = UPPER(cNombre_canal);
				
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
				
                FOREACH
					SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} first 1 par_id_canal_inicial INTO lastIdCanalInicial FROM bdirst:"informix".par_canal_inicial order by par_id_canal_inicial::INTEGER desc
            	END FOREACH;			
					IF NVL(lastIdCanalInicial,'') = '' THEN
						LET lastIdCanalInicial = 1;
					ELSE
						LET lastIdCanalInicial = lastIdCanalInicial + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".par_canal_inicial (par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha, par_generar_otp, par_usuario_alta_id_fk )
					VALUES(lastIdCanalInicial, pcve_canal_inicial, pnombre_canal, calta_fecha, pgenerar_otp , pUsuario);
				ELSE
					LET cCodRet = '99999';
				END IF;
			END IF;
		END IF;
			
		IF pBandera = 2 THEN
		
			SELECT {+INDEX (bdirst:par_canal_inicial idx_nombre_canal_inicial)} COUNT(par_cve_canal_inicial) INTO iExiste 
			FROM bdirst:"informix".par_canal_inicial
			WHERE par_nombre_canal = cNombre_canal;			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
			
				LET cAccion = 'MODIFICA CANAL DE GENERACION';
			
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_inicial', 'par_cve_canal_inicial', 'par_nombre_canal', 'par_alta_fecha', 'par_generar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_generar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_inicial WHERE par_id_canal_inicial = '"||TRIM(pid_canal_inicial)||"' AND par_cve_canal_inicial = '"||TRIM(pcve_canal_inicial)||"')";
			
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					IF (pid_canal_inicial <> '' AND pcve_canal_inicial <> '') OR (pcve_canal_inicial IS NOT NULL AND pid_canal_inicial IS NOT NULL) THEN -- VALIDAR CON JOHN SI SE REALIZA LA VALIDACION CON NULL
						IF pgenerar_otp <>'' THEN
							UPDATE bdirst:"informix".par_canal_inicial
							SET par_nombre_canal = pnombre_canal,
							par_generar_otp = pgenerar_otp,
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
						ELSE
							UPDATE bdirst:"informix".par_canal_inicial
							SET par_nombre_canal = pnombre_canal,
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
						END IF;
						
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
				
					ELSE
						LET cCodRet = '00003';
						RETURN cCodRet;
					END IF;
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
		
		IF pBandera = 3 THEN
			LET cAccion = 'ELIMINA CANAL DE GENERACION';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id_canal_inicial', 'par_cve_canal_inicial', 'par_nombre_canal', 'par_alta_fecha', 'par_generar_otp', 'par_ultima_mod_fecha', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal, par_alta_fecha::VARCHAR(10), par_generar_otp, par_ultima_mod_fecha::VARCHAR(10), par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".par_canal_inicial WHERE par_id_canal_inicial = '"||TRIM(pid_canal_inicial)||"' AND par_cve_canal_inicial = '"||TRIM(pcve_canal_inicial)||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				
				IF pid_canal_inicial <> '' THEN
					
					UPDATE bdirst:"informix".par_canal_inicial
							SET 
							par_generar_otp = 'F',
							par_ultima_mod_fecha = cultima_mod_fecha, 
							par_usuario_mod_id_fk = pUsuario 
							WHERE par_cve_canal_inicial = pcve_canal_inicial AND par_id_canal_inicial = pid_canal_inicial;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00862';
						RETURN cCodRet;
					END IF;
				
				ELSE
					LET cCodRet = '00003';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL de la Alta, Actualizacion y delete de Canales de generaciÃÂ³n',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_abm_parametro_status( pUsuario CHAR(8), pIdFuncion CHAR(10),
	pIdStatus VARCHAR(2), pCodigoStatus VARCHAR(2), pDescripcionstatus VARCHAR(20), pBandera INTEGER, pIp VARCHAR(20))
	
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cAlta_fecha DATE;
	DEFINE cultima_mod_fecha DATE;
	DEFINE iExiste INTEGER;
	DEFINE lastIdStatus CHAR(2);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	DEFINE cCdigoEstatus CHAR(2);
	DEFINE cDescripcionstatus CHAR(20);
		
	LET cDescripcionstatus = TRIM(pDescripcionstatus);
	LET cAccion = '';
	LET cEntidad = 'cat_status';
	LET cip = pip;
	LET crespaldo = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAlta_fecha = CURRENT;
	LET cultima_mod_fecha = CURRENT;
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');
	LET cCdigoEstatus = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_abm_parametro_status.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionstatus= '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = 1 THEN
			LET cAccion = 'AGREGA PARAMETRO ESTATUS';
			
			SELECT {+INDEX (bdirst:cat_status idx_cat_status)} COUNT(cat_cod_status) INTO iExiste 
			FROM bdirst:"informix".cat_status 
			WHERE UPPER(cat_descripcion_status) = UPPER(cDescripcionstatus); --cat_cod_status = pCodigoStatus OR 
			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					SELECT {+INDEX (bdirst:cat_status idx_cat_status)} MAX (cat_id_status::INTEGER) INTO lastIdStatus FROM bdirst:"informix".cat_status;
					
					IF NVL(lastIdStatus, 0) = 0 THEN 
						LET lastIdStatus =  1;
					ELSE 
						LET lastIdStatus = lastIdStatus + 1;
					END IF;
				
					INSERT INTO bdirst:"informix".cat_status (cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha, cat_usuario_alta_id_fk)
					VALUES(lastIdStatus, cCdigoEstatus, pDescripcionstatus, cAlta_fecha, pUsuario);
				ELSE 
					LET cCodRet = '99999'; 
				END IF;
				
			END IF;
		END IF;
		
		IF pBandera = 2 THEN
			
			SELECT {+INDEX (bdirst:cat_status idx_cat_status)} COUNT(cat_cod_status) INTO iExiste 
			FROM bdirst:"informix".cat_status 
			WHERE cat_descripcion_status = cDescripcionstatus; --cat_cod_status = pCodigoStatus OR 
			
			IF NVL(iexiste,0) > 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet;
			ELSE
				LET cAccion = 'MODIFICACION PARAMETROS ESTATUS';
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'cat_id_status', 'cat_cod_status', 'cat_descripcion_status', 'cat_alta_fecha', 'cat_ultima_mod_fecha', 'cat_usuario_alta_id_fk', 'cat_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha::VARCHAR(10), cat_ultima_mod_fecha::VARCHAR(10), cat_usuario_alta_id_fk::VARCHAR(11), cat_usuario_mod_id_fk::VARCHAR(11)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".cat_status WHERE cat_cod_status = '"||pCodigoStatus||"' AND cat_id_status = '"||pIdStatus||"')";
			
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".cat_status 
					SET cat_descripcion_status = pDescripcionstatus,
					cat_ultima_mod_fecha = cultima_mod_fecha, 
					cat_usuario_mod_id_fk = pUsuario 
					WHERE cat_cod_status = pCodigoStatus AND cat_id_status = pIdStatus;
				
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
			
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
		
		IF pBandera = 3 THEN
			LET caccion = 'ELIMINA PARAMETROS ESTATUS';
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'cat_id_status', 'cat_cod_status', 'cat_descripcion_status', 'cat_alta_fecha', 'cat_ultima_mod_fecha', 'cat_usuario_alta_id_fk', 'cat_usuario_mod_id_fk'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT cat_id_status, cat_cod_status, cat_descripcion_status, cat_alta_fecha::VARCHAR(10), cat_ultima_mod_fecha::VARCHAR(10), cat_usuario_alta_id_fk::VARCHAR(11), cat_usuario_mod_id_fk::VARCHAR(11)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".cat_status WHERE cat_cod_status = '"||pCodigoStatus||"' AND cat_id_status = '"||pIdStatus||"')";
			
			EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
			IF cCodRet = '00000' THEN 
				EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
				DELETE FROM bdirst:"informix".cat_status WHERE cat_cod_status = pCodigoStatus AND cat_id_status = pIdStatus;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00862';
					RETURN cCodRet;
				END IF;
			ELSE
				LET cCodRet = '99999';
				RETURN cCodRet;
			END IF;
			
		END IF;
		
		RETURN cCodRet;
	END

END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃÂN DE ATM',
'FUNCIONALIDAD: Parametros Status',
'DESCRIPCION: SP para el alta, actualizaciÃÂ³n y eliminacion de un parametros estatus',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/01/2021',
'DESCRIPCION: Se realiza ajuste a procedimiento para realizar la insercion de valor vacÃÂ­o sobre campo cat_cod_status.',
'BD: bdirst';

CREATE PROCEDURE "informix".sp_canal_cobro( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS idCanalFinal,
		CHAR(30) AS cveCanalFinal,
		CHAR(30) AS nombreCanal,
		CHAR(1) AS cobrarOtp;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdCanalFinal CHAR(2);
	DEFINE cCveCanalFinal CHAR(30);
	DEFINE cNombreCanal CHAR(30);
	DEFINE cCobrarOtp CHAR(1);
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE crespaldo CHAR(50);
	
	LET cIdCanalFinal = '';
	LET cCveCanalFinal = '';
	LET cNombreCanal = '';
	LET cCobrarOtp = '';
	LET cAccion = 'CONSULTA CANAL DE COBRO';
	LET cEntidad = 'par_canal_final';
	LET crespaldo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_cobro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN
			FOREACH
		
				SELECT par_id_canal_final, par_cve_canal_final, par_nombre_canal, par_cobrar_otp
				INTO cIdCanalFinal, cCveCanalFinal, cNombreCanal, cCobrarOtp
				FROM bdirst: "informix".par_canal_final where par_cobrar_otp ='V'
			
				RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdCanalFinal, cCveCanalFinal,cNombreCanal, cCobrarOtp;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 24/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Cobro',
'DESCRIPCION: SPL encargado de consultar informaciÃ³n en tabla par_canal_final',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_cobro_totales( pUsuario CHAR(8), pIdFuncion CHAR(10) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_cobro_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst: "informix".par_canal_final where par_cobrar_otp ='V';
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Cobro',
'DESCRIPCION: SPL encargado de devolver el total de registros de la consulta canal de cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_generacion( pUsuario CHAR(8), pIdFuncion CHAR(10), pIp CHAR(20) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS idCanalInicial,
		CHAR(30) AS cveCanalInicial,
		CHAR(30) AS nombreCanal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE cIdCanalInicial CHAR(2);
	DEFINE cCveCanalInicial CHAR(30);
	DEFINE cNombreCanal CHAR(30);
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cIp CHAR(20);
	DEFINE crespaldo CHAR(50);
	LET cIdCanalInicial = '';
	LET cCveCanalInicial = '';
	LET cNombreCanal = '';
	
	LET cAccion = 'CONSULTA CANAL DE GENERACION';
	LET cEntidad = 'par_canal_inicial';
	LET cIp = pIp;
	LET crespaldo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_generacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, pIp, NULL, pUsuario, 1) INTO cCodRet;
		
		IF cCodRet = '00000' THEN 
			FOREACH
				SELECT par_id_canal_inicial, par_cve_canal_inicial, par_nombre_canal 
				INTO cIdCanalInicial, cCveCanalInicial, cNombreCanal
				FROM bdirst: "informix".par_canal_inicial where par_generar_otp ='V'
				
				RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal WITH RESUME;
			END FOREACH;
		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdCanalInicial, cCveCanalInicial,cNombreCanal;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 24/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de GeneraciÃ³n',
'DESCRIPCION: SPL encargado de consultar informaciÃ³n en tabla par_canal_inicial',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_canal_generacion_totales( pUsuario CHAR(8), pIdFuncion CHAR(10) )
	RETURNING 
		CHAR(5) AS codret,
		CHAR(2) AS totales;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
		
	DEFINE iTotales INTEGER;
	
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_canal_generacion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) 
		INTO iTotales 
		FROM bdirst: "informix".par_canal_inicial where par_generar_otp ='V';
		
		IF NVL(iTotales,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 22/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Canal de Generacion',
'DESCRIPCION: SPL encargado de obtener el total de registros sobre la tabla par_canal_inicial',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_modifica_parametros_retiros( pUsuario CHAR(8), pIdFuncion CHAR(10), pMonto_minimo VARCHAR(100), pMonto_maximo VARCHAR(100), pCodigo_activo VARCHAR(100), pVigencia VARCHAR(100), pip VARCHAR(20))
	RETURNING 
		CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE iExiste INTEGER;
	
	DEFINE cAccion CHAR(50);
	DEFINE cEntidad CHAR(100);
	DEFINE cip CHAR(20);
	DEFINE crespaldo CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cArchivoRespaldo CHAR(50);
	
	LET iExiste = 0;
	LET cAccion = '';
	LET cEntidad = 'parametro_sistema';
	LET cip = pip;
	LET crespaldo = '';
	LET cCmd1 = '';
	LET cArchivoRespaldo = 'ParamRet_'||pUsuario||TO_CHAR(CURRENT, '%d%m%Y');
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/calizarraga/sp_modifica_parametros_retiros.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pip = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pMonto_minimo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst:"informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'MONTO_MINIMO';
			
			IF NVL(iexiste,0) > 0 THEN
				LET cAccion = 'MODIFICA MONTO MINIMO';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'MONTO_MINIMO')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pMonto_minimo 
					WHERE par_nombre = 'MONTO_MINIMO' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF; 
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL MONTO MINIMO --
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'MONTO_MINIMO', pMonto_minimo, 'MONTO MINIMO', pUsuario);
			END IF;
			
		END IF;
		
		IF pMonto_maximo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'MONTO_MAXIMO';
			
			IF NVL(iexiste,0) > 0 THEN
				LET cAccion = 'MODIFICA MONTO MAXIMO';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'MONTO_MAXIMO')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pMonto_maximo 
					WHERE par_nombre = 'MONTO_MAXIMO' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;

			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL MONTO MAXIMO --
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'MONTO_MAXIMO', pMonto_maximo, 'MONTO MAXIMO', pUsuario);
				
			END IF;
		END IF;
		
		IF pCodigo_activo <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'CODIGOS_ACTIVOS';
			
			IF NVL(iexiste,0) > 0 THEN
				LET caccion = 'MODIFICA CODIGOS ACTIVOS';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'CODIGOS_ACTIVOS')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pCodigo_activo 
					WHERE par_nombre = 'CODIGOS_ACTIVOS' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL CODIGOS ACTIVOS --
				
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, 
				par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'CODIGOS_ACTIVOS', pCodigo_activo, 'CODIGOS ACTIVOS', pUsuario);
				
			END IF;
		END IF;
		
		IF pVigencia <> '' THEN
			SELECT COUNT(par_id) INTO iExiste FROM bdirst: "informix".parametro_sistema WHERE par_status = 'A' AND par_nombre = 'VIGENCIA';
			
			IF NVL(iexiste,0) > 0 THEN
				LET caccion = 'MODIFICA VIGENCIA';
				
				LET cCmd1 ="";	
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'par_id', 'par_alta_fecha', 'par_ultima_mod_fecha', 'par_status', 'par_nombre', 'par_valor', 'par_descripcion', 'par_usuario_alta_id_fk', 'par_usuario_mod_id_fk'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
				LET cCmd1 =""||TRIM(cCmd1)||"SELECT par_id::VARCHAR(10), par_alta_fecha::VARCHAR(10), par_ultima_mod_fecha::VARCHAR(10), par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk::VARCHAR(10), par_usuario_mod_id_fk::VARCHAR(10)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirst:""informix"".parametro_sistema WHERE par_status = 'A' and par_nombre = 'VIGENCIA')";
				
				EXECUTE PROCEDURE "informix".sp_generararchivo_rst(cArchivoRespaldo, cCmd1) INTO cCodRet;
				
				IF cCodRet = '00000' THEN 
					EXECUTE PROCEDURE "informix".sp_bitacora(cAccion, cEntidad, cIp, cArchivoRespaldo, pUsuario, 2) INTO cCodRet;
					
					UPDATE bdirst:"informix".parametro_sistema 
					SET par_valor = pVigencia 
					WHERE par_nombre = 'VIGENCIA' AND par_status = 'A';
					
				ELSE
					LET cCodRet = '99999';
					RETURN cCodRet;
				END IF;
				
			ELSE
				-- SE AGREGA EL REGISTRO SI ES QUE NO EXISTE Y HAY VALOR DEL VIGENCIA --
				
				INSERT INTO bdirst:"informix".parametro_sistema(par_alta_fecha, par_status, par_nombre, par_valor, par_descripcion, par_usuario_alta_id_fk) 
				VALUES( CURRENT, 'A', 'VIGENCIA', pVigencia, 'VIGENCIA', pUsuario);
				
			END IF;
		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JAOIDOR ',
'FECHA: 15/12/2020',
'MODULO: ADMINISTRACIÃN DE ATM',
'FUNCIONALIDAD: Retiro sin Tarjeta',
'DESCRIPCION: SPL encargado de actualizar los parameros retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_actualizainsertaprodtransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1),
		pCccmayor CHAR(10), pCccsub CHAR(10), pCccsubsub CHAR(10), pCccsssub CHAR(10), pCccssssub CHAR(10), pCsector CHAR(10), 
		pAccmayor CHAR(10),	pAccsub CHAR(10), pAccsubsub CHAR(10), pAccsssub CHAR(10), pAccssssub CHAR(10), pAsector CHAR(10),
		pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_actualizainsertaprodtransaccion.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pCccmayor = '' OR pCccsub = '' OR pCccsubsub = '' OR pCccsssub = '' OR pCccssssub = '' OR pCsector = '' OR 
		pAccmayor = '' OR pAccsub = '' OR  pAccsubsub = '' OR pAccsssub = '' OR pAccssssub = '' OR  pAsector = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pBandera = '1' THEN

			UPDATE bdinteg:"informix".si_prodtran SET
			c_ccmayor = pCccmayor,
			c_ccsub = pCccsub,
			c_ccsubsub = pCccsubsub,
			c_ccsssub = pCccsssub,
			c_ccssssub = pCccssssub,
			c_sector = pCsector,
			a_ccmayor = pAccmayor,
			a_ccsub = pAccsub,
			a_ccsubsub = pAccsubsub,
			a_ccsssub = pAccsssub,
			a_ccssssub = pAccssssub,
			a_sector = pAsector
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
		
		ELIF pBandera = '2' THEN
		
			DELETE FROM bdinteg:"informix".si_prodtran 
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
			
		ELIF pBandera = '3' THEN
		
			INSERT INTO bdinteg:"informix".si_prodtran (empresa,  producto,  sistema,  transaccion,  secuencia,  c_ccmayor,  c_ccsub, c_ccsubsub,  c_ccsssub,  c_ccssssub,  c_sector, a_ccmayor,  a_ccsub,  a_ccsubsub, a_ccsssub,  a_ccssssub,  a_sector, user_insert, fecha_insert)
			VALUES (cEmpresa, pProducto, pSistema, pTransaccion, pSecuencia, pCccmayor, pCccsub, pCccsubsub, pCccsssub, pCccssssub, pCsector,  pAccmayor,	pAccsub, pAccsubsub, pAccsssub, pAccssssub, pAsector, pUsuario, CURRENT);
		
		ELSE 
		
			SELECT COUNT(*) 
			INTO iTotales
			FROM bdinteg:"informix".si_prodtran
            WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
			
			IF iTotales > 0 THEN
		
				LET cCodRet = '99999';
		
			END IF
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Insertar, Actualizar y eliminar una transacciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusgenrepsistema(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(150) AS nombre_archivo,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNombreArchivo CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNombreArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;	
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusgenrepsistema.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNombreArchivo,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, nombre_archivo, error_proceso, error
		INTO cStatus, cNombreArchivo, cErrorProceso, cError
		FROM "informix".sw_verificastatusrepxsist WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet, 'I', '', '', ''; 
		ELSE 			
			RETURN cCodRet, cStatus, cNombreArchivo, cErrorProceso, cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 15/01/2021',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado verificar el status de la generacion del reporte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS numero,
			CHAR(50) AS descripcion,
			CHAR(15) AS naturaleza;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumero CHAR(4);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNaturaleza CHAR(15);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumero = '';
	LET cDescripcion = '';
	LET cNaturaleza = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransacciones.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			numero, descripcion, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza 
			INTO cNumero, cDescripcion, cNaturaleza
			FROM bdinteg:"informix".si_transacc
			WHERE empresa = cEmpresa 
			AND sistema = pSistema 
			ORDER BY numero ASC

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los las Transacciones por sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS sistema, 
			CHAR(4) AS producto, 
			CHAR(4) AS transaccion,
			CHAR(50) AS descTran,
			CHAR(1) AS naturaleza,
			INTEGER AS secuencia, 
			CHAR(10) AS c_ccmayor, 
			CHAR(10) AS c_ccsub, 
			CHAR(10) AS c_ccsubsub, 
			CHAR(10) AS c_ccsssub, 
			CHAR(10) AS c_ccssssub, 
			CHAR(10) AS c_sector, 
			CHAR(10) AS a_ccmayor, 
			CHAR(10) AS a_ccsub, 
			CHAR(10) AS a_ccsubsub, 
			CHAR(10) AS a_ccsssub, 
			CHAR(10) AS a_ccssssub, 
			CHAR(10) AS a_sector;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	--DEFINE iNoRegistros INTEGER;
	--DEFINE iRegistros INTEGER;
	--DEFINE iRecuperacion INTEGER;
	DEFINE cSistema CHAR(3);
	DEFINE cProducto CHAR(4);
	DEFINE cTransaccion CHAR(4);
	DEFINE cDescTran CHAR(50);
	DEFINE cNaturaleza CHAR(1);
	DEFINE iSecuencia INTEGER;
	DEFINE cCccmayor CHAR(10);
	DEFINE cCccsub CHAR(10);
	DEFINE cCccsubsub CHAR(10);
	DEFINE cCccsssub CHAR(10);
	DEFINE cCccssssub CHAR(10);
	DEFINE cCsector CHAR(10);
	DEFINE cAccmayor CHAR(10);
	DEFINE cAccsub CHAR(10);
	DEFINE cAccsubsub CHAR(10);
	DEFINE cAccsssub CHAR(10);
	DEFINE cAccssssub CHAR(10); 
	DEFINE cAsector CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	--LET iNoRegistros = 0;
	--LET iRegistros = 0;
	--LET iRecuperacion = 0;
	LET cSistema = '';
	LET cProducto = '';
	LET cTransaccion = '';
	LET cDescTran = '';
	LET cNaturaleza = '';
	LET iSecuencia = 0;
	LET cCccmayor = '';
	LET cCccsub = '';
	LET cCccsubsub = '';
	LET cCccsssub = '';
	LET cCccssssub = '';
	LET cCsector = '';
	LET cAccmayor = '';
	LET cAccsub = '';
	LET cAccsubsub = '';
	LET cAccsssub = '';
	LET cAccssssub = '';
	LET cAsector = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransaccion.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT a.sistema, a.producto, transaccion, TRIM(c.descripcion)trandesc, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza, 
		secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
		INTO cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector
		FROM bdinteg:"informix".si_prodtran a, bdinteg:"informix".si_transacc c 
		WHERE c.empresa = a.empresa 
		AND c.numero = a.transaccion 
		AND c.sistema = a.sistema 
		AND a.secuencia = pSecuencia
		AND a.transaccion = pTransaccion
		AND a.producto = pProducto 
		AND a.sistema = pSistema
		AND a.empresa = cEmpresa;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una Transaccion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultaprodtransaccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaprodtransaccion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		

		SELECT COUNT(*) 
		INTO iTotales
		FROM bdinteg:"informix".si_prodtran
        WHERE empresa = cEmpresa
		AND sistema = pSistema
		AND producto = pProducto
		AND transaccion = pTransaccion
		AND secuencia = pSecuencia;
			
		IF iTotales > 0 THEN
			LET cCodRet = '99999';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 25/02/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una transacciÃÂ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultanombrecatalogo(pUsuario CHAR(8), pIdFuncion CHAR(10), pCcmayor CHAR(10), pCcsub CHAR(10), pCcsubsub CHAR(10), pCcssubsub CHAR(10), pCcsssubsub CHAR(10), pSector CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(50);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultanombrecatalogo.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCcmayor = '' OR pCcsub = '' OR pCcsubsub = '' OR pCcssubsub = '' OR pCcsssubsub = '' OR pSector = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT NVL(TRIM(nombre), 'CTA CONTABLE NO EXISTE')
		INTO cNombre 
		FROM bdinteg:si_catalog
        WHERE empresa = cEmpresa
        AND ccmayor = pCcmayor
        AND ccsub = pCcsub
        AND ccsubsub = pCcsubsub
        AND ccssubsub = pCcssubsub
        AND ccsssubsub = pCcsssubsub
        AND sector = pSector;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cNombre;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar EL CATALOGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarepentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pRutaDescarga CHAR(100))
		 RETURNING CHAR(5) AS codret,
			CHAR(100) AS reporte_xls;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cNombreRepXls CHAR(100);
	DEFINE cNombreRepTxt CHAR(45);
	DEFINE cRutaGralXls CHAR(150);
	DEFINE cRutaGralTxt CHAR(150);
	DEFINE cTpoSuc CHAR(10);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dHoy DATE;
	DEFINE cStr7 CHAR(50);
	DEFINE cStr9 CHAR(50);
	DEFINE cIdPlantilla CHAR(5);
	--DEFINE ven_transacc SMALLINT;
	--DEFINE bInTransaction BOOLEAN;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;

	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cNombreRepXls = '';
	LET cNombreRepTxt = '';
	LET cRutaGralXls = '';
	LET cRutaGralTxt = '';
	LET cTpoSuc = '';
	LET cNombreReporteHist = '';
	LET dFechaHoy = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET cIdPlantilla = '';
	--LET bInTransaction = 'f';
	--LET ven_transacc = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				--IF ven_transacc = 1 THEN
					--ROLLBACK ;		
				--END IF;
				RETURN cCodRet,cNombreRepXls;
			END EXCEPTION;
		
			ON EXCEPTION IN (-668)			
				
			END EXCEPTION WITH RESUME;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_generarepentradasalidacaja.out';
			--TRACE ON;
		
			IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNombreRepXls;
			END IF;
		
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,cNombreRepXls;
			END IF;
			
			--BEGIN;
			--IF bInTransaction = 'f' THEN
				--COMMIT;
			--END IF;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
			LET cNombreRepXls = 'ENTRADASSALIDAS_'||pUsuario||"_"||TO_CHAR(CURRENT, '%d%m%Y')||'.xls';
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);

			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;	
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportesentradasalida 
				WHERE usuario_insert = pUsuario
				AND fecha_reporte < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				DELETE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} FROM  bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;  
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'TIPO', 'DIA SOLICITUD', 'DIA ENVIO', 'DIA RECEPCION', 'PLAZA', 'SUCURSAL', 'CAJA GENERAL', 'MONTO', 'STATUS', 'FOLIO SUCURSAL', 'FOLIO OPERACION', 'USUARIO SOLICITO', 'USUARIO ENVIO', 'USUARIO RECIBIO', 'DIA REVISION', 'USUARIO REVERSO'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||"SELECT CASE WHEN tipo_suc = 'S' THEN 'SUCURSAL' WHEN tipo_suc = 'C' THEN 'ATM' END , TO_CHAR(fecsol, '%d/%m/%Y'), TO_CHAR(fecenvio, '%d/%m/%Y'), TO_CHAR(fecrecepcion, '%d/%m/%Y'), nomplaza::CHAR(50), ''''||sucursal::CHAR(50), codproveedor::CHAR(50), monto::CHAR(50), desstatus::CHAR(50), ''''||folsuc::CHAR(50), ''''||foloper::CHAR(50), ''''||usuariosol::CHAR(50), ''''||usuarioenv::CHAR(50), ''''||usuariorecep::CHAR(50), TO_CHAR(fecrever, '%d/%m/%Y'), ''''||vusuariorever::CHAR(50)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".tmp_entradasalida ";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_usuario = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			--GENERACION DE ARCHIVO XLS
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGralXls)||" > "||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGralXls)||'; /usr/bin/mv '||TRIM(cRutaGralXls)||'.tmp '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGralXls);
			SYSTEM TRIM(cSql);
			
			DELETE {+INDEX (bdicnweb:sw_ctrlgenreportesentradasalida idx_sw_ctrlgenreportesentradasalida)} FROM   bdicnweb:"informix".sw_ctrlgenreportesentradasalida WHERE nombre_reporte = TRIM(cNombreRepXls);
			
			INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesentradasalida(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
			VALUES(TRIM(cNombreRepXls),dFechaHoy,dHoraHoy,pUsuario);
		
			/*
			-- NOTIFICACIÃN VÃA CORREO ELECTRÃNICO EXITOSO
			LET cStr7 = 'GENERACIÃN DEL ARCHIVO XLS';
			LET cStr9 = 'CAJA GENERAL';
			LET dHoy = CURRENT;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1', 
			TRIM(cIdPlantilla),
			TRIM(cIdPlantilla), 
			pUsuario, 
			'',
			'', 
			'1', 
			'',
			'',
			'',
			'',
			'',
			TRIM(pTituloPlantilla),
			TRIM(cStr7),
			'',
			TRIM(cStr9),
			'',
			'',
			'',
			'0',
			'0',
			'0',
			'0',
			'0',
			dHoy,
			dHoy) INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
			END IF;
			*/
			
			--LET ven_transacc = 0;
			--IF bInTransaction = 't' THEN
				--BEGIN;
			--END IF;
		
			RETURN cCodRet,cNombreRepXls;
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 05/02/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ENTRADAS SALIDAS DE CAJA GENERAL',
'DESCRIPCION: SPL que genera el reporte de Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportexlsdepositoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
				CHAR(50) AS nombreArchivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;

	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;	
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreportexlsdepositoscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;	
		
		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'DepositosCoppelProcesados_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.xls';		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		LET cCmd1 ="";
		LET cCmd1 = "SELECT 'FOLIO','FECHA','FOLIO COMPROBANTE','NO. SUC / ATM','NO. CAJA GENERAL','PLAZA','IMPORTE COMPROBANTE','IMPORTE FICHA(S)','BILLETE \$1000',";
		LET cCmd1 =""||TRIM(cCmd1)||"'BILLETE \$500','BILLETE \$200','BILLETE \$100','BILLETE \$50', 'BILLETE \$20', 'MORRALLA','FALTANTE','SOBRANTE', 'ESTATUS' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT folio_oper, NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), comprobante, suc_coppel, caja_general, plaza, imp_comprobante::CHAR(21), ";
		LET cCmd1 =""||TRIM(cCmd1)||" imp_ficha::CHAR(21), cantidad_1::CHAR(11), cantidad_2::CHAR(11), cantidad_3::CHAR(11), cantidad_4::CHAR(11), cantidad_5::CHAR(11), ";
		LET cCmd1 =""||TRIM(cCmd1)||" cantidad_6::CHAR(11), cantidad_7::CHAR(11), faltante::CHAR(21), sobrante::CHAR(21), estatus FROM bdisuc:""informix"".ss_temp_deposito_coppel";
			
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
			
		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
			
		LET cSql = '';
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
			
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'depcoppel.sql';
		SYSTEM TRIM(cSql);
		
		--DELETE FROM bdisuc:"informix".ss_temp_deposito_coppel;
		
		RETURN cCodRet, cNombreReporte;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 12/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de generar el reporte de la carga de archivos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusexpedientes(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusexpedientes.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificastatusexpediente WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/05/2021',
'MODULO: ',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_cuentadoctos(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumCte CHAR(20),pTipoCte SMALLINT)
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE iIsamErrorSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET iIsamErrorSp = 0;
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_cuentadoctos.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cuentadoctos_soc(pNumCte,pTipoCte) 
		INTO cCodRetSp,iIsamErrorSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cuentadoctos_soc';
		ELIF iCodRetSp = 99999 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100 THEN
			LET cCodRet = '01163'; --EL CLIENTE [CLIENTE 1] ES UN CLIENTE MORAL
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '01164'; --CLIENTE [CLIENTE 1] CON ADEUDO IDE, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 300 THEN
			LET cCodRet = '01165'; --CLIENTE [CLIENTE 1] CON BANCA ELECTRÓNICA AVANZADA, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 400 THEN
			LET cCodRet = '01166'; --CLIENTE [CLIENTE 1] FUSIONADO, NO SE PUEDE EFECTUAR LA FUSIÓN
		ELIF iCodRetSp = 500 THEN
			LET cCodRet = '01167'; --EXISTEN PROBLEMAS CON EL EXPEDIENTE DEL CLIENTE. FAVOR DE AVISAR A SISTEMAS
		ELIF iCodRetSp <> 0 THEN
			LET cCodRet = '01168'; --ERROR, FAVOR DE AVISAR A SISTEMAS
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar la validacion de imagen de los clientes a fusionar.',
'BD: bdicnweb',
'MODIFICÓ: Daniel Reyes Guillen 13-05-2021 Se descomenta línea de error 200';

CREATE PROCEDURE "informix".sp_ris_consultaproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(2))
		RETURNING CHAR(5) AS codret,
				CHAR(10) AS codigo,
				CHAR(100) AS descProd;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(1000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	LET cCmd1 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescProd;
		END EXCEPTION;

		SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaproductos.out';
		TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM "informix".sw_ristras_cmbproducto WHERE usuario_insert = pUsuario;

		SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion
		INTO cBase, cDescripcion
		FROM bdinteg:si_sistema
		WHERE sistema = pSistema;

		LET iTamReg = LENGTH(TRIM(cDescripcion));
		LET iPosCaracter = INSTR(cDescripcion, ":");
		LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
		LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
		LET iPosCaracter2 = INSTR(cDato2, ":");
		LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
		LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));

		LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_cmbproducto (usuario_insert, codigo, descripcion) SELECT '" || pUsuario || "'," || TRIM(cCampo1) || ", " || TRIM(cCampo2) || " FROM " || TRIM(cBase) || ":""informix""." || TRIM(cTabla) || " WHERE empresa = '" || cEmpresa || "'; "" > /tmp/mfinis/" || cFile;

		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
		SYSTEM TRIM(cCmd1);

		FOREACH
			SELECT codigo, descripcion
			INTO cCodigo, cDescProd
			FROM "informix".sw_ristras_cmbproducto
			WHERE usuario_insert = pUsuario
            ORDER BY codigo ASC

			LET cDescProd = cDescProd || " [" || cCodigo || "]";

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCodigo, cDescProd WITH RESUME;

		END FOREACH;

		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Productos por Sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultacriteriostransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistema CHAR(2), pProducto CHAR(10),  pTransaccion CHAR(4), pDescripcion CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(100) AS dato1,
				CHAR(100) AS dato2,
				CHAR(100) AS dato3,
				CHAR(10) AS dato4,
				CHAR(10) AS dato5,
				CHAR(10) AS dato6,
				CHAR(10) AS dato7,
				CHAR(10) AS dato8,
				CHAR(10) AS dato9,
				CHAR(10) AS dato10,
				CHAR(10) AS dato11,
				CHAR(10) AS dato12,
				CHAR(10) AS dato13,
				CHAR(10) AS dato14,
				CHAR(10) AS dato15,
				CHAR(10) AS dato16;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cCmd2 CHAR(2000);
	DEFINE cCmd3 CHAR(2000);
	DEFINE cCmd4 CHAR(2000);
	DEFINE cCmd5 CHAR(2000);
	DEFINE cCmd6 CHAR(2000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);
	DEFINE cDato1 CHAR(100);
	DEFINE cDato2_2 CHAR(100);
	DEFINE cDato3 CHAR(100);
	DEFINE cDato4 CHAR(10);
	DEFINE cDato5 CHAR(10);
	DEFINE cDato6 CHAR(10);
	DEFINE cDato7 CHAR(10);
	DEFINE cDato8 CHAR(10);
	DEFINE cDato9 CHAR(10);
	DEFINE cDato10 CHAR(10);
	DEFINE cDato11 CHAR(10);
	DEFINE cDato12 CHAR(10);
	DEFINE cDato13 CHAR(10);
	DEFINE cDato14 CHAR(10);
	DEFINE cDato15 CHAR(10);
	DEFINE cDato16 CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cCmd3 = '';
	LET cCmd4 = '';
	LET cCmd5 = '';
	LET cCmd6 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';
	LET cDato1 = '';
	LET cDato2_2 = '';
	LET cDato3 = '';
	LET cDato4 = '';
	LET cDato5 = '';
	LET cDato6 = '';
	LET cDato7 = '';
	LET cDato8 = '';
	LET cDato9 = '';
	LET cDato10 = '';
	LET cDato11 = '';
	LET cDato12 = '';
	LET cDato13 = '';
	LET cDato14 = '';
	LET cDato15 = '';
	LET cDato16 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultacriteriostransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pRegistros = 0 THEN
			DELETE FROM "informix".sw_ristras_consultacriteriostransacciones WHERE usuario_insert = pUsuario;
		
			SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion 
			INTO cBase, cDescripcion
			FROM bdinteg:si_sistema 
			WHERE sistema = pSistema;
			
			LET iTamReg = LENGTH(TRIM(cDescripcion));
			LET iPosCaracter = INSTR(cDescripcion, ":");
			LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
			LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
			LET iPosCaracter2 = INSTR(cDato2, ":");
			LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
			LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));
		
			LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_consultacriteriostransacciones (usuario_insert,dato1,dato2,dato3,dato4,dato5,dato6,dato7,dato8,dato9,dato10,dato11,dato12,dato13,dato14,dato15,dato16) SELECT '" || pUsuario || "'," || " TRIM(b.descripcion) || ' [' || TRIM(a.sistema) || ']', " || "d." || Trim(cCampo2) || "|| ' [' || a.producto || ']', '[' || transaccion || '] ' || TRIM(c.descripcion), secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector FROM bdinteg:si_prodtran a, bdinteg:si_sistema b, bdinteg:si_transacc c, " || Trim(cBase) || ":" || Trim(cTabla) || " d";
			LET cCmd2 = "" || TRIM(cCmd1) || " WHERE d.empresa = a.empresa AND d." || Trim(cCampo1) || " = a.producto AND c.empresa = a.empresa AND c.numero = a.transaccion AND b.sistema = a.sistema";
		
			IF pProducto <> '' THEN
				LET cCmd3 = TRIM(cCmd2) || " AND a.producto LIKE '" || TRIM(pProducto) || "%'";
			ELSE
				LET cCmd3 = TRIM(cCmd2);
			END IF;
		
			IF pTransaccion <> '' THEN
				LET cCmd4 = TRIM(cCmd3) || " AND a.transaccion LIKE '" || TRIM(pTransaccion) || "%'";
			ELSE
				LET cCmd4 = TRIM(cCmd3);
			END IF;
		
			IF pDescripcion <> '' THEN
				LET cCmd5 = TRIM(cCmd4) || " AND c.descripcion LIKE '" || TRIM(pDescripcion) || "%'";
			ELSE
				LET cCmd5 = TRIM(cCmd4);
			END IF;
		
			LET cCmd6 = TRIM(cCmd5) || " ORDER BY 1,2,3, a.secuencia"" > /tmp/mfinis/" || cFile;
		
			SYSTEM TRIM(cCmd6);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
			SYSTEM TRIM(cCmd1);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
			SYSTEM TRIM(cCmd1);
		END IF;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion  
			dato1, dato2, dato3, dato4, dato5, dato6, dato7, dato8, dato9, dato10, dato11, dato12, dato13, dato14, dato15, dato16
			INTO cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16
			FROM "informix".sw_ristras_consultacriteriostransacciones
			WHERE usuario_insert = pUsuario
			ORDER BY 3,4
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16 WITH RESUME;
		
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los por diferentes criterios de busqueda',
'AUTOR: VerÃÂ³nica SÃÂ¡nchez Tlacomulco',
'FECHA: 04/03/2021',
'DESCRIPCION: Se realiza ajuste a SP para realizar ordenamiento de informaciÃÂ³n por secuencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultasistemas(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			 CHAR(2) AS sistema,
			 CHAR(35) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSistema CHAR(2);
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSistema = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultasistemas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT sistema, descripcion  
			INTO cSistema, cDescripcion 
			FROM bdinteg:si_sistema
			WHERE utiliza_productos = 'S' 
			--AND descripcion NOT IN ('TRANSFERENCIAS') 
			ORDER BY descripcion
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cSistema, cDescripcion WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Sistemas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_formararchivodedeclaracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaXML CHAR(6), pDeclaracion CHAR(1), pTipoDeclaracion CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cArchivo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cArchivo = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
			
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;

			RETURN cCodRet, cArchivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_ope_formararchivodedeclaracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaXML = '' OR pDeclaracion = '' OR pTipoDeclaracion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivo;
		END IF;

		DELETE FROM "informix".sw_verificastatusformarchivo WHERE usuario_insert = pUsuario;
		
		INSERT INTO "informix".sw_verificastatusformarchivo(usuario_insert, status,	error_proceso, error, nombre_archivo) VALUES(pUsuario,'I','','','');

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_formararchivodedeclaracion', CURRENT, null);
		


		LET pFechaXML=pFechaXML;
		LET pDeclaracion=pDeclaracion;
		LET pTipoDeclaracion=pTipoDeclaracion;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
			RETURN cCodRet, cArchivo;

			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END IF;

		
		
		LET pFechaXML=pFechaXML;
		LET pDeclaracion=pDeclaracion;
		LET pTipoDeclaracion=pTipoDeclaracion;

		EXECUTE PROCEDURE bdilide:"informix".sp_formararchivodedeclaracion2(pFechaXML, pDeclaracion, pTipoDeclaracion)
		--EXECUTE PROCEDURE bdilide:"informix".sp_formararchivodedeclaracion(pFechaXML, pDeclaracion, pTipoDeclaracion)
		INTO cCodRetSp, cArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_formararchivodedeclaracion";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_formararchivodedeclaracion' AND fecha_fin IS NULL; 
		
		IF cCodRet = '00000' THEN
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'T', error = cCodRet, nombre_archivo = cArchivo
			WHERE usuario_insert = pUsuario;
		ELSE
			UPDATE "informix".sw_verificastatusformarchivo
			SET status = 'E', error = cCodRet
			WHERE usuario_insert = pUsuario;
		END IF;

		RETURN cCodRet, cArchivo;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa IDE',
'DESCRIPCION: SPL encargado de generar archivo declarcacion IDE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusarchivodeclaracionide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(25) AS nom_archivo,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNomArchivo CHAR(25);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNomArchivo = '';
	

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;	
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusentradasalida.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;
		END IF;
		
		
		
		SELECT status,nom_archivo,error_proceso,error
		INTO cStatus,cNomArchivo,cErrorProceso,cError
		FROM bdicnweb:sw_verificastatusarchivodeclaracionide WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cNomArchivo,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: VERIFICA EL ESTATUS DEL PROCESO ',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_escribirarchivodedeclaracionide(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchivo CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(25) AS nombreArchivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFile CHAR(25);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFile = '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
			
			UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;            

			RETURN cCodRet, cFile;
			
                        
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_escribirarchivodedeclaracionide.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
         DELETE FROM bdicnweb:"informix".sw_verificastatusarchivodeclaracionide WHERE usuario_insert = TRIM(pUsuario);
                
        -- SE INSERTA PROCESO
         INSERT INTO bdicnweb:"informix".sw_verificastatusarchivodeclaracionide(usuario_insert,status,nom_archivo,error_proceso,error) VALUES(pUsuario,'I','','',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' THEN
			LET cCodRet = '00003';
			  --Actualiza proceso erroneo
                     UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
					 SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, cFile;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_escribirarchivodedeclaracionide', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
			 --Actualiza proceso erroneo
                    UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
				    SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, cFile;
		END IF;
		
		
		
		EXECUTE PROCEDURE bdilide:"informix".sp_escribirarchivodedeclaracionide2(pArchivo)
		INTO cCodRetSp, cFile;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_escribirarchivodedeclaracionide";
			--Actualiza proceso erroneo
            UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
		END IF;

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_escribirarchivodedeclaracionide' AND fecha_fin IS NULL;
		---Actualiza proceso exitoso
        UPDATE bdicnweb:"informix".sw_verificastatusarchivodeclaracionide
	    SET status = 'T', error_proceso = 'N', nom_archivo = cFile WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, cFile;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa IDE',
'DESCRIPCION: SPL encargado de escribir archivo declarcacion IDE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusformaarchivoide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(20) AS nombre_archivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNombreArch CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNombreArch = '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_verificastatusformaarchivoide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;
		END IF;
		
		
		
		SELECT status,error_proceso,error, nombre_archivo
		INTO cStatus, cErrorProceso, cError, cNombreArch
		FROM "informix".sw_verificastatusformarchivo WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet, cStatus, cErrorProceso, cError, cNombreArch;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion IDE',
'DESCRIPCION: SPL encargado verificar el status del proceso de creacion del archivo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultafechaprocesoanual(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(5) AS status,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFecha DATE;
	DEFINE cStatus CHAR(1);
	DEFINE dUltimoDiaMes DATE;
	DEFINE iexisteFechaProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFecha = DATE(1);
	LET cStatus = '';
	LET dUltimoDiaMes = DATE(1);
	LET iexisteFechaProceso = 0;
	


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;

			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/bdicnweb/sp_ope_consultafechaprocesoanual.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultafechaprocesoanual', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;
		
		
		
		SELECT COUNT(a.fech_proceso) 
		INTO iexisteFechaProceso
		FROM bdilide:"informix".sl_procesos a
		WHERE a.proceso = 'decanual' AND a.fech_proceso = pFechaProceso;
		
		SELECT LAST_DAY(pFechaProceso)
		INTO dUltimoDiaMes
		FROM systables WHERE tabid = 1;
		
		IF iexisteFechaProceso > 0 THEN -- LA COMPARACIÃN DEBERÃ SER CON LA VARIABLE DEL INTO, DEJE ESTA SOLO COMO EJEMPLO PARA LA LOGICA DEL SPL
			
			SELECT a.fech_proceso, a.status
			INTO dFecha, cStatus
			FROM bdilide:"informix".sl_procesos a
			WHERE a.proceso = 'decanual' AND a.fech_proceso = dUltimoDiaMes;
			
			IF dFecha = dUltimoDiaMes OR cStatus = '1' THEN
		
				EXECUTE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario, pIdFuncion)
				INTO cCodRetSp, cDescripcion;
				
				LET cDescripcion = cDescripcion || (SELECT year(pFechaProceso) FROM systables WHERE tabid = 1);
			ELSE
				LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
			END IF;
		
		ELIF iexisteFechaProceso = 0 THEN
			LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaprocesoanual' AND fecha_fin IS NULL;

		RETURN cCodRet, dFecha, cStatus, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a fecha de proceso (DECLARACIÃN ANUAL)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
		
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultarutalmacenamientoxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultarutalmacenamientoxml', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;

		
		
		SELECT a.desc_valor
		INTO cDescripcion
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '13' AND a.valor = '01';
		
		IF cDescripcion = ''  THEN
			LET cCodRet = '00017';
		END IF;

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultarutalmacenamientoxml' AND fecha_fin IS NULL;
		
		RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a la ruta en donde se almacenan los archivos xml',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacomboparametro(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			   	CHAR(8) AS cve_param,
				CHAR(80) AS desc_valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCveParam CHAR(8);
	DEFINE cDescValor CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	LET cCveParam = '';
	LET cDescValor = '';

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacomboparametro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cDescValor;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultacomboparametro', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cDescValor;
		END IF;

		
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion A.cve_param, B.descripcion 
			INTO cCveParam, cDescValor
			FROM bdilide:"informix".sl_parametros AS A 
			INNER JOIN bdilide:"informix".sl_cveparam AS B ON A.cve_param = B.cve_param 
			WHERE A.cve_param IN ('08', '11', '13', '18', '20', '24') 
			GROUP BY A.cve_param, B.descripcion 
			ORDER BY 1, 2			
		
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet, cCveParam, cDescValor WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;

			RETURN cCodRet, cCveParam, cDescValor;
		END IF;	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultacomboparametro' AND fecha_fin IS NULL;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de consular el combo seleccion parametro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizaparametrosgral(pUsuario CHAR(8), pIdFuncion CHAR(10), pCveParametro CHAR(8), cValor CHAR(10), cDescValor CHAR(50), pActaulizaValor CHAR(1))
		RETURNING CHAR(5) AS codret;						
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescValorAnt CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescValorAnt = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;

			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/Componentes_a_liberar_IDE/bdicnweb/SPL_PROBADOS_PARA_PRODUCCION/sp_ope_actualizaparametrosgral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCveParametro = '' OR cValor = '' OR pActaulizaValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		
		
		IF pActaulizaValor = '1' THEN
			SELECT desc_valor INTO cDescValorAnt
			FROM bdilide:"informix".sl_parametros
			WHERE cve_param = pCveParametro AND valor = cValor;
			
			INSERT INTO "informix".sw_bitacoractualizaciondatos(usuario_insert, nombre_tabla, valor_antes, valor_despues, fecha_inicio, fecha_fin) 
			VALUES(pUsuario, 'sl_parametros', cDescValorAnt, null, CURRENT, null);

			UPDATE bdilide:"informix".sl_parametros SET desc_valor = cDescValor WHERE cve_param = pCveParametro AND valor = cValor;
			
			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT, valor_despues = cDescValor
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;
		ELSE
			SELECT valor INTO cDescValorAnt
			FROM bdilide:"informix".sl_parametros
			WHERE cve_param = pCveParametro
			AND valor=cValor;
			
			INSERT INTO "informix".sw_bitacoractualizaciondatos(usuario_insert, nombre_tabla, valor_antes, valor_despues, fecha_inicio, fecha_fin) 
			VALUES(pUsuario, 'sl_parametros', cDescValorAnt, null, CURRENT, null);

			UPDATE bdilide:"informix".sl_parametros SET desc_valor = cDescValor WHERE valor = cValor AND cve_param = pCveParametro;

			UPDATE "informix".sw_bitacoractualizaciondatos 
			SET fecha_fin = CURRENT, valor_despues = cValor
			WHERE usuario_insert = pUsuario AND fecha_fin IS NULL;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de actualizar los parametros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusdeclide(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(80) AS mensaje;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cMensaje = '';


	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusdeclide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;
		END IF;
		
		
		
		SELECT status,error_proceso,error,mensaje
		INTO cStatus, cErrorProceso, cError, cMensaje
		FROM "informix".sw_verificastatusdeclide WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet, cStatus, cErrorProceso, cError, cMensaje;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado verificar el status del proceso de carga de archivo coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_obtienenombrempresa(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienenombrempresa.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_obtienenombrempresa', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
		
		
		SELECT a.desc_valor
		INTO cDescripcion
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '08' AND a.valor = '02';
		
		IF NVL(cDescripcion,'') = ''  THEN
			LET cCodRet = '00017';
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_obtienenombrempresa' AND fecha_fin IS NULL;
		
RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de Consulta Para Obtener El Nombre De La Empresa Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametroxsd(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE existe_ArchivoXSD INTEGER;
	DEFINE cDescripcion CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET existe_ArchivoXSD = 0;
	LET cDescripcion = '';


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametroxsd.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametroxsd', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
	
		
		SELECT COUNT (a.desc_valor) 
		INTO existe_ArchivoXSD 
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '20' AND a.valor = '01';

		IF existe_ArchivoXSD > 0 THEN 
			SELECT a.desc_valor
			INTO cDescripcion
			FROM bdilide:"informix".sl_parametros a
			WHERE a.cve_param = '20' AND a.valor = '01';
		ELSE
			LET cCodRet = '00017';
		END IF
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametroxsd' AND fecha_fin IS NULL;
		
		RETURN cCodRet, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de Consulta Para Validar La Existencia Del ParÃ¡metro Archivo XSD',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametrosgralide(pUsuario CHAR(8), pIdFuncion CHAR(10), pCveParam CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			   	CHAR(8) AS cve_param,
				CHAR(10) AS valor,
				CHAR(50) AS desc_valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRecuperacion INTEGER;	
	DEFINE cCveParam CHAR(8);
	DEFINE cValor CHAR(10);
	DEFINE cDescValor CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRecuperacion = 0;
	LET cCveParam = '';
	LET cValor = '';
	LET cDescValor = '';
	


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametrosgralide.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveParam = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametrosgralide', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;
		
	
		
		IF pCveParam = '08' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor IN ('01','02','03','04','05','06','07') 
				ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '11' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor = '01' ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '13' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam	AND valor IN ('01','03') ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '18' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor IN ('01','02','03','04') ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '20' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam AND valor = '01' ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		ELIF pCveParam = '24' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion cve_param, valor, desc_valor 
				INTO cCveParam, cValor, cDescValor
				FROM bdilide:"informix".sl_parametros 
				WHERE cve_param = pCveParam ORDER BY 1, 2
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet, cCveParam, cValor, cDescValor WITH RESUME;
				
			END FOREACH;
		
		END IF;	
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescValor;
		END IF;	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosgralide' AND fecha_fin IS NULL;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 05/10/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Administrador de Parametros',
'DESCRIPCION: SPL encargado de Consular el grid de parametros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaparametrosenviosat(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS cve_param,
			CHAR(10) AS valor,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE existenParametros 	INTEGER;
	DEFINE cCveParam 			CHAR(8);
	DEFINE cValor 				CHAR(10);
	DEFINE cDescripcion 		CHAR(50);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET existenParametros 		= 0;
	LET cCveParam 				= '';
	LET cValor 					= '';
	LET cDescripcion 			= '';
	
	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaparametrosenviosat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaparametrosenviosat', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF;

		
		
		SELECT COUNT(*) 
		INTO existenParametros
		FROM bdilide:"informix".sl_parametros a
		WHERE a.cve_param = '18';
		
		IF existenParametros >= 3 THEN
		
			FOREACH 
				SELECT a.cve_param, a.valor, a.desc_valor
				INTO cCveParam, cValor, cDescripcion
				FROM bdilide:"informix".sl_parametros a
				WHERE a.cve_param = '18'
				ORDER BY a.valor DESC
				
				RETURN cCodRet, cCveParam, cValor, cDescripcion WITH RESUME;
			
			END FOREACH;
		
		ELSE 
			LET cCodRet = '01220'; -- NO EXISTEN LOS PARÃMETROS NECESARIOS PARA ENVIAR EL ARCHIVO AL SAT, FAVOR DE REVISAR EN EL ADMINISTRADOR DE PARÃMETROS.
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
			RETURN cCodRet, cCveParam, cValor, cDescripcion;
		END IF	
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaparametrosenviosat' AND fecha_fin IS NULL;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener los parÃ¡metros a mostrar en la pantalla transmisiÃ³n del archivo al SAT',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultaiprutacarga(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET iRegistros = 0;
	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultaiprutacarga.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultaiprutacarga', CURRENT, null);

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;
		
	
		
		FOREACH 
			SELECT a.desc_valor 
			INTO cDescripcion
			FROM bdilide:"informix".sl_parametros a
			WHERE (a.cve_param = '11' AND a.valor = '01') OR (a.cve_param = '13' AND a.valor = '03')

			LET iRegistros = iRegistros + 1;

			RETURN cCodRet, cDescripcion WITH RESUME;
		END FOREACH;
		
		IF iRegistros = 0  THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
			RETURN cCodRet, cDescripcion;
		END IF;	

		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultaiprutacarga' AND fecha_fin IS NULL;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Transmision archivos SAT',
'DESCRIPCION: SPL encargado de consulta para obtener la ip y la ruta de descarga del archivo .gz',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultafechaproceso(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(1) AS status,
			CHAR(50) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFecha DATE;
	DEFINE cStatus CHAR(1);
	DEFINE dUltimoDiaMes DATE;
	DEFINE iexisteFechaProceso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescripcion = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFecha = DATE(1);
	LET cStatus = '';
	LET dUltimoDiaMes = DATE(1);
	LET iexisteFechaProceso = 0;
	

	SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultafechaproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;

		INSERT INTO "informix".sw_bitacoraprocedimientoside(usuario_insert, nombre_procedimiento, fecha_inicio, fecha_fin) 
		VALUES(pUsuario, 'sp_ope_consultafechaproceso', CURRENT, null);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_bitacoraprocedimientoside 
			SET fecha_fin = CURRENT
			WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
			RETURN cCodRet, dFecha, cStatus, cDescripcion;
		END IF;
		
		
		
		SELECT COUNT(a.fech_proceso) 
		INTO iexisteFechaProceso
		FROM bdilide:"informix".sl_procesos a
		WHERE a.proceso = 'decmensual' AND a.fech_proceso = pFechaProceso;
		
		SELECT LAST_DAY(pFechaProceso)
		INTO dUltimoDiaMes
		FROM systables WHERE tabid = 1;
		
		IF iexisteFechaProceso > 0 THEN -- LA COMPARACIÃN DEBERÃ SER CON LA VARIABLE DEL INTO, DEJE ESTA SOLO COMO EJEMPLO PARA LA LOGICA DEL SPL
			
			SELECT a.fech_proceso, a.status
			INTO dFecha, cStatus
			FROM bdilide:"informix".sl_procesos a
			WHERE a.proceso = 'decmensual' AND a.fech_proceso = dUltimoDiaMes;
			
			IF dFecha = dUltimoDiaMes OR cStatus = '1' THEN
		
				EXECUTE PROCEDURE "informix".sp_ope_consultarutalmacenamientoxml(pUsuario, pIdFuncion)
				INTO cCodRetSp, cDescripcion;
				
				LET cDescripcion = cDescripcion || (SELECT year(pFechaProceso) FROM systables WHERE tabid = 1);
			ELSE
				LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
			END IF;
		
		ELIF iexisteFechaProceso = 0 THEN
			LET cCodRet = '01221'; -- PRIMERO DEBE GENERAR EL REPORTE PARA PODER GENERAR EL ARCHIVO XML, VERIFIQUE.	
		END IF;
		
		UPDATE "informix".sw_bitacoraprocedimientoside 
		SET fecha_fin = CURRENT
		WHERE usuario_insert = pUsuario AND nombre_procedimiento = 'sp_ope_consultafechaproceso' AND fecha_fin IS NULL;
		
		RETURN cCodRet, dFecha, cStatus, cDescripcion;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: JOHNATTAN ESQUIVEL SANCHEZ',
'FECHA: 03/10/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Declaracion Informativa',
'DESCRIPCION: SPL encargado de consulta para obtener el valor correspondiente a fecha de proceso (DECLARACION MENSUAL)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_altamodificacion_piezas_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pIdDenominacion INTEGER,pNumRecibo CHAR(10), pTipoPieza CHAR(1), pSerie CHAR(40), pFolio CHAR(40), pFechaEmision DATE, pNumPiezas INTEGER, pNota CHAR(200), pNumGuia CHAR(12),pFolioBanxico CHAR(40), pDictamenBanxico INTEGER,pNumLoteBanxico CHAR(40), pEstatus INTEGER, pIdPieza INTEGER, pTrama CHAR(500))
    RETURNING CHAR(5) AS CodRet;
	
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE iNoRegistros        	 INTEGER;
	DEFINE cFolio 				 INTEGER;
	DEFINE cNumRecibo			 CHAR(10);
	DEFINE dFechaEmision      	 DATE;
	DEFINE iNumPiezas            INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE iDictamen             INTEGER;	
		
	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET cEmpresa 				= '001';
	LET iNoRegistros			= 0;
	LET cFolio					= 0;
	LET cNumRecibo			    = '';
	LET dFechaEmision      	  	= DATE(1);
	LET iNumPiezas            	= 0;
	LET iCvePieza             	= 0;
	LET iDictamen             	= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_altamodificacion_piezas_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pOpcion=''  OR (pOpcion=4 AND pTrama='') THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 4 THEN 
		
			FOREACH 
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTrama, ',')
				INTO cFolio
				
				SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  cve_pieza,num_piezas,num_recibo,fecha_emision, NVL(cd.id_dictamen,'0' ) 
				INTO iCvePieza,iNumPiezas,cNumRecibo,dFechaEmision,iDictamen 
				FROM "informix".sw_cg_billetesfalsos s LEFT JOIN bdisuc:"informix".ss_cat_dictamen_bym_falsos cd ON cd.desc_dictamen=s.dictamen_banxico
				WHERE us_insert = TRIM(pUsuario)
				AND id_serial=cFolio::INTEGER;
				
				UPDATE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} "informix".sw_cg_billetesfalsos SET
				indicador=1
				WHERE us_insert = TRIM(pUsuario)
				AND id_serial=cFolio::INTEGER;
				
				EXECUTE PROCEDURE bdisuc:"informix".sp_altamodificacion_piezas_bym('4', '0',cNumRecibo,'','','',  dFechaEmision, iNumPiezas, '','','', iDictamen,'', '2', pUsuario, iCvePieza)
				INTO cCodRetSp, cMensaje;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_altamodificacion_piezas_bym';
				ELIF cCodRetSp::INTEGER = 1   THEN
					LET cCodRet = '00003';
				ELIF cCodRetSp::INTEGER = 262 THEN		--262	El archivo se cargÃ³ satisfactoriamente.           
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 263 THEN		--263	El archivo se generÃ³ satisfactoriamente.          
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 264 THEN		--264	El archivo ya fue procesado con anterioridad.     
					LET cCodRet = '00492';
				ELIF cCodRetSp::INTEGER = 265 THEN		--265	La informaciÃ³n ha sido guardada                   
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 266 THEN		--266 satisfactoriamente.                               
					LET cCodRet = '00000';
				ELIF cCodRetSp::INTEGER = 2 THEN		--2                               
					LET cCodRet = '00017';
				END IF;
				
			END FOREACH;
			
		ELSE
			
			EXECUTE PROCEDURE bdisuc:"informix".sp_altamodificacion_piezas_bym(pOpcion, pIdDenominacion,pNumRecibo, pTipoPieza, pSerie, pFolio,
			pFechaEmision, pNumPiezas, pNota, pNumGuia,pFolioBanxico, pDictamenBanxico,pNumLoteBanxico, pEstatus, pUsuario, pIdPieza)
			INTO cCodRetSp, cMensaje;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_altamodificacion_piezas_bym';
			ELIF cCodRetSp::INTEGER = 1   THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 262 THEN		--262	El archivo se cargÃ³ satisfactoriamente.           
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 263 THEN		--263	El archivo se generÃ³ satisfactoriamente.          
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 264 THEN		--264	El archivo ya fue procesado con anterioridad.     
				LET cCodRet = '00492';
			ELIF cCodRetSp::INTEGER = 265 THEN		--265	La informaciÃ³n ha sido guardada                   
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 266 THEN		--266 satisfactoriamente.                               
				LET cCodRet = '00000';
			ELIF cCodRetSp::INTEGER = 2 THEN		--2                               
				LET cCodRet = '00017';
				
			END IF;
			
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
		END IF;
		
		RETURN cCodRet; 
    
	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que actualiza el registro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consulta_catdenominacion_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato CHAR(1))
    RETURNING CHAR(5) AS codret,
		INTEGER  AS IdDenominacion,
		CHAR(1)  AS CvePieza,
		CHAR(7)  AS TipoPieza,
		CHAR(10) AS Denominacion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    
	DEFINE iIdDenominacion INTEGER;
	DEFINE cCvePieza       CHAR(1);
	DEFINE cTipoPieza      CHAR(7);
	DEFINE cDenominacion   CHAR(10);
	DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET iIdDenominacion=0;
	LET cCvePieza     =''; 
	LET cTipoPieza    =''; 
	LET cDenominacion =''; 
	LET iRecuperacion = 0;
   	
	BEGIN
     
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END EXCEPTION;
      
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consulta_catdenominacion_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_catdenominacion_bym(pOpcion, pDato)  
            INTO cCodRetSp, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consulta_catdenominacion_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion WITH RESUME;
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdDenominacion, cCvePieza,cTipoPieza,cDenominacion;
		END IF;
		
    END; 
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 22/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Denominaciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacat_estatus_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato INTEGER)
	RETURNING CHAR(5) AS codret,
        INTEGER AS cve_Dictamen,
		CHAR(20) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    DEFINE cMensaje CHAR(80);
    DEFINE iCveEstatus INTEGER;
    DEFINE cDescripcion CHAR(20);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET cMensaje = '';
    LET iCveEstatus = 0;
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacat_estatus_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consultacat_estatus_bym(pOpcion, pDato)  
            INTO cCodRetSp, cMensaje, iCveEstatus, cDescripcion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                    RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultacat_estatus_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
                    LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
                    LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iCveEstatus,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCveEstatus, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Estatus(ss_cat_estatus_bym_falsos)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadatospiezas_bym_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pTipoConsulta INTEGER)
       RETURNING  	CHAR(5) 	AS CodRet,
	   INTEGER     AS total;
	
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE dFechaCaptura         DATE;
	DEFINE cNumRecibo            CHAR(10);
	DEFINE iNumPiezas            INTEGER;
	DEFINE cTipoPieza            CHAR(1);
	DEFINE cDenominacion         CHAR(10);
	DEFINE iCveDenominacion      INTEGER;
	DEFINE cSerie                CHAR(40);
	DEFINE cFolio                CHAR(40);
	DEFINE dFechaEmision         DATE;
	DEFINE cNota                 CHAR(200);
	DEFINE cEstatus              CHAR(20);
	DEFINE cDictamenBanxico      CHAR(20);
	DEFINE cNumLoteBanxico       CHAR(40);
	DEFINE cFolioBanxico         CHAR(40);
	DEFINE dFechaPago            DATE;
	DEFINE cFormaPago            CHAR(20);
	DEFINE cNumCta               CHAR(11);
	DEFINE cNumSuc               CHAR(4);
	DEFINE cNombreSuc            CHAR(40);
	DEFINE cDomSuc               CHAR(80);
	DEFINE cNomOperador          CHAR(45);
	DEFINE cApellidoTenedor1     CHAR(40);
	DEFINE cApellidoTenedor2     CHAR(40);
	DEFINE cNomTenedor1          CHAR(40);
	DEFINE cNomTenedor2          CHAR(40);
	DEFINE cIdentificacion       CHAR(50);
	DEFINE cNumIdentificacion    CHAR(40);
	DEFINE cCalle                CHAR(30);
	DEFINE cNumCasa              CHAR(10);
	DEFINE cColonia              CHAR(32);
	DEFINE cDelegacion           CHAR(60);
	DEFINE cCodPostal            CHAR(5);
	DEFINE cCiudad               CHAR(60);
	DEFINE cEstado               CHAR(2);
	DEFINE cTelefono             CHAR(13);
	DEFINE cEmail                CHAR(30); 
	DEFINE dFechaInicio          DATE;
	DEFINE dFechaFin             DATE;
	DEFINE cNumReciboCon         CHAR(10);
	DEFINE iIdTenedor            INTEGER;
	DEFINE cNumSucursalReten     CHAR(4);
	DEFINE cNombre1              CHAR(40);
	DEFINE cNombre2              CHAR(40);
	DEFINE cApPaterno            CHAR(40);
	DEFINE cApMaterno            CHAR(40);
	DEFINE cCalleCon             CHAR(40);
	DEFINE cNumeroCalle          CHAR(10);
	DEFINE cColoniaCon           CHAR(6);
	DEFINE cDelegacionPoblacion  CHAR(3);
	DEFINE cCodPostalCon         CHAR(5);
	DEFINE cCiudadCon            CHAR(3);
	DEFINE cEstadoCon            CHAR(2);
	DEFINE cTelefonoCon          CHAR(13);
	DEFINE cEmailCon             CHAR(30);
	DEFINE cEjecutivoInsert      CHAR(8);
	DEFINE cIdentificacionCon    CHAR(20);
	DEFINE cIdentificacionDes    CHAR(50);
	DEFINE cNumIdentificacionCon CHAR(40);
	DEFINE cIdPieza              INTEGER;
	DEFINE dFechaRecepcion       DATE;
	DEFINE iIdDenominacion       INTEGER;
	DEFINE cSerieCon             CHAR(40);
	DEFINE cFolioCon             CHAR(40);
	DEFINE dFechaEmisionCon      DATE;
	DEFINE iNumPiezasCon         INTEGER;
	DEFINE cNotaCon              CHAR(200);
	DEFINE cFolioBanxicoCon      CHAR(40);
	DEFINE iDictamenBanxico      INTEGER;
	DEFINE cNumLoteBanxicoCon    CHAR(40);
	DEFINE dFechaPagoCon         DATE;
	DEFINE iTipoPago             INTEGER;
	DEFINE cNumCtaCliente        CHAR(11);
	DEFINE iEstatus              INTEGER;
	DEFINE dFechaInsert          DATE;
	DEFINE cNombreScucursal      CHAR(40);
	DEFINE cDireccion1           CHAR(40);
	DEFINE cNombreOperador       CHAR(45);
	DEFINE cDesCvePieza          CHAR(1); 
	DEFINE cDenominacionCon      CHAR(10);
	DEFINE cDesDictamen          CHAR(20);  
	DEFINE cDesTipoPago          CHAR(20);
	DEFINE cDesEstatus           CHAR(20);
	DEFINE cCodigo               CHAR(3);
	DEFINE cPromotor             CHAR(8);
	DEFINE cCiudadoDelegacion    CHAR(3);
	DEFINE cCiudadoCoppel        INTEGER;
	DEFINE cNombreCidDel         CHAR(60);
	DEFINE cNombreCol		     CHAR(32);
	DEFINE cNombreCalle          CHAR(30);	
	DEFINE cNombreCiudad         CHAR(60);
	DEFINE cNombreDelegacion     CHAR(60);
	DEFINE cEstadoDes            CHAR(30);
	DEFINE cEstadoDesRes         CHAR(30);
	DEFINE cEstadoBanxico        CHAR(3);
	DEFINE iRegistros2 			 INTEGER;
	DEFINE iTermino 			 INTEGER;
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE dFechaHoy 			 DATE;
	DEFINE iNoRegistros			 INTEGER;

	LET cEmpresa 				='001';
	LET iNoRegistros			= 0;
	LET dFechaHoy               = DATE(CURRENT);

	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET iCvePieza               = 0;
	LET dFechaCaptura           = DATE(1);
	LET cNumRecibo              = '';
	LET iNumPiezas              = 0;
	LET cTipoPieza              = '';
	LET cDenominacion           = '';
	LET iCveDenominacion        = 0;  
	LET cSerie                  = '';
	LET cFolio                  = '';
	LET dFechaEmision           = DATE(1);
	LET cNota                   = '';
	LET cEstatus                = '';  
	LET cDictamenBanxico        = '';  
	LET cNumLoteBanxico         = '';
	LET cFolioBanxico           = '';
	LET dFechaPago              = DATE(1);
	LET cFormaPago              = ''; 
	LET cNumCta                 = '';
	LET cNumSuc                 = '';
	LET cNombreSuc              = '';
	LET cDomSuc                 = ''; 
	LET cNomOperador            = '';
	LET cApellidoTenedor1       = ''; 
	LET cApellidoTenedor2       = '';                                                                                                                               
	LET cNomTenedor1            = '';
	LET cNomTenedor2            = '';
	LET cIdentificacion         = '';
	LET cNumIdentificacion      = ''; 
	LET cCalle                  = '';
	LET cNumCasa                = '';                                             
	LET cColonia                = '';
	LET cDelegacion             = '';
	LET cCodPostal              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cTelefono               = '';
	LET cEmail                  = '';
	LET cPromotor               = '';
	LET cEstadoDesRes           = '';       
	LET iRegistros2 			= 0;
	LET iTermino 				= 0;
	LET iNoRegistros			= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadatospiezas_bym_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoConsulta = 0 THEN	--LLENA TABLA DE GRID PRINCIPAL
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			DELETE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  FROM "informix".sw_cg_billetesfalsos WHERE us_insert = TRIM(pUsuario);
			
			DELETE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  FROM bdicnweb:"informix".sw_cg_validaestatusbf WHERE usuario_inserta = pUsuario;
	
			INSERT INTO bdicnweb:"informix".sw_cg_validaestatusbf(id_status, desc_status, usuario_inserta, fecha)
			VALUES ('I', 'INICIA_PROCESO', pUsuario, CURRENT);
	
			FOREACH 
				EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym2(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa)
				INTO cCodRetSp, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes,iRegistros2, iTermino

				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym2';
				ELIF cCodRetSp::INTEGER = 1 THEN
					UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
					SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
					WHERE usuario_inserta = pUsuario;
		
					LET cCodRet = '00003';
					RETURN cCodRet,iNoRegistros;
				ELIF cCodRetSp::INTEGER = 2 THEN
					UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
					SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
					WHERE usuario_inserta = pUsuario;
								
					LET cCodRet = '00017';
					RETURN cCodRet,iNoRegistros;
				ELIF cCodRetSp::INTEGER = 0 THEN
					LET iRecuperacion = iRecuperacion + 1;
					INSERT INTO "informix".sw_cg_billetesfalsos(id_serial, cve_pieza, fecha_captura,num_recibo, num_piezas, tipo_pieza, denominacion,cve_denominacion,serie, folio, fecha_emision,nota,
					estatus,dictamen_banxico,num_lote_banxico, folio_banxico, fecha_pago, forma_pago, num_cta, num_suc, nombre_suc,dom_suc, nom_operador,apellido_tenedor1,apellido_tenedor2,
					nom_tenedor1,  nom_tenedor2, identificacion,num_identificacion,calle, numcasa,colonia, delegacion,codpostal, ciudad, estado, telefono,email,operador,estado_desc,us_insert,fecha_insert) VALUES 
					(iRecuperacion,iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, pUsuario,dFechaHoy);
				END IF;
			END FOREACH;
			
			SELECT COUNT(*) INTO iNoRegistros
			FROM "informix".sw_cg_billetesfalsos
			WHERE us_insert = TRIM(pUsuario);
			
			UPDATE {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  bdicnweb:"informix".sw_cg_validaestatusbf
			SET id_status = 'F', desc_status = 'FINALIZA_PROCESO'
			WHERE usuario_inserta = pUsuario;				
		
		ELIF pTipoConsulta = 1 THEN	 --GRID PRINCIPAL
			
			SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)}  COUNT(*) INTO iNoRegistros
			FROM "informix".sw_cg_billetesfalsos
			WHERE us_insert = TRIM(pUsuario);

		ELIF pTipoConsulta = 2 THEN	 --GRID REPORTE

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym3_totales(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa)
			INTO cCodRetSp, iNoRegistros;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym3_totales';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN		
				LET cCodRet = '00017';
			END IF;
		
	    END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;

		RETURN cCodRet,iNoRegistros; 
    
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que obtiene el total de los registros para el llenado de grid',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultastatusprocesobf(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS id_status,
		CHAR(30) AS desc_status;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(1);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = '';
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultastatusprocesobf.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		SELECT {+INDEX (bdicnweb:sw_cg_validaestatusbf idx_sw_cg_validaestatusbf)}  id_status, desc_status
		INTO cIdStatus, cDescStatus
		FROM "informix".sw_cg_validaestatusbf
		WHERE usuario_inserta = pUsuario;
			
		IF cIdStatus  = '' THEN
			RETURN cCodRet, 'I', 'INICIA_PROCESO';
		ELSE 
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/01/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: Caja Gral Billetes Falsos',
'DESCRIPCION: SPL que realiza la consulta de los estatus para monitorear el proceso del spl de sp_cg_consultadatospiezas_bym_totales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consutacat_dictamen_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pDato INTEGER)
        RETURNING CHAR(5) AS codret,
        INTEGER AS cve_Dictamen,
		CHAR(20) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    DEFINE cMensaje CHAR(80);
    DEFINE iCveDictamen INTEGER;
    DEFINE cDescripcion CHAR(20);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    LET cMensaje = '';
    LET iCveDictamen = 0;
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCveDictamen, cDescripcion;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consutacat_dictamen_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCveDictamen, cDescripcion;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, iCveDictamen, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
            EXECUTE PROCEDURE bdisuc:"informix".sp_consutacat_dictamen_bym(pOpcion, pDato)  
            INTO cCodRetSp, cMensaje, iCveDictamen, cDescripcion
			
            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consutacat_dictamen_bym';
            ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
            ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
            END IF;
            
			LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, iCveDictamen,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iCveDictamen, cDescripcion;
		END IF;
		
    END;  
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de Dictamenes(ss_cat_dictamen_bym_falsos)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_genera_archivo_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pOpcion CHAR(1), pRuta CHAR(100))
    RETURNING CHAR(5) AS codret,
        CHAR(100) AS ruta,
		CHAR(30)  AS nombreArchivo;
		
	DEFINE cCodRet   CHAR(5);
    DEFINE iSqlErr   INTEGER;
    DEFINE iCodRetSp INTEGER;
    DEFINE iRecuperacion INTEGER;
	DEFINE cNombreArchivo CHAR(30);
	DEFINE cCmd1 CHAR(2500);
    DEFINE cSql    CHAR(2500);
	DEFINE pRutaGra CHAR(100);
	DEFINE cDelFile CHAR(200);
	DEFINE cFolio INTEGER;
	
	DEFINE bInTransaction BOOLEAN; --
	DEFINE ven_transacc SMALLINT; --
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iCodRetSp = 0;
    LET iRecuperacion = 0;
	LET cNombreArchivo   ='';
   	LET cCmd1='';
	LET cSql='';
	LET pRutaGra='';
	LET cDelFile='';
	LET cFolio=0;
	
	LET bInTransaction = 'f'; --
	LET ven_transacc = 0; --
	
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			IF ven_transacc = 1 THEN
				ROLLBACK WORK; --		
			END IF;
			
			RETURN cCodRet, pRuta, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_genera_archivo_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOpcion = '' OR (pOpcion =1 AND pRuta='') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, pRuta, cNombreArchivo;
		END IF;
 
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, pRuta, cNombreArchivo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pOpcion = 0 THEN --limpiar selecccion
		
			UPDATE {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} "informix".sw_cg_billetesfalsos SET
			indicador=0
			WHERE us_insert = TRIM(pUsuario);
			
			RETURN  cCodRet, pRuta, cNombreArchivo;
			
		ELIF pOpcion = 1 THEN --genera archivo
		
			BEGIN WORK;
				LET ven_transacc = 1;
			
				LET cNombreArchivo   ='ArchivoBanxicoBilletes.txt';
				LET pRutaGra = TRIM(pRuta)||TRIM(cNombreArchivo);
				
				LET cCmd1 ="  "|| "SELECT '40137'||LPAD(day(fecha_captura),2,'0')||LPAD( month(fecha_captura),2,'0' )||year(fecha_captura)||RPAD(num_suc,8)|| 'F'||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD((RTRIM(NVL(nom_tenedor1,'')) ||' '|| RTRIM(NVL(nom_tenedor2,'')) ),'70',' ')||RPAD(NVL(apellido_tenedor1,''),30)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(apellido_tenedor2,''),30)||RPAD( (RTRIM(NVL(calle,''))||' '||RTRIM(NVL(numcasa,''))), 40)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(colonia,''),30)||RPAD(NVL(delegacion,''),30)||LPAD(NVL(estado,''),2)||RPAD(NVL(ciudad,''),30)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(codpostal,''),5)||RPAD((RTRIM(NVL(nom_operador,''))||' '||RTRIM(NVL(operador,''))),80)||RPAD(NVL(tipo_pieza,''),1)|| ''||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL('1',''),1)||LPAD(denominacion::DECIMAL(6,2),8,'0')||LPAD(NVL(num_piezas,'')::CHAR,5,'0')||";
				LET cCmd1 =""||TRIM(cCmd1)||"LPAD(day(fecha_emision),2,'0')||LPAD( month(fecha_emision),2,'0' )||year(fecha_emision)||RPAD(NVL(serie,''),14)||";
				LET cCmd1 =""||TRIM(cCmd1)||"RPAD(NVL(folio,''),20)||RPAD(NVL(nota,''),278)||'*'||LPAD(NVL(num_recibo,''),11,0)";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:sw_cg_billetesfalsos WHERE indicador='1' AND us_insert="||pUsuario;
				
				LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pRutaGra)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cSql);
			
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cDelFile);
				
				LET cSql = '';
				LET cSql = '/informix/bin/dbaccess sysmaster '||TRIM(pRuta)||'query07.sql';
				--COMMIT WORK;
				SYSTEM TRIM(cSql);  
				--BEGIN WORK;
			
				LET cSql = '';
				LET cSql = 'rm -rf '||TRIM(pRuta)||'query07.sql';
				SYSTEM TRIM(cSql);
				
				LET cSql= "sed 's/|$//g;/^$/d' " ||  TRIM(pRuta) ||  cNombreArchivo || " > " || TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				SYSTEM TRIM(cSql);
				
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				SYSTEM TRIM(cDelFile);
				
				SYSTEM "sed "||"'s/$'""/`/usr/bin/echo \\\r`/"" "|| TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt'||" > "||TRIM(pRuta) || TRIM(cNombreArchivo)||'3.txt';
				
				LET cDelFile = '/usr/bin/chmod 777 '||TRIM(pRuta) || TRIM(cNombreArchivo)||'3.txt';
				SYSTEM TRIM(cDelFile);
				
				-- Eliminamos el archivo original
				SYSTEM "rm -rf "||TRIM(pRutaGra);
				SYSTEM "rm -rf "||TRIM(pRuta) || TRIM(cNombreArchivo)||'2.txt';
				
				-- Se renombra el archivo temporal por el nombre original
				SYSTEM "mv "|| TRIM(pRuta)||TRIM(cNombreArchivo)||"3.txt "||TRIM(pRutaGra);
			
			COMMIT WORK;
			
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN  cCodRet, pRuta, cNombreArchivo;
			
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 23/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: SPL Intermedio que actualiza el campo indicador para generar el archivo',
'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2017',
'DESCRIPCION: Se modifica SPL para dar tratado a transacciones y asignación de permisos a los archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ca_cargaarchivoxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pArchivoProcesar CHAR(100))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd CHAR(2000);
	DEFINE cArchivoTmp CHAR(250);
	DEFINE cScriptCarga CHAR(250);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cNombreArchivoTmp CHAR(50);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd = '';
	LET cArchivoTmp = TRIM(pArchivoProcesar)||'.tmp';
	LET cScriptCarga = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	--LET cRutaInformix = '/informix/bin/';
	LET cNombreArchivoTmp = 'scriptofixml'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.sql';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ca_cargaarchivoxml.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR pArchivoProcesar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		-- Se convierte el archivo de FORMATO UTF-8 a IBM-1252
		LET cCmd = "iconv -s -f UTF-8 -t IBM-1252 "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" > "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/mv "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan tags innecesarios
		LET cCmd = "sed '/<?xml/d' "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" | awk '{if($1 ~ /<Expediente/) $1 = ""<Expediente>""; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xmlns/) $2 = """"; print $0}' | awk '{if($2 ~ /xsi/) $2 = """"; print $0}' > "||TRIM(pRutaCarga)||TRIM(cArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		-- Eliminamos el archivo pivote
		LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(cArchivoTmp)||' '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de retorno de carro (DOS)
		LET cCmd = '/usr/bin/tr "\r" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de tabuladores
		LET cCmd = '/usr/bin/tr "\t" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cScriptCarga = "echo 'LOAD FROM "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" INSERT INTO bdicnweb:""informix"".sw_ca_archivoxml_tmp(xmlfile_data);' > "||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cScriptCarga);
				
		DELETE FROM bdicnweb:"informix".sw_ca_archivoxml_tmp;	
		
		LET cCmd = TRIM(cRutaInformix)||'dbaccess bdicnweb < '||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		UPDATE STATISTICS MEDIUM FOR TABLE bdicnweb:"informix".sw_ca_archivoxml_tmp;
		
		LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreArchivoTmp);
		SYSTEM TRIM(cCmd);
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		--LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		--SYSTEM TRIM(cCmd);
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA AUTOMÁTICA DE ARCHIVOS XML', 
'DESCRIPCION: SPL encargado de hacer la limpieza del archivo xml, para que posteriormente sea cargado en la tabla bdicnweb:sw_ca_archivoxml_tmp.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 28/06/2018',
'DESCRIPCION: Se coloca tratado para el código de error -668.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadatospiezas_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pTipoConsulta INTEGER, pRegistros INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5) AS CodRet,
		INTEGER 	AS CvePieza,
		DATE 		AS FechaCaptura,
		CHAR(10) 	AS NumRecibo,
		INTEGER 	AS NumPiezas,
		CHAR(1) 	AS TipoPieza,
		CHAR(10) 	AS Denominacion,
		INTEGER 	AS CveDenominacion,
		CHAR(40) 	AS Serie,
		CHAR(40) 	AS Folio,
		DATE 		AS FechaEmision,
		CHAR(200) 	AS Nota,
		CHAR(20) 	AS Estatus,
		CHAR(20) 	AS DictamenBanxico,
		CHAR(40) 	AS NumLoteBanxico,
		CHAR(40) 	AS FolioBanxico,
		DATE 		AS FechaPago,
		CHAR(20) 	AS FormaPago,
		CHAR(11) 	AS NumCta,
		CHAR(4) 	AS NumSuc,
		CHAR(40) 	AS NombreSuc,
		CHAR(80) 	AS DomSuc,
		CHAR(45) 	AS NomOperador,
		CHAR(40) 	AS ApellidoTenedor1,
		CHAR(40) 	AS ApellidoTenedor2,
		CHAR(40) 	AS NomTenedor1,
		CHAR(40) 	AS NomTenedor2,
		CHAR(50) 	AS Identificacion,
		CHAR(40) 	AS NumIdentificacion,
		CHAR(30) 	AS Calle,
		CHAR(10) 	AS NumCasa,
		CHAR(32) 	AS Colonia,
		CHAR(60) 	AS Delegacion,
		CHAR(5) 	AS CodPostal,
		CHAR(60) 	AS Ciudad,
		CHAR(2) 	AS Estado,
		CHAR(13) 	AS Telefono,
		CHAR(30) 	AS Email,
		CHAR(8)     AS Operador,
		CHAR(30)    AS EstadoDesc;
			
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE dFechaCaptura         DATE;
	DEFINE cNumRecibo            CHAR(10);
	DEFINE iNumPiezas            INTEGER;
	DEFINE cTipoPieza            CHAR(1);
	DEFINE cDenominacion         CHAR(10);
	DEFINE iCveDenominacion      INTEGER;
	DEFINE cSerie                CHAR(40);
	DEFINE cFolio                CHAR(40);
	DEFINE dFechaEmision         DATE;
	DEFINE cNota                 CHAR(200);
	DEFINE cEstatus              CHAR(20);
	DEFINE cDictamenBanxico      CHAR(20);
	DEFINE cNumLoteBanxico       CHAR(40);
	DEFINE cFolioBanxico         CHAR(40);
	DEFINE dFechaPago            DATE;
	DEFINE cFormaPago            CHAR(20);
	DEFINE cNumCta               CHAR(11);
	DEFINE cNumSuc               CHAR(4);
	DEFINE cNombreSuc            CHAR(40);
	DEFINE cDomSuc               CHAR(80);
	DEFINE cNomOperador          CHAR(45);
	DEFINE cApellidoTenedor1     CHAR(40);
	DEFINE cApellidoTenedor2     CHAR(40);
	DEFINE cNomTenedor1          CHAR(40);
	DEFINE cNomTenedor2          CHAR(40);
	DEFINE cIdentificacion       CHAR(50);
	DEFINE cNumIdentificacion    CHAR(40);
	DEFINE cCalle                CHAR(30);
	DEFINE cNumCasa              CHAR(10);
	DEFINE cColonia              CHAR(32);
	DEFINE cDelegacion           CHAR(60);
	DEFINE cCodPostal            CHAR(5);
	DEFINE cCiudad               CHAR(60);
	DEFINE cEstado               CHAR(2);
	DEFINE cTelefono             CHAR(13);
	DEFINE cEmail                CHAR(30); 

	DEFINE dFechaInicio          DATE;
	DEFINE dFechaFin             DATE;
	DEFINE iBandFecha            INTEGER;
	DEFINE iBandInicio           INTEGER;
	DEFINE iBandRegistros        INTEGER;
	DEFINE iRegistros            INTEGER;
	DEFINE iRegCon               INTEGER;
	DEFINE iContador             INTEGER;
	DEFINE iTermino              INTEGER;
	DEFINE cNumReciboCon         CHAR(10);
	DEFINE iIdTenedor            INTEGER;
	DEFINE cNumSucursalReten     CHAR(4);
	DEFINE cNombre1              CHAR(40);
	DEFINE cNombre2              CHAR(40);
	DEFINE cApPaterno            CHAR(40);
	DEFINE cApMaterno            CHAR(40);
	DEFINE cCalleCon             CHAR(40);
	DEFINE cNumeroCalle          CHAR(10);
	DEFINE cColoniaCon           CHAR(6);
	DEFINE cDelegacionPoblacion  CHAR(3);
	DEFINE cCodPostalCon         CHAR(5);
	DEFINE cCiudadCon            CHAR(3);
	DEFINE cEstadoCon            CHAR(2);
	DEFINE cTelefonoCon          CHAR(13);
	DEFINE cEmailCon             CHAR(30);
	DEFINE cEjecutivoInsert      CHAR(8);
	DEFINE cIdentificacionCon    CHAR(20);
	DEFINE cIdentificacionDes    CHAR(50);
	DEFINE cNumIdentificacionCon CHAR(40);
	DEFINE cIdPieza              INTEGER;
	DEFINE dFechaRecepcion       DATE;
	DEFINE iIdDenominacion       INTEGER;
	DEFINE cSerieCon             CHAR(40);
	DEFINE cFolioCon             CHAR(40);
	DEFINE dFechaEmisionCon      DATE;
	DEFINE iNumPiezasCon         INTEGER;
	DEFINE cNotaCon              CHAR(200);
	DEFINE cFolioBanxicoCon      CHAR(40);
	DEFINE iDictamenBanxico      INTEGER;
	DEFINE cNumLoteBanxicoCon    CHAR(40);
	DEFINE dFechaPagoCon         DATE;
	DEFINE iTipoPago             INTEGER;
	DEFINE cNumCtaCliente        CHAR(11);
	DEFINE iEstatus              INTEGER;
	DEFINE dFechaInsert          DATE;
	DEFINE cNombreScucursal      CHAR(40);
	DEFINE cDireccion1           CHAR(40);
	DEFINE cNombreOperador       CHAR(45);
	DEFINE cDesCvePieza          CHAR(1); 
	DEFINE cDenominacionCon      CHAR(10);
	DEFINE cDesDictamen          CHAR(20);  
	DEFINE cDesTipoPago          CHAR(20);
	DEFINE cDesEstatus           CHAR(20);
	DEFINE cCodigo               CHAR(3);
	DEFINE cPromotor             CHAR(8);
	DEFINE cCiudadoDelegacion    CHAR(3);
	DEFINE cCiudadoCoppel        INTEGER;
	DEFINE cNombreCidDel         CHAR(60);
	DEFINE cNombreCol		     CHAR(32);
	DEFINE cNombreCalle          CHAR(30);	
	DEFINE cNombreCiudad         CHAR(60);
	DEFINE cNombreDelegacion     CHAR(60);
	DEFINE cEstadoDes            CHAR(30);
	DEFINE cEstadoDesRes         CHAR(30);
	DEFINE cEstadoBanxico        CHAR(3);
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE dFechaHoy 			 DATE;

	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET iCvePieza               = 0;
	LET dFechaCaptura           = DATE(1);
	LET cNumRecibo              = '';
	LET iNumPiezas              = 0;
	LET cTipoPieza              = '';
	LET cDenominacion           = '';
	LET iCveDenominacion        = 0;  
	LET cSerie                  = '';
	LET cFolio                  = '';
	LET dFechaEmision           = DATE(1);
	LET cNota                   = '';
	LET cEstatus                = '';  
	LET cDictamenBanxico        = '';  
	LET cNumLoteBanxico         = '';
	LET cFolioBanxico           = '';
	LET dFechaPago              = DATE(1);
	LET cFormaPago              = ''; 
	LET cNumCta                 = '';
	LET cNumSuc                 = '';
	LET cNombreSuc              = '';
	LET cDomSuc                 = ''; 
	LET cNomOperador            = '';
	LET cApellidoTenedor1       = ''; 
	LET cApellidoTenedor2       = '';                                                                                                                               
	LET cNomTenedor1            = '';
	LET cNomTenedor2            = '';
	LET cIdentificacion         = '';
	LET cNumIdentificacion      = ''; 
	LET cCalle                  = '';
	LET cNumCasa                = '';                                             
	LET cColonia                = '';
	LET cDelegacion             = '';
	LET cCodPostal              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cTelefono               = '';
	LET cEmail                  = '';

	LET dFechaInicio            = DATE(1);
	LET dFechaFin               = DATE(1);
	LET iBandFecha              = 0;
	LET iBandInicio             = 0;
	LET iBandRegistros          = 0;
	LET iRegistros              = 0;
	LET iRegCon                 = 0;
	LET iContador               = 0;
	LET iTermino                = 0;
	LET cNumReciboCon			= '';
	LET iIdTenedor				= 0;
	LET cNumSucursalReten		= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cCalleCon				= '';
	LET cNumeroCalle			= '';
	LET cColoniaCon				= '';
	LET cDelegacionPoblacion	= '';
	LET cCodPostalCon			= '';
	LET cCiudadCon				= '';
	LET cEstadoCon				= '';
	LET cTelefonoCon			= '';
	LET cEmailCon				= '';
	LET cEjecutivoInsert		= '';
	LET cIdentificacionCon		= '';
	LET cIdentificacionDes 	    = '';
	LET cNumIdentificacionCon	= '';
	LET cIdPieza				= 0;
	LET dFechaRecepcion			= DATE(1);
	LET iIdDenominacion			= 0;
	LET cSerieCon				= '';
	LET cFolioCon				= '';
	LET dFechaEmisionCon		= DATE(1);
	LET iNumPiezasCon			= 0;
	LET cNotaCon				= '';
	LET cFolioBanxicoCon		= '';
	LET iDictamenBanxico		= 0;
	LET cNumLoteBanxicoCon		= '';
	LET dFechaPagoCon           = DATE(1);
	LET iTipoPago				= 0;
	LET cNumCtaCliente			= '';
	LET iEstatus				= 0;
	LET dFechaInsert            = DATE(1);
	LET cNombreScucursal        = '';
	LET cDireccion1             = '';
	LET cNombreOperador         = '';
	LET cDesCvePieza            = '';
	LET cDenominacionCon        = ''; 
	LET cDesDictamen            = ''; 
	LET cDesTipoPago            = ''; 
	LET cDesEstatus             = ''; 
	LET cCodigo                 = ''; 
	LET cPromotor               = '';
	LET cCiudadoDelegacion      = '';
	LET cCiudadoCoppel          = 0;
	LET cNombreCidDel           = '';
	LET cNombreCol		        = '';
	LET cNombreCalle            = '';
	LET cNombreCiudad           = '';	
	LET cNombreDelegacion       = '';
	LET cEstadoDes              = '';
	LET cEstadoDesRes           = '';
	LET cEstadoBanxico          =  '';
	LET cEmpresa 				= '001';
	LET dFechaHoy 				= DATE(CURRENT);

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadatospiezas_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		   RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;

		IF pTipoConsulta = 1 THEN --GRID PRINCIPAL
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			FOREACH 
				
				SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} SKIP pRegistros FIRST pRecuperacion 
				cve_pieza,fecha_captura,num_recibo,num_piezas,tipo_pieza,denominacion,cve_denominacion,serie,folio,fecha_emision,nota,estatus,dictamen_banxico,num_lote_banxico,folio_banxico,fecha_pago,
				forma_pago,num_cta,num_suc,nombre_suc,dom_suc,nom_operador,apellido_tenedor1, apellido_tenedor2, nom_tenedor1,nom_tenedor2,
				identificacion,num_identificacion,calle, numcasa,colonia,delegacion,codpostal, ciudad,estado,telefono,email,operador,estado_desc  
				INTO iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, 
				cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,
				cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes
				FROM bdicnweb:"informix".sw_cg_billetesfalsos
				WHERE us_insert=pUsuario
				ORDER BY id_serial ASC

				LET iRecuperacion = iRecuperacion + 1;	
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
		
			END FOREACH;
		
		ELSE --GRID REPORTE
		
			FOREACH 
			
				EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym3(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa,pRegistros,pRecuperacion )
				INTO cCodRetSp, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes,iRegistros, iTermino
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym3';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros = 0  THEN		
					LET cCodRet = '00017';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros > 0 THEN		
					LET cCodRet = '1001';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
	
			END FOREACH;
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que obtiene informacion para llenado de grid',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 07/04/2016',
'MODIFICACION: Se agrega validación para la recuperación de registros a retornar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_sac_reportediario( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,DATE AS FechaProceso, INTEGER AS num_mesesvent, MONEY(16,2) AS importe_vent, 
	INTEGER AS num_mesesdomi,MONEY(16,2) AS Importe_domi, INTEGER AS num_meses,MONEY(16,2) AS importe_total,MONEY(16,2) AS comision,
	MONEY(16,2) AS iva,MONEY(16,2) AS importe_pago_coppel;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE dFechaProceso DATE;
	DEFINE iNum_mesesvent INTEGER;
	DEFINE mImporte_vent MONEY(16,2);
	DEFINE iNum_mesesdomi INTEGER;
	DEFINE mImporte_domi MONEY(16,2);
	DEFINE iNum_meses INTEGER;
	DEFINE mImporte_total MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIva MONEY(16,2);
	DEFINE mImporte_pago_coppel MONEY(16,2);
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;
	LET dFechaProceso=DATE(1);
	LET iNum_mesesvent =0;
	LET mImporte_vent =0;
	LEt iNum_mesesdomi=0;
	LET mImporte_domi=0;
	LET iNum_meses=0;
	LET mImporte_total=0;
	LET mComision=0;
	LET mIva=0;
	LET mImporte_pago_coppel=0;
	LET iRecuperacion=0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,iNum_meses,mImporte_domi,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportediario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

       FOREACH

		SELECT SKIP pRegistros FIRST pRecuperacion fecha_proceso,num_mesesvent,importe_vent ,num_mesesdomi,importe_domi,num_meses,importe_total,comision,iva,importe_pago_coppel
		INTO dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel
		FROM bdisac:sac_reportediario_seg  
     	WHERE fecha_proceso BETWEEN pFecha_inicial AND pFecha_final and reportesoc ='1'
      ORDER BY fecha_proceso ASC

       LET iRecuperacion = iRecuperacion + 1;
        
      RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel WITH RESUME;
       END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;	
		

	END;		

END PROCEDURE;