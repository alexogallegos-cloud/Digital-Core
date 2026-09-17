CREATE PROCEDURE "informix".sp_cb_verificapermisodescarga(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(5) AS permitido;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE bPermiso BOOLEAN;
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bPermiso ='f';
	LET iTotal = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,bPermiso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cb_verificapermisodescarga.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,bPermiso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,bPermiso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iTotal
		FROM "informix".seg_permisos_usuarios
		WHERE id_usuario = pUsuario AND id_funcion =pIdFuncion AND id_permiso ='DES' AND status ='1';
		
		IF iTotal = 1 THEN
			LET bPermiso ='t';
		ELSE 
			LET bPermiso ='f';
		END IF;	
		
		RETURN cCodRet,bPermiso;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/08/2021',
'FUNCIONALIDAD: ', 
'DESCRIPCION: SPL encargado de hacer la validacion de permisos para descarga',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cb_verificastatusrepcuentasatrasp(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS nombre_archivo,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,		
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cProceso CHAR(15);
	DEFINE cNombre_archivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cProceso='';
	LET cNombre_archivo=0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cb_verificastatusrepcuentasatrasp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,nombre_archivo,error_proceso,error,tipo_proceso
		INTO cStatus,cNombre_archivo,cErrorProceso,cError,cProceso
		FROM "informix".sw_verificastatusrepcuentasatraspasar
		WHERE usuario_insert = TRIM(pUsuario);
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'','','I','','';
		ELSE 			
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 30/07/2021',
'MODULO:  ',
'FUNCIONALIDAD: ', 
'DESCRIPCION: SPL encargado de hacer la validacion del reporte cuentas a traspasar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cb_verificastatusrepcuentastrasp(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS nombre_archivo,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,		
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cProceso CHAR(15);
	DEFINE cNombre_archivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cProceso='';
	LET cNombre_archivo=0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cb_verificastatusrepcuentastrasp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,nombre_archivo,error_proceso,error,tipo_proceso
		INTO cStatus,cNombre_archivo,cErrorProceso,cError,cProceso
		FROM "informix".sw_verificastatusrepcuentastraspasadas
		WHERE usuario_insert = TRIM(pUsuario);
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'','','I','','';
		ELSE 			
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 30/07/2021',
'MODULO:  ',
'FUNCIONALIDAD: ', 
'DESCRIPCION: SPL encargado de hacer la validacion del reporte cuentas traspasadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultasucursalesfiltro(pUsuario CHAR(8), pIdFuncion CHAR(10), pFiltro CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS num_sucursal,
		CHAR(40) AS nombre_sucursal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumSucursal CHAR(4);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumSucursal = '';
	LET cNombreSucursal = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSucursal, cNombreSucursal;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_consultasucursalesfiltro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSucursal, cNombreSucursal;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumSucursal, cNombreSucursal;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSucursal, cNombreSucursal;
		END IF;
		
		IF pFiltro <> '' THEN
			IF pFiltro NOT IN ('S', 'N') THEN
				LET cCodRet = '00044';
				RETURN cCodRet, cNumSucursal, cNombreSucursal;
			END IF;
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion sucursal, nombre
				INTO cNumSucursal, cNombreSucursal
				FROM bdinteg:"informix".si_sucursales
				WHERE tpo_sucursal = pFiltro
				UNION
                SELECT sucursal, nombre
                FROM bdinteg:"informix".si_sucursales
                WHERE sucursal in ('9250','9251','9764','5003','5011','5008','8505')
				ORDER BY sucursal
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumSucursal, cNombreSucursal WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumSucursal, cNombreSucursal;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumSucursal, cNombreSucursal;
			END IF;
			
		ELSE	
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion sucursal, nombre
				INTO cNumSucursal, cNombreSucursal
				FROM bdinteg:"informix".si_sucursales
				ORDER BY sucursal
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cNumSucursal, cNombreSucursal WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumSucursal, cNombreSucursal;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumSucursal, cNombreSucursal;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/11/2013",
"DESCRIPCION: Consulta las sucursales dependiendo del filtro que se le ponga (S o N)",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cnt_catconsulta(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		CHAR(1) AS id_catalogo,
		CHAR(35) AS desc_catalogo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdCatalogo CHAR(1);
	DEFINE cDescCatalogo CHAR(35);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cIdCatalogo = '';
	LET cDescCatalogo = '';
	LET iNumRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cIdCatalogo, cDescCatalogo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_catconsulta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCatalogo, cDescCatalogo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCatalogo, cDescCatalogo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH
			SELECT id_catalogo, desc_catalogo
			INTO cIdCatalogo, cDescCatalogo
			FROM sw_cnt_tipoconsulta
			ORDER BY id_catalogo ASC
			
			LET iNumRegistros = iNumRegistros + 1;
			RETURN cCodRet, cIdCatalogo, cDescCatalogo WITH RESUME;
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet, cIdCatalogo, cDescCatalogo;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 08/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de consultar el detalle del catÃÂ¡logo tipo de consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_consdetalleempleado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8))
    RETURNING CHAR(5) AS codret,
		CHAR(45) AS nombre,
		CHAR(4) AS sucursal,
		CHAR (3) AS puesto,
		CHAR(20) AS nombramiento,
		CHAR (10) AS asistente,
		CHAR (40) AS password;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	--
	DEFINE cEmpresaSp CHAR(3);
	DEFINE cNomEmpleado CHAR(45);
	DEFINE cSucursal CHAR(4);
	DEFINE cPuesto CHAR(3);
	DEFINE cNombramiento CHAR(20);
	DEFINE cAsistente CHAR(10);
	DEFINE cPassword CHAR(40);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';
    LET iRecuperacion = 0;
	LET iNumRegistros = 0;
	--
	LET cEmpresaSp = '';
	LET cNomEmpleado = '';
	LET cSucursal = '';
	LET cPuesto = '';
	LET cNombramiento = '';
	LET cAsistente = '';
	LET cPassword = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomEmpleado, cSucursal, cPuesto, cNombramiento, cAsistente, cPassword;
		END EXCEPTION;
				
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consdetalleempleado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNomEmpleado, cSucursal, cPuesto, cNombramiento, cAsistente, cPassword;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomEmpleado, cSucursal, cPuesto, cNombramiento, cAsistente, cPassword;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultarempleado(pNumEmpleado)
			INTO cEmpresaSp, cNomEmpleado, cSucursal, cPuesto, cNombramiento, cAsistente, cPassword
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, UPPER(cNomEmpleado), cSucursal, cPuesto, cNombramiento, cAsistente, cPassword WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '01120'; --EL NÃÂMERO DE EMPLEADO NO EXISTE
			RETURN cCodRet, cNomEmpleado, cSucursal, cPuesto, cNombramiento, cAsistente, cPassword;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 22/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS A EMPLEADOS',
'DESCRIPCION: Spl encargado de obtener el detalle del empleado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_consdetallefaltantedescaemp(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pNumEmpleado CHAR(8), pSucursal CHAR(4), pIdFaltante SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,  
		CHAR(4) AS NumeroSucursal,
		SMALLINT AS IdFaltante,   
		CHAR(80) AS DesConcepto,  
		DATE AS FechaRegistro,    
		DATE AS FechaLiquidacion, 
		CHAR(80) AS DescRecupera, 
		MONEY(10,2) AS Cargos, 	
		MONEY(10,2) AS Abonos, 	
		MONEY(12,2) AS Saldo, 	
		MONEY(12,2) AS Total; 	
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cNumEmpleado	CHAR(8);
	DEFINE cNumSucursal	CHAR(4);
	DEFINE sIdFaltante SMALLINT;
	DEFINE sIdMovimiento SMALLINT;
	DEFINE cTipoMovimiento CHAR(1);
	DEFINE cAuxiliar CHAR(12);
	DEFINE sIdRecupera SMALLINT; 
	DEFINE cDesRecupera CHAR(80);
	DEFINE mMontoMovimiento MONEY(10,0);
	DEFINE mSaldoMovimiento MONEY(10,0);        
	DEFINE dFechaRegistro DATE;
	DEFINE cTransaccion CHAR(4);
	DEFINE cContable CHAR(1);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE cReferencia CHAR(26);
	DEFINE cDesConcepto CHAR(80);
	DEFINE cSucursalPago CHAR(4);
	DEFINE dFechaReg DATE;
	DEFINE dFechaLiq DATE;
	DEFINE mTotal MONEY(12,2);
	DEFINE mCargos MONEY(10,2);
	DEFINE mAbonos MONEY(10,2);
	DEFINE mSaldo MONEY(12,2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	LET cNumEmpleado = '';
	LET cNumSucursal = '';
	LET sIdFaltante = 0;
	LET sIdMovimiento = 0;
	LET cTipoMovimiento = '';
	LET cAuxiliar = '';
	LET sIdRecupera = 0; 
	LET cDesRecupera = '';
	LET mMontoMovimiento = 0;
	LET mSaldoMovimiento = 0;        
	LET dFechaRegistro = '';
	LET cTransaccion = '';
	LET cContable = '';
	LET cUsuarioAutoriza = '';
	LET cReferencia = '';
	LET cDesConcepto = '';
	LET cSucursalPago = '';
	LET dFechaReg = '';
	LET dFechaLiq = '';
	LET mTotal = 0.00;
	LET mCargos = 0.00;
	LET mAbonos = 0.00;
	LET mSaldo = 0.00;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;		
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consdetallefaltantedescaemp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pNumEmpleado = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;
		END IF;
		
		-- VALIDACIÃÂN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion num_sucursal,id_faltante,des_concepto,
			fecha_registro,fecha_liquida,des_recupera,cargos,abonos,saldo,saldo_actual
			INTO cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal
			FROM "informix".sw_cnt_detallefaltantedescaemp
			WHERE usuario_insert = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumSucursal,sIdFaltante,UPPER(cDesConcepto),dFechaReg,dFechaLiq,UPPER(cDesRecupera),mCargos,mAbonos,mSaldo,mTotal WITH RESUME;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01126'; --NO SE ENCONTRARON DATOS PARA LA CONSULTA
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,mCargos,mAbonos,mSaldo,mTotal;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 22/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS A EMPLEADOS',
'DESCRIPCION: Spl encargado de consultar el detalle de faltantes y descuentos a empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_consdetallefaltantedescaemp_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pNumEmpleado CHAR(8), pSucursal CHAR(4), pIdFaltante SMALLINT)
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cNumEmpleado	CHAR(8);
	DEFINE cNumSucursal	CHAR(4);
	DEFINE sIdFaltante SMALLINT;
	DEFINE sIdMovimiento SMALLINT;
	DEFINE cTipoMovimiento CHAR(1);
	DEFINE cAuxiliar CHAR(12);
	DEFINE sIdRecupera SMALLINT; 
	DEFINE cDesRecupera CHAR(80);
	DEFINE mMontoMovimiento MONEY(10,0);
	DEFINE mSaldoMovimiento MONEY(10,0);        
	DEFINE dFechaRegistro DATE;
	DEFINE cTransaccion CHAR(4);
	DEFINE cContable CHAR(1);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE cReferencia CHAR(26);
	DEFINE cDesConcepto CHAR(80);
	DEFINE cSucursalPago CHAR(4);
	DEFINE dFechaReg DATE;
	DEFINE dFechaLiq DATE;
	DEFINE mTotal MONEY(12,2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '';    
	LET iNumRegistros = 0;
	LET iRecuperacion = 0;
	
	LET cNumEmpleado = '';
	LET cNumSucursal = '';
	LET sIdFaltante = 0;
	LET sIdMovimiento = 0;
	LET cTipoMovimiento = '';
	LET cAuxiliar = '';
	LET sIdRecupera = 0; 
	LET cDesRecupera = '';
	LET mMontoMovimiento = 0;
	LET mSaldoMovimiento = 0;        
	LET dFechaRegistro = '';
	LET cTransaccion = '';
	LET cContable = '';
	LET cUsuarioAutoriza = '';
	LET cReferencia = '';
	LET cDesConcepto = '';
	LET cSucursalPago = '';
	LET dFechaReg = '';
	LET dFechaLiq = '';
	LET mTotal = 0.00;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".status_cnt_detallefaltantedescaemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consdetallefaltantedescaemp_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_cnt_detallefaltantedescaemp WHERE usuario_insert = pUsuario;
		INSERT INTO "informix".status_cnt_detallefaltantedescaemp(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_cnt_detallefaltantedescaemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACIÃÂN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_cnt_detallefaltantedescaemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		DELETE FROM "informix".sw_cnt_detallefaltantedescaemp WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			EXECUTE PROCEDURE bdirech:"informix".spconsultarmovfaltante(pNumEmpleado,pSucursal,pIdFaltante,pFechaInicio,pFechaFin)
			INTO cCodRetSp,cNumEmpleado,cNumSucursal,sIdFaltante,sIdMovimiento,cTipoMovimiento,cAuxiliar,
			sIdRecupera,cDesRecupera,mMontoMovimiento,mSaldoMovimiento,dFechaRegistro,cTransaccion,cContable,
			cUsuarioAutoriza,cReferencia,cDesConcepto,cSucursalPago
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP bdirech:"informix".spconsultarmovfaltante';
			ELIF iCodRet = 1 THEN
				LET cCodRet = '00003';
				UPDATE "informix".status_cnt_detallefaltantedescaemp
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iNumRegistros;
			ELIF iCodRet = 2 THEN
				LET cCodRet = '01126'; --NO SE ENCONTRARON DATOS PARA LA CONSULTA
				UPDATE "informix".status_cnt_detallefaltantedescaemp
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			IF UPPER(cTipoMovimiento) != 'R' THEN

				IF UPPER(cTipoMovimiento) = 'C' THEN
					
					LET iRecuperacion = iRecuperacion + 1;
					INSERT INTO "informix".sw_cnt_detallefaltantedescaemp (num_sucursal,id_faltante,des_concepto,
					fecha_registro,fecha_liquida,des_recupera,cargos,abonos,saldo,usuario_insert,fecha_insert)			
					VALUES(cNumSucursal,sIdFaltante,cDesConcepto,dFechaRegistro,'',cDesRecupera,mMontoMovimiento,'',mSaldoMovimiento,pUsuario,CURRENT);
					
					LET dFechaRegistro = '';
					
				ELIF UPPER(cTipoMovimiento) = 'A' THEN
					
					IF NVL(mSaldoMovimiento,0) = 0 THEN
						LET dFechaReg = '';
						LET dFechaLiq = dFechaRegistro;
					ELSE
						LET dFechaReg = dFechaRegistro;
						LET dFechaLiq = '';
					END IF;
					
					LET iRecuperacion = iRecuperacion + 1;
					INSERT INTO "informix".sw_cnt_detallefaltantedescaemp (num_sucursal,id_faltante,des_concepto,
					fecha_registro,fecha_liquida,des_recupera,cargos,abonos,saldo,usuario_insert,fecha_insert)			
					VALUES(cNumSucursal,sIdFaltante,cDesConcepto,dFechaReg,dFechaLiq,cDesRecupera,'',mMontoMovimiento,mSaldoMovimiento,pUsuario,CURRENT);
					
					LET dFechaRegistro = '';
					LET dFechaReg = '';
					LET dFechaLiq = '';
					
				ELIF UPPER(cTipoMovimiento) = 'T' THEN
					
					LET mTotal = mMontoMovimiento;
					
				END IF;
				
			END IF;
			
		END FOREACH;
		
		UPDATE "informix".sw_cnt_detallefaltantedescaemp 
		SET saldo_actual = mTotal
		WHERE usuario_insert = pUsuario;
		
		SELECT COUNT(*) INTO iNumRegistros 
		FROM "informix".sw_cnt_detallefaltantedescaemp 
		WHERE usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01126'; --NO SE ENCONTRARON DATOS PARA LA CONSULTA
			UPDATE "informix".status_cnt_detallefaltantedescaemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_cnt_detallefaltantedescaemp
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 22/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS A EMPLEADOS',
'DESCRIPCION: Spl encargado de consultar el nÃÂºmero total de registros del detalle de faltantes y descuentos a empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_consultadetallefaltdescemp(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pEjecutivo CHAR(8), pSucursal CHAR(4), pZona CHAR(3), pRegional CHAR(3), pIdAsignado SMALLINT, pEstatus SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,      --
		CHAR(8) AS NumEmpleado, 	  --No. de Empleado
		CHAR(45) AS NomEmpleado, 	  --Nombre de Empleado
		CHAR(4) AS Sucursal, 	      --C.C. Suc.
		CHAR(40) AS NomSucursal, 	  --Nombre de Sucursal o ÃÂrea
		SMALLINT AS IdFaltante, 	  --Id
		CHAR(12) AS Auxiliar, 	      --
		CHAR(3) AS NumZona,  	      --
		CHAR(3) AS NumRegion, 	      --
		SMALLINT AS IdConcepto, 	  --
		CHAR(80) AS DesConcepto, 	  --Concepto
		SMALLINT AS IdRecupera, 	  --
		CHAR(80) AS DesRecupera, 	  --Forma de Recuperar
		SMALLINT AS IdAsignado, 	  --
		CHAR(80) AS DesAsignado, 	  --Asignado a
		SMALLINT AS IdEstatus, 	      --
		CHAR(80) AS DesEstatus, 	  --Estatus
		MONEY(10,2) AS SaldoInicial,  --Importe del Faltante o DaÃÂ±o
		MONEY(10,2) AS DescAcumulado, --Descuento Acumulado
		MONEY(10,2) AS DescCalculado, --
		MONEY(10,2) AS SaldoActual,   --Saldo
		MONEY(10,2) AS SaldoQueb,     --Importe Quebranto
		CHAR(40) AS BancoCheque, 	  --
		DATE AS FechaLiquida, 	      --Fecha de EliminaciÃÂ³n
		DATE AS FechaAsigna, 	      --
		DATE AS FechaRegistro,        --Fecha de Registro
		CHAR(26) AS Referencia,       --
		CHAR(8) AS UsuariAutoriza,    --
		MONEY(12,2) AS TotalFaltante, --
		MONEY(12,2) AS TotalSaldo,    --
		MONEY(12,2) AS TotalQueb;     --
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cNumEmpleado	CHAR(8);
	DEFINE cNomEmpleado	CHAR(45);
	DEFINE cNumSucursal	CHAR(4);  
	DEFINE cNomSucursal	CHAR(40);
	DEFINE sIdFaltante SMALLINT; 
	DEFINE cAuxiliar CHAR(12); 
	DEFINE cNumZona CHAR(3);	
	DEFINE cNumRegional CHAR(3); 
	DEFINE sIdConcepto SMALLINT; 
	DEFINE cDesConcepto CHAR(80);
	DEFINE sIdRecupera SMALLINT; 
	DEFINE cDesRecupera CHAR(80);
	DEFINE sIdAsignado SMALLINT; 	     
	DEFINE cDesAsignado CHAR(80);
	DEFINE sIdEstatus SMALLINT; 
	DEFINE cDesEstatus CHAR(80);
	DEFINE mSaldoInicial MONEY(10,0); 
	DEFINE mDescAcumulado MONEY(10,0); 
	DEFINE mDescCalculado MONEY(10,0); 
	DEFINE mSaldoActual MONEY(10,0); 
	DEFINE mSaldoQueb MONEY(10,0); 
	DEFINE cBancoCheque CHAR(40); 
	DEFINE dFechaLiquida DATE; 
	DEFINE dFechaAsigna DATE;         
	DEFINE dFechaRegistro DATE;	
	DEFINE cReferencia CHAR(26);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE mTotalFaltante MONEY(12,2);
	DEFINE mTotalSaldo MONEY(12,2);
	DEFINE mTotalQueb MONEY(12,2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	LET cNumEmpleado = '';
	LET cNomEmpleado = '';
	LET cNumSucursal = '';
	LET cNomSucursal = '';
	LET sIdFaltante = 0;
	LET cAuxiliar = '';
	LET cNumZona = '';	
	LET cNumRegional = '';
	LET sIdConcepto = 0;
	LET cDesConcepto = '';
	LET sIdRecupera = 0;
	LET cDesRecupera = '';
	LET sIdAsignado = 0;  
	LET cDesAsignado = '';
	LET sIdEstatus = 0;
	LET cDesEstatus = '';
	LET mSaldoInicial = 0;
	LET mDescAcumulado = 0;
	LET mDescCalculado = 0;
	LET mSaldoActual = 0;
	LET mSaldoQueb = 0;
	LET cBancoCheque = '';
	LET dFechaLiquida = '';
	LET dFechaAsigna = '';    
	LET dFechaRegistro = '';
	LET cReferencia = '';
	LET cUsuarioAutoriza = '';
	LET mTotalFaltante = 0.00;
	LET mTotalSaldo = 0.00;
	LET mTotalQueb = 0.00;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;			
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consultadetallefaltdescemp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;
		END IF;
		
		-- VALIDACIÃÂN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;
		END IF;
		
		FOREACH 
		
			SELECT SKIP pRegistros FIRST pRecuperacion num_empleado,nom_empleado,sucursal,nom_sucursal,
			id_faltante,auxiliar,num_zona,num_region,id_concepto,des_concepto,id_recupera,des_recupera,id_asignado,des_asignado,
			id_estatus,des_estatus,saldo_inicial,desc_acumulado,desc_calculado,saldo_actual,banco_cheque,
			fecha_liquida,fecha_asigna,fecha_registro,usuario_autoriza,referencia,saldo_queb,total_faltante,total_saldo,total_queb
			INTO cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuarioAutoriza,cReferencia,mSaldoQueb,mTotalFaltante,mTotalSaldo,mTotalQueb
			FROM "informix".sw_cnt_detallefaltdescemp
			WHERE usuario_insert = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,UPPER(cDesConcepto),sIdRecupera,UPPER(cDesRecupera),sIdAsignado,UPPER(cDesAsignado),sIdEstatus,UPPER(cDesEstatus),
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			NVL(dFechaLiquida,''),NVL(dFechaAsigna,''),NVL(dFechaRegistro,''),cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb WITH RESUME;
						
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,mSaldoQueb,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cReferencia,cUsuarioAutoriza,mTotalFaltante,mTotalSaldo,mTotalQueb;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 09/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de consultar el detalle de faltantes y descuentos de empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_consultadetallefaltdescemp_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pEjecutivo CHAR(8), pSucursal CHAR(4), pZona CHAR(3), pRegional CHAR(3), pIdAsignado SMALLINT, pEstatus SMALLINT)
	RETURNING CHAR(5) AS codret, 
        INTEGER AS total_registros;
                        
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE cNumEmpleado	CHAR(8);
	DEFINE cNomEmpleado	CHAR(45);
	DEFINE cNumSucursal	CHAR(4);  
	DEFINE cNomSucursal	CHAR(40);
	DEFINE sIdFaltante SMALLINT; 
	DEFINE cAuxiliar CHAR(12); 
	DEFINE cNumZona CHAR(3);	
	DEFINE cNumRegional CHAR(3); 
	DEFINE sIdConcepto SMALLINT; 
	DEFINE cDesConcepto CHAR(80);
	DEFINE sIdRecupera SMALLINT; 
	DEFINE cDesRecupera CHAR(80);
	DEFINE sIdAsignado SMALLINT; 	     
	DEFINE cDesAsignado CHAR(80);
	DEFINE sIdEstatus SMALLINT; 
	DEFINE cDesEstatus CHAR(80);
	DEFINE mSaldoInicial MONEY(10,0); 
	DEFINE mDescAcumulado MONEY(10,0); 
	DEFINE mDescCalculado MONEY(10,0); 
	DEFINE mSaldoActual MONEY(10,0); 
	DEFINE mSaldoQueb MONEY(10,0); 
	DEFINE cBancoCheque CHAR(40); 
	DEFINE dFechaLiquida DATE; 
	DEFINE dFechaAsigna DATE;         
	DEFINE dFechaRegistro DATE;	
	DEFINE cReferencia CHAR(26);
	DEFINE cUsuarioAutoriza CHAR(8);
	DEFINE mTotalFaltante MONEY(12,2);
	DEFINE mTotalSaldo MONEY(12,2);
	DEFINE mTotalQueb MONEY(12,2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	LET cNumEmpleado = '';
	LET cNomEmpleado = '';
	LET cNumSucursal = '';
	LET cNomSucursal = '';
	LET sIdFaltante = 0;
	LET cAuxiliar = '';
	LET cNumZona = '';	
	LET cNumRegional = '';
	LET sIdConcepto = 0;
	LET cDesConcepto = '';
	LET sIdRecupera = 0;
	LET cDesRecupera = '';
	LET sIdAsignado = 0;  
	LET cDesAsignado = '';
	LET sIdEstatus = 0;
	LET cDesEstatus = '';
	LET mSaldoInicial = 0;
	LET mDescAcumulado = 0;
	LET mDescCalculado = 0;
	LET mSaldoActual = 0;
	LET mSaldoQueb = 0;
	LET cBancoCheque = '';
	LET dFechaLiquida = '';
	LET dFechaAsigna = '';    
	LET dFechaRegistro = '';
	LET cReferencia = '';
	LET cUsuarioAutoriza = '';
	LET mTotalFaltante = 0.00;
	LET mTotalSaldo = 0.00;
	LET mTotalQueb = 0.00;
	
	BEGIN
			
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".status_cnt_detallefaltdescemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consultadetallefaltdescemp_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_cnt_detallefaltdescemp WHERE usuario_insert = pUsuario;
		INSERT INTO "informix".status_cnt_detallefaltdescemp(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_cnt_detallefaltdescemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END IF;
			
		-- VALIDACIÃÂN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_cnt_detallefaltdescemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iRegistros;
		END IF;         
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".sw_cnt_detallefaltdescemp WHERE usuario_insert = pUsuario;
		
		FOREACH 
			
			EXECUTE PROCEDURE bdirech:"informix".spconsultarconfaltante(pEjecutivo, pSucursal, pZona, pRegional, pIdAsignado, pFechaInicio, pFechaFin, pEstatus)
			INTO cCodRetSp,cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuarioAutoriza,cReferencia,mSaldoQueb
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP spconsultarconfaltante';
			END IF;
			
			IF mSaldoActual > 0 THEN
				LET mTotalFaltante = mTotalFaltante + mSaldoInicial;
				LET mTotalSaldo = mTotalSaldo + mSaldoActual;
			END IF;
			LET mTotalQueb = mTotalQueb + mSaldoQueb;
			
			
			INSERT INTO "informix".sw_cnt_detallefaltdescemp (num_empleado,nom_empleado,sucursal,nom_sucursal,
			id_faltante,auxiliar,num_zona,num_region,id_concepto,des_concepto,id_recupera,des_recupera,id_asignado,des_asignado,
			id_estatus,des_estatus,saldo_inicial,desc_acumulado,desc_calculado,saldo_actual,banco_cheque,
			fecha_liquida,fecha_asigna,fecha_registro,usuario_autoriza,referencia,saldo_queb,usuario_insert,fecha_insert)			
			VALUES(cNumEmpleado,cNomEmpleado,cNumSucursal,cNomSucursal,sIdFaltante,cAuxiliar,cNumZona,cNumRegional,
			sIdConcepto,cDesConcepto,sIdRecupera,cDesRecupera,sIdAsignado,cDesAsignado,sIdEstatus,cDesEstatus,
			mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,
			dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuarioAutoriza,cReferencia,mSaldoQueb,pUsuario,CURRENT);
						
		END FOREACH;
		
		UPDATE "informix".sw_cnt_detallefaltdescemp 
		SET total_faltante = mTotalFaltante, total_saldo  = mTotalSaldo, total_queb = mTotalQueb 
		WHERE usuario_insert = pUsuario;
		
		SELECT COUNT(*) INTO iRegistros FROM "informix".sw_cnt_detallefaltdescemp WHERE usuario_insert = pUsuario;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".status_cnt_detallefaltdescemp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iRegistros;
		END IF;
		
		UPDATE "informix".status_cnt_detallefaltdescemp
		SET status = 'T', error_proceso = 'N', num_registros = iRegistros WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, iRegistros;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 09/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de consultar el nÃÂºmero total de registros del detalle de faltantes y descuentos de empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_detallecatalogos(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdCatalogo CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret, 
        CHAR(10) AS id_campo,
		CHAR(100) AS desc_campo;
                        
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cIdCampo CHAR(10);
	DEFINE cDescCampo CHAR(100);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombre CHAR(80);
	DEFINE cDireccion1 CHAR(40);
	DEFINE cDireccion2 CHAR(40);
	DEFINE cTelefono1 CHAR(14);
	DEFINE cGerente CHAR(40);
	DEFINE cSubgerente CHAR(40);
	DEFINE cTipoSucursal CHAR(2);
	DEFINE cPlaza CHAR(3);
    DEFINE cRegional CHAR(3);
	DEFINE dFecha DATE;
	DEFINE iIdAsignado SMALLINT;
	DEFINE iIdEstatus SMALLINT;
	DEFINE cDivisa CHAR(2);
	DEFINE cStatus CHAR(2);
	DEFINE cSolicitud CHAR(1);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cIdCampo = '';
	LET cDescCampo = '';
	LET cSucursal = '';
	LET cNombre = '';
	LET cDireccion1 = '';
	LET cDireccion2 = '';
	LET cTelefono1 = '';
	LET cGerente = '';
	LET cSubgerente = '';
	LET cTipoSucursal = '';
	LET cPlaza = '';
    LET cRegional = '';
	LET dFecha = '';
	LET iIdAsignado = NULL;
	LET iIdEstatus = NULL;
	LET cDivisa = '';
	LET cStatus = '';
	LET cSolicitud = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
			
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdCampo, cDescCampo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_detallecatalogos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdCatalogo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCampo, cDescCampo;
		END IF;
		
		-- VALIDACIÃÂN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCampo, cDescCampo;
		END IF;         
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Sucursal
		IF pIdCatalogo = '1' THEN
			
			IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
				RETURN cCodRet, cIdCampo, cDescCampo;
			END IF;
			
			IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cIdCampo, cDescCampo;
			END IF;
			
			IF pIdFuncion IN ('CNT001','CCN001') THEN
				
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatsucursales2(cEmpresa,'',pRegistros,pRecuperacion)
					INTO cCodRetSp, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal
					
					LET iCodRet = cCodRetSp::INTEGER;
					IF iCodRet < 0 THEN
						RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultarcatsucursales2';
					ELIF iCodRet = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet, cIdCampo, cDescCampo;
					END IF;
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cSucursal, UPPER(cNombre) WITH RESUME;
				END FOREACH;
			
			ELIF pIdFuncion IN ('CNT002','CTB106','CNT003','CTB107','CNT004','CTB108','CNT101','CRE918') THEN
				
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion sucursal, nombre 
					INTO cSucursal, cNombre
					FROM bdinteg:"informix".si_sucursales
					WHERE empresa = cEmpresa ORDER BY sucursal ASC
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cSucursal, UPPER(cNombre) WITH RESUME;
				END FOREACH;
				
			END IF;
			
			IF pRegistros = 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdCampo, cDescCampo;
			ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdCampo, cDescCampo;
			END IF;
			
		-- Zona
		ELIF pIdCatalogo = '2' THEN
			
			FOREACH
				EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatplazas(cEmpresa,'')
				INTO cCodRetSp, cEmpresa, cPlaza, cNombre, cRegional
				
				LET iCodRet = cCodRetSp::INTEGER;
				IF iCodRet < 0 THEN
					RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultarcatplazas';
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cPlaza, UPPER(cNombre) WITH RESUME;
			END FOREACH;
			
		-- Regional
		ELIF pIdCatalogo = '3' THEN
				
			IF pIdFuncion IN ('CNT102','CTB109','CNT008','CTB110') THEN
				
				FOREACH
					SELECT regional, nombre 
					INTO cRegional, cNombre
					FROM bdinteg:"informix".si_regional
					WHERE empresa = cEmpresa ORDER BY regional ASC
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cRegional, UPPER(cNombre) WITH RESUME;
				END FOREACH;
				
			ELSE
				
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".spconsultarcatregiones(cEmpresa,'')
					INTO cCodRetSp, cEmpresa, cRegional, cNombre, dFecha
					
					LET iCodRet = cCodRetSp::INTEGER;
					IF iCodRet < 0 THEN
						RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP spconsultarcatregiones';
					ELIF iCodRet = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet, cIdCampo, cDescCampo;
					END IF;
					
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cRegional, UPPER(cNombre) WITH RESUME;
				END FOREACH;
				
			END IF;
			
		-- ÃÂreas
		ELIF pIdCatalogo = '4' THEN
			
			FOREACH
				EXECUTE PROCEDURE bdirech:"informix".spconsultarcatasignado('')
				INTO cCodRetSp, iIdAsignado, cNombre, dFecha
				
				LET iCodRet = cCodRetSp::INTEGER;
				IF iCodRet < 0 THEN
					RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP spconsultarcatasignado';
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iIdAsignado, UPPER(cNombre) WITH RESUME;
			END FOREACH;
			
		-- Estatus
		ELIF pIdCatalogo = '5' THEN
			
			FOREACH
				EXECUTE PROCEDURE bdirech:"informix".spconsultarcatestatus('')
				INTO cCodRetSp, iIdEstatus, cNombre, dFecha
				
				LET iCodRet = cCodRetSp::INTEGER;
				IF iCodRet < 0 THEN
					RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP spconsultarcatestatus';
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iIdEstatus, UPPER(cNombre) WITH RESUME;
			END FOREACH;
			
		-- Moneda
		ELIF pIdCatalogo = '6' THEN
			
			FOREACH
				SELECT divisa, descripcion 
				INTO cDivisa, cNombre
				FROM bdinteg:"informix".si_divisas
				WHERE empresa = cEmpresa ORDER BY divisa ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cDivisa, UPPER(cNombre) WITH RESUME;
			END FOREACH;
			
		-- Estatus (Reporte de Solicitudes de CrÃÂ©dito/Monitor de Solicitudes de Estudio)
		ELIF pIdCatalogo = '7' THEN
			
			FOREACH
				SELECT status_solicitud, descripcion
				INTO cStatus, cNombre			
				FROM bdisolic:"informix".ss_status_sol 
				WHERE empresa = cEmpresa ORDER BY status_solicitud ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cStatus, UPPER(cNombre) WITH RESUME; 
			END FOREACH;
			
		-- Solicitud
		ELIF pIdCatalogo = '8' THEN
			
			FOREACH
				SELECT tp_solicitud, descripcion
				INTO cSolicitud, cNombre			
				FROM bdisolic:"informix".ss_tp_solicitud WHERE empresa = cEmpresa ORDER BY 2
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cSolicitud, UPPER(cNombre) WITH RESUME; 
			END FOREACH;
		
		END IF; 
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdCampo, cDescCampo;
		END IF;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 08/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de obtener el detalle del catÃÂ¡logo consultado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_reportefaltantedescuentoemp_xls(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150))
        RETURNING CHAR(5) AS codret,
				  CHAR(150) AS archivo_generado;

        DEFINE cCodRet 				CHAR(5);
        DEFINE iSqlErr 				INT;
        DEFINE cCmd1 				CHAR(4000);
		DEFINE cCmd2 				CHAR(4000);
		DEFINE cArchDescarga		CHAR(200);
		DEFINE iNoRegistros         INT;
		DEFINE cCodRetSp		    CHAR(5);
		DEFINE cRutaInformix CHAR(100);
		DEFINE cUsrBin CHAR(100);
		DEFINE cNameReport CHAR(60);
		DEFINE ven_transacc SMALLINT;
		DEFINE bInTransaction BOOLEAN;
		DEFINE cSql CHAR(8000);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCmd1 = '';
		LET cCmd2 = '';
		LET cArchDescarga = '';
		LET cCodRetSp = '00000';
		LET cRutaInformix = '/informix/bin/';
		LET cUsrBin = '/usr/bin/';
		LET cNameReport = '';
		LET ven_transacc = 0;
		LET bInTransaction = 'f';
		LET cSql = '';
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					IF ven_transacc = 1 THEN
						ROLLBACK WORK; 
					END IF;
					RETURN cCodRet,cArchDescarga;
			END EXCEPTION;
			
			ON EXCEPTION IN (-668, -535, -255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_reportefaltantedescuentoemp_xls.out';
			--TRACE ON;
		
			IF pIdUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cArchDescarga;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,cArchDescarga;
			END IF;
			
			BEGIN WORK;
					
			LET cNameReport = 'REPORTEFALTANTESDESCUENTOSEMPLEADOS.xls';

			LET cArchDescarga = TRIM(TRIM(pRutaDescarga)||TRIM(cNameReport));
			
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'C.C. SUC.','NOMBRE DE SUCURSAL O AREA','NO. EMPLEADO','NOMBRE DE EMPLEADO','CONCEPTO','FORMA DE RECUPERAR','ID','FECHA REGISTRO','FECHA DE ELIMINACION','IMPORTE DEL FALTANTE','DESCUENTO ACUMULADO','SALDO','ASIGNADO A','IMPORTE QUEBRANTO','ESTATUS'";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT ''''||sucursal,nom_sucursal,num_empleado,nom_empleado,UPPER(des_concepto),UPPER(des_recupera),id_faltante::CHAR(11),NVL(TO_CHAR(fecha_registro, '%d/%m/%Y'), ' '), NVL(TO_CHAR(fecha_liquida, '%d/%m/%Y'), ' '),saldo_inicial::CHAR(20),desc_acumulado::CHAR(20),saldo_actual::CHAR(20),UPPER(des_asignado),saldo_queb::CHAR(20),UPPER(des_estatus)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cnt_detallefaltdescemp";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pIdUsuario ||"'";	
			LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			
			LET cCmd2 = '';
			LET cCmd2 = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchDescarga)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryRFDE.sql';
			SYSTEM TRIM(cCmd2);			
		
			LET cCmd1 = '';
			LET cCmd1 = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryRFDE.sql';
			SYSTEM TRIM(cCmd1); 
						
			LET cCmd1 = '';
			LET cCmd1 = TRIM(cUsrBin)||"rm -rf "||TRIM(pRutaDescarga)||'queryRFDE.sql';
			SYSTEM TRIM(cCmd1);		

			COMMIT WORK;			
		
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
					
			RETURN cCodRet,cArchDescarga;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 12/08/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de generar los reportes de la consulta de faltantes y descuentos de empleados en formato xls.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_verificastatusdetfaltantedescaemp(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_verificastatusdetfaltantedescaemp.out';
		--TRACE ON;
		
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
		FROM "informix".status_cnt_detallefaltantedescaemp WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 22/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS A EMPLEADOS',
'DESCRIPCION: Spl encargado de verificar el status de la consulta de faltantes y descuentos a empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_verificastatusdetfaltdescemp(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_verificastatusdetfaltdescemp.out';
		--TRACE ON;
		
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
		FROM "informix".status_cnt_detallefaltdescemp WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA 09/04/2019',
'MODULO: CONTRALORÃÂA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de verificar el status de la consulta de faltantes y descuentos de empleados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_actualizastatususuariomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1))
RETURNING
        CHAR(5) AS COD_RET,
        CHAR(80) AS DESCRIPCION; 
    
	---DECLARACIONES
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cErrorInfo   CHAR(80);
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensajeRet  CHAR(80);
	DEFINE cEstatus  	CHAR(8);
    ---INICIALIZACIONES
    LET iSqlErr       = 0;
    LET iIsamErr      = 0;
    LET cErrorInfo    = '';
    LET cCodRet       = '00000';
    LET cMensajeRet   = 'Proceso Exitoso';
	LET cEstatus	  = '';
	
BEGIN

   ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet, cMensajeRet;
	END EXCEPTION;
    
	--SET DEBUG FILE TO "/tmp/mfinis/sp_mc_actualizastatususuariomc.out";
	--TRACE ON;
	
    IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet, cMensajeRet;
	END IF;   
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, cMensajeRet;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF pBandera = 1 THEN 
		LET cEstatus = 'DISP';
	ELIF pBandera = 2 THEN 
		LET cEstatus = 'NO DISP';
	ELIF pBandera = 3 THEN 
		LET cEstatus = 'INACTIVO'; 
	END IF;
	
    UPDATE bdisolic:"informix".ss_analistaenatencion SET status_analista = cEstatus WHERE ejecutivo = pUsuario;
	 
	RETURN cCodRet, cMensajeRet;
	
END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 03/08/2018',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: Se atualiza el status del ejecutivo en atenciÃ³n que se encuentra en la funcionalidad Cambio de Status.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_eliminasolicatenusuariomc(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING
        CHAR(5) AS COD_RET,
        CHAR(80) AS DESCRIPCION; 
    
	---DECLARACIONES
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cErrorInfo   CHAR(80);
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensajeRet  CHAR(80);
	DEFINE cHora              CHAR(8);
    ---INICIALIZACIONES
    LET iSqlErr       = 0;
    LET iIsamErr      = 0;
    LET cErrorInfo    = '';
    LET cCodRet       = '00000';
    LET cMensajeRet   = '';
	
	--	SET DEBUG FILE TO "/informix/gpe/sp_mc_eliminasolicatenusuariomc.out";
	--TRACE ON;
	
	
BEGIN
   /*ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet, cMensajeRet;
	END EXCEPTION;*/
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;	
            LET cMensajeRet = 'Error --> '||cErrorInfo||''||cHora||''||pUsuario||''||pIdFuncion;

			INSERT INTO "informix".sw_bitacora_soc(cod_ret,mensaje,hora_insert,user_insert,funcion)
			VALUES (cCodRet,cMensajeRet,cHora,pUsuario,pIdFuncion);
			
            RETURN cCodRet,cMensajeRet;
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHora FROM sysmaster:sysshmvals;
	

    IF pUsuario = '' OR pIdFuncion = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet, cMensajeRet;
	END IF;   
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, cMensajeRet;
	END IF;
	
	
	--BEGIN WORK;
	
	DELETE FROM bdisolic:"informix".ss_cte_procesando WHERE usuario = pUsuario;
	
    UPDATE bdisolic:"informix".ss_solicitudes_mc SET ejecutivo_atiende ='' WHERE ejecutivo_atiende = pUsuario AND status_fin = '' AND revisado <> 'S';
	 
	--COMMIT WORK;
	LET cMensajeRet = 'Proceso Exitoso';					
	RETURN cCodRet, cMensajeRet;
	
END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 03/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: Se elimina la solicitud al salir de la pantalla Cambio de Status.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtenerfechahoy(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		DATE AS fecha_hoy;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaHoy DATE;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFechaHoy = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,dFechaHoy;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerfechahoy.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaHoy;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaHoy;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerfechahoy(cEmpresa)
		INTO dFechaHoy;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet,dFechaHoy;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 11/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: Spl encargado de consultar la fecha hoy de la tabla bdinteg:si_fechas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarasigconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), 
pNumSucursal CHAR(4), pIdFaltante SMALLINT, pFechaAsignacion DATE, pIdAsignado SMALLINT, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_actualizarasigconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pFechaAsignacion = '' OR pIdAsignado = '' OR pUsuarioAutoriza = ''  THEN
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
		
		EXECUTE PROCEDURE bdirech:"informix".spactualizarasigconfaltante(pNumEmpleado,pNumSucursal,pIdFaltante,pFechaAsignacion,pIdAsignado,pUsuarioAutoriza)
	    INTO cCodRet;
		
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;


           LET cCodRet ='00000';
       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01228';         END IF;


		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL intermedio encargado de ejecutar el sp productivo spactualizarasigconfaltante ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarconfaltantereversoasig(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), pNumSucursal CHAR(4),
			pIdFaltante SMALLINT, pFechaAsignacion DATE, pIdEstatus SMALLINT, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);

	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;

	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarconfaltantereversoasig.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pNumEmpleado='' OR pNumSucursal='' OR pIdFaltante='' OR pFechaAsignacion='' OR pIdEstatus='' or pUsuarioAutoriza='' THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizarconfaltantereversoasig(pNumEmpleado,pNumSucursal,pIdFaltante,pFechaAsignacion,pIdEstatus,pUsuarioAutoriza)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;
        
         

       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01228';         END IF;

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 02/05/2021',
'MODULO: ',
'FUNCIONALIDAD:OFI ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizarconfaltantereversoasig ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizardepositofaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4), 
pIdFaltante SMALLINT, pDescuento MONEY(10,0), pFecha DATE, pBancoCheque CHAR(40), pUsuarioAurotiza CHAR(8))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizardepositofaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pDescuento = '' OR pFecha ='' OR pBancoCheque = '' OR pUsuarioAurotiza = '' THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizardepositofaltante(pNumEmpleado,pNumSucursal,pIdFaltante,pDescuento,pFecha,pBancoCheque,pUsuarioAurotiza)
		INTO  cCodRet;
           	
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;


        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;

        IF cCodRet ='00002' THEN
			LET cCodRet ='01234';         END IF;
         
        IF cCodRet ='00003' THEN
			LET cCodRet ='01236';         END IF;
        

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizardepositofaltante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizardescconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaQuincena DATE, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizardescconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena ='' OR pUsuarioAutoriza = ''  THEN
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
		
		EXECUTE PROCEDURE bdirech:"informix".spactualizardescconfaltante(pFechaQuincena,pUsuarioAutoriza)
		INTO  cCodRet;
        
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

        IF cCodRet ='00001' THEN
			LET cCodRet ='0003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01226';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01280'; 		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01282';         END IF;
        IF cCodRet ='00005' THEN
			LET cCodRet ='01278'; 		END IF;
  
		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizardescconfaltante ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizardescdescquincena(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pDescAplicado MONEY(10,0))
		RETURNING CHAR(5) AS codret
			
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizardescdescquincena.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado ='' OR pDescAplicado = ''  THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizardescdescquincena(pNumEmpleado,pDescAplicado)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01227';         END IF;

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/01/2021',
'MODULO:OFI ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp intermedio spactualizardescdescquincena',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarfijoconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10), pSueldoQuincena MONEY(16,2), pNumEmpleado CHAR(8), 
pNumSucursal CHAR(4), pIdFaltante SMALLINT, pFechaAsignacion DATE,pDescQuincenaFijo MONEY (10,0), pIdAsignado SMALLINT, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret,
				  MONEY(10,0) AS MaximoDescuento
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE mMaximoDescuento MONEY(10,0);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET mMaximoDescuento=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mMaximoDescuento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarfijoconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pFechaAsignacion = '' OR pIdAsignado = '' OR pUsuarioAutoriza = ''  OR pSueldoQuincena='' OR pDescQuincenaFijo='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mMaximoDescuento;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mMaximoDescuento;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
																		
		EXECUTE PROCEDURE bdirech:"informix".spactualizarfijoconfaltante(pSueldoQuincena, pNumEmpleado, pNumSucursal, pIdFaltante ,pFechaAsignacion, pIdAsignado, pDescQuincenaFijo, pUsuarioAutoriza)
		
		INTO cCodRet, mMaximoDescuento;

        
       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, mMaximoDescuento;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='01230'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01229';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01232';         END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01233'; 		END IF;
        IF cCodRet ='00005' THEN
			LET cCodRet ='01231';         END IF;
        IF cCodRet ='00006' THEN
			LET cCodRet ='00003';         END IF;
		 IF cCodRet ='00007' THEN
			LET cCodRet ='01228';         END IF;
		
		RETURN cCodRet, mMaximoDescuento;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizarfijoconfaltante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarfinconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), pNumSucursal CHAR(4), 
							pIdFaltante SMALLINT, pDescuento MONEY(10,0), pFecha DATE, pBancoCheque CHAR(40), pUsuarioAutoriza CHAR (8))
		RETURNING CHAR(5) AS codret
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarfinconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pDescuento = '' OR pFecha = '' OR pBancoCheque = ''  OR pUsuarioAutoriza='' THEN
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
																		
		EXECUTE PROCEDURE bdirech:"informix".spactualizarfinconfaltante(pNumEmpleado,pNumSucursal, pIdFaltante, pDescuento ,pFecha, pBancoCheque, pUsuarioAutoriza)
		
		INTO cCodRet;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

   
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01234';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01236';         END IF;
		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp intermedio spactualizarfinconfaltante ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarimpconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4), pIdFaltante SMALLINT, pDescuento MONEY(10,0))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
	--	SET DEBUG FILE TO '/tmp/mfinis/spactualizarimpconfaltante.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado ='' OR pNumSucursal = '' OR pIdFaltante = '' OR pDescuento =''  THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizarimpconfaltante(pNumEmpleado,pNumSucursal,pIdFaltante,pDescuento)
		INTO  cCodRet;

       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;

      
        
        IF cCodRet ='00002' THEN
			LET cCodRet ='01267';
		END IF;
        IF cCodRet ='00001' THEN
			LET cCodRet ='01266';
		END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01257';
		END IF;
     

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizarimpconfaltante ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarprocesos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE, pIdProceso SMALLINT, pEstatus CHAR(1))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);

	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;

	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarprocesos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso =''  OR pIdProceso='' OR pEstatus='' THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizarprocesos(pFechaProceso,pIdProceso,pEstatus)
		INTO  cCodRet;

         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;


       IF cCodRet ='00001' THEN
			LET cCodRet ='01266'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01238';         END IF;

        
		RETURN cCodRet;

        
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizarprocesos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarquebrantofaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4),
 pIdFaltante SMALLINT, pFechaAsignacion DATE, pIdAsignado SMALLINT, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarquebrantofaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pFechaAsignacion = '' OR pIdAsignado ='' OR pUsuarioAutoriza = '' THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizarquebrantofaltante(pNumEmpleado,pNumSucursal,pIdFaltante,pFechaAsignacion,pIdAsignado,pUsuarioAutoriza)
		INTO  cCodRet;

          IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;

        
       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01236';         END IF;
      
		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO:OFI ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spactualizarquebrantofaltante ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_actualizarsueldoempleado(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4), 
pSueldo MONEY(10,0), pFecha DATE)
		RETURNING CHAR(5) AS codret;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spactualizarsueldoempleado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado ='' OR pNumSucursal = '' OR pSueldo ='' OR pFecha = ''   THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		

		EXECUTE PROCEDURE bdirech:"informix".spactualizarsueldoempleado(pNumEmpleado,pNumSucursal,pSueldo,pFecha)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
        
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01274';         END IF;

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: ',
'FECHA: 01/01/2018',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_calcularcifracontrol(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaQuincena DATE, pTipoCifraCtrl SMALLINT)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS suma
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE isuma INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET isuma=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, isuma;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spcalcularcifracontrol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena =''  OR pTipoCifraCtrl='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, isuma;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, isuma;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		EXECUTE PROCEDURE bdirech:"informix".spcalcularcifracontrol(pFechaQuincena,pTipoCifraCtrl)
		INTO  cCodRet, isuma;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
            RETURN cCodRet, isuma;
		END IF;

       

       IF cCodRet ='00001' THEN
			LET cCodRet ='01266'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01240';         END IF;


		RETURN cCodRet, isuma;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spcalcularcifracontrol',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_calculardescuento(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaQuincena DATE)
		RETURNING CHAR(5) AS codret;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spcalculardescuento.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena =''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		EXECUTE PROCEDURE bdirech:"informix".spcalculardescuento(pFechaQuincena)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
        
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01275';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01276';         END IF;

		RETURN cCodRet;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: ',
'FECHA: 01/01/2018',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultadepositoscuentacpp(pUsuario CHAR(8), pIdFuncion CHAR(10),pfechaDe DATE, pfechaHasta DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS numsucursal,
		CHAR(40) AS nomsucursal,
		CHAR(8) AS numempleado,
		CHAR(45) AS nomempleado,
		CHAR(80) AS desconcepto,
		SMALLINT AS idfaltante,
		DATE AS fecharegistro,
		MONEY(10,2) AS saldoinicial,
		MONEY(10,2) AS descquincenafijo,
		MONEY(10,2) AS montoabono,
		MONEY(10,2) AS saldoactual,
		DATE AS fechaasigna,
		CHAR(80) AS desasignado,
		SMALLINT AS idestatus,
		SMALLINT AS idmovimientoabono,
		CHAR(1) AS tipomovimiento,
		CHAR(10) AS fechaasignadeposito,
		DATE AS fechaliquida,
		CHAR(12) AS auxiliar,
		CHAR(26) AS referencia,
		CHAR(8) AS usuarioautoriza,
        MONEY (10,2) AS totalsaldoinicial,
        MONEY(10,2) AS totalsaldoactual;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumsucursal         CHAR(4);
    DEFINE cNomsucursal         CHAR(40);
    DEFINE cNumempleado         CHAR(8);
    DEFINE cNomempleado         CHAR(45);
    DEFINE cDesconcepto         CHAR(80);
    DEFINE iDfaltant         SMALLINT;
    DEFINE dFecharegistro       DATE; 
    DEFINE mSaldoinicial       MONEY(10,2); 
    DEFINE mDescquincenafijo   MONEY(10,2); 
    DEFINE mMontoabono         MONEY(10,2);
    DEFINE mSaldoactual         MONEY(10,2);
    DEFINE dFechaasigna         DATE; 
    DEFINE cDesasignado         CHAR(80);
    DEFINE iDestatu           SMALLINT; 
    DEFINE iMovimientoabono   SMALLINT; 
    DEFINE cTpomovimiento     CHAR(1);
    DEFINE dFechaasignadeposito CHAR(10);
    DEFINE dFechaliquida       DATE;
    DEFINE cAuxiliar           CHAR(12);
    DEFINE cReferencia         CHAR(26);
    DEFINE cUsuarioautoriza     CHAR(8);
    DEFINE mTotalSaldoinicial MONEY(10,2);
    DEFINE mTotalSaldoactual MONEY(10,2);
    
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cNumsucursal='';
    LET cNomsucursal='';
    LET cNumempleado='';
    LET cNomempleado ='';
    LET cDesconcepto ='';
    LET iDfaltant =0;
    LET dFecharegistro  =     DATE(1); 
    LET mSaldoinicial    =0;
    LET mDescquincenafijo  =0;
    LET mMontoabono  =0;
    LET mSaldoactual  =0;
    LET dFechaasigna  =  DATE(1);
    LET cDesasignado  ='';
    LET iDestatu   =0;
    LET iMovimientoabono =0;
    LET cTpomovimiento ='';
    LET dFechaasignadeposito ='';
    LET dFechaliquida =  DATE(1);
    LET cAuxiliar ='';
    LET cReferencia  ='';
    LET cUsuarioautoriza  ='';
    LET mTotalSaldoinicial =0.0;
    LET mTotalSaldoactual =0.0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
				RETURN cCodRet,cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza,mTotalSaldoinicial,mTotalSaldoactual;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_consultadepositoscuentacpp.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
				RETURN cCodRet,cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza,mTotalSaldoinicial,mTotalSaldoactual;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		RETURN cCodRet,cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza,mTotalSaldoinicial,mTotalSaldoactual;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

         SELECT sum(saldoinicial), sum(saldoactual)
		INTO mTotalSaldoinicial,mTotalSaldoactual
		FROM bdicnweb:rec_depfaltantes
        WHERE fechaasignadeposito >= DATE(pfechaDe) and fechaasignadeposito <= DATE (pfechaHasta);

		FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion 

        numsucursal,nomsucursal,numempleado,nomempleado,desconcepto,idfaltante,fecharegistro,saldoinicial,descquincenafijo,montoabono,saldoactual,
		fechaasigna,desasignado,idestatus,idmovimientoabono,tipomovimiento,TO_CHAR(fechaasignadeposito,'%d/%m/%Y') as fechaasignadeposito,fechaliquida,auxiliar,referencia,usuarioautoriza   
		
		INTO cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,
		dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza
		FROM bdicnweb:rec_depfaltantes
		WHERE fechaasignadeposito >= DATE(pfechaDe) and fechaasignadeposito <= DATE (pfechaHasta )

       RETURN cCodRet,cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza,mTotalSaldoinicial,mTotalSaldoactual WITH RESUME;
		END FOREACH;
		

       

    	IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,cNumsucursal,cNomsucursal,cNumempleado,cNomempleado,cDesconcepto,iDfaltant,dFecharegistro,mSaldoinicial,mDescquincenafijo,mMontoabono,mSaldoactual,dFechaasigna,cDesasignado,iDestatu,iMovimientoabono,cTpomovimiento,dFechaasignadeposito,dFechaliquida,cAuxiliar,cReferencia,cUsuarioautoriza,mTotalSaldoinicial,mTotalSaldoactual;
		END IF;	

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/03/2021',
'MODULO: OFI',
'FUNCIONALIDAD: CONSULTA LA TABLA DE DEPOSITOS A CUENTA BANCOPPEL',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultadepositoscuentacpp_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pfechaDe DATE, pfechaHasta DATE)
	RETURNING CHAR(5) AS codret,
                INTEGER AS numregistros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumregistros INTEGER;
 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET iNumregistros=0;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
				RETURN cCodRet,iNumregistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_consultadepositoscuentacpp_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
				RETURN cCodRet,iNumregistros;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		RETURN cCodRet,iNumregistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT (*) as numfilas
		INTO iNumregistros
		FROM bdicnweb:rec_depfaltantes
		WHERE fechaasignadeposito >= DATE(pfechaDe) and fechaasignadeposito <= DATE (pfechaHasta);

        IF (iNumregistros=0) THEN
            LET cCodRet ='00017';
        END IF;
            
        RETURN cCodRet,iNumregistros;
		

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/03/2021',
'MODULO: OFI',
'FUNCIONALIDAD: CONSULTA LA TABLA DE DEPOSITOS A CUENTA BANCOPPEL',
'DESCRIPCION: ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarcatasignado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSecuencia SMALLINT,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				 INTEGER AS IdAsignado, 
				 CHAR(80) AS DesAsignado, 
				 DATE AS FechaInsert
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cDesAsignado CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIdAsignado INTEGER;
	DEFINE dFechaInsert DATE;
    DEFINE iRecuperacion INTEGER;
	
	
	LET cCodRet = '00000';
	LET cDesAsignado = '';
	LET iIdAsignado = 0;
	LET dFechaInsert=DATE(1);
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRecuperacion=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarcatasignado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros ='' OR pRecuperacion='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert;
		END IF;

        -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert;
		END IF;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarcatasignado2(pIdSecuencia,pRegistros,pRecuperacion)
		INTO cCodRet, iIdAsignado, cDesAsignado,dFechaInsert
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert 
		WITH RESUME;
		END FOREACH;

        IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert ;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdAsignado, cDesAsignado,dFechaInsert ;
		END IF;	
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo  spconsultarcatasignado2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarcatplazas(pUsuario CHAR(8), pIdFuncion CHAR(10), pPlaza CHAR(3),pRegional CHAR(3))
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS empresa, 
				  CHAR (3) AS plaza, 
				  CHAR(40) AS nombre, 
				  CHAR (3) AS regional, 
				  DATE AS fecha_insert
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cPlaza CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE cRegional CHAR(3);
	DEFINE dFecha_Insert DATE;
	
	
	LET cCodRet = '00000';
	LET cEmpresa = '001';
	LET cPlaza = '';
	LET cNombre ='';
	LET cRegional ='';
	LET dFecha_Insert=DATE(1);
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarcatplazas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".spconsultarcatplazas(cEmpresa,pPlaza,pRegional)
		INTO cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert

		RETURN cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert
		WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEmpresa,cPlaza,cNombre,cRegional,dFecha_Insert;
		END IF;

		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/01/2018',
'MODULO: OFI ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarcatplazas ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarcatregiones(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegional CHAR(3),pRecuperacion INTEGER, pRegistros INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS empresa, 
				  CHAR (3) AS regional, 
				  CHAR(40) AS nombre, 
				  DATE AS fecha_insert
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre CHAR(40);
	DEFINE cRegional CHAR(3);
	DEFINE dFecha_Insert DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cEmpresa = '001';
	LET cNombre ='';
	LET cRegional ='';
	LET dFecha_Insert=DATE(1);
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
    LET iRecuperacion =0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarcatregiones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRecuperacion =''  OR pRegistros='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		END IF;


          -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".spconsultarcatregiones2(cEmpresa,pRegional,pRecuperacion,pRegistros)
		INTO cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert
		WITH RESUME;
		END FOREACH;
		
        IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEmpresa,cRegional,cNombre,dFecha_Insert;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarcatregiones2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarcatsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4),pRegistros INTEGER,pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS empresa, 
				  CHAR(4) AS sucursal, 
				  CHAR(40) AS nombre, 
				  CHAR(40) AS direccion1, 
				  CHAR(40) AS direccion2, 
				  CHAR(14) AS telefono,
				  CHAR(40) AS gerente, 
				  CHAR(40) AS subgerente, 
				  CHAR(2) AS tpo_sucursal
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cNombre CHAR(40);
	DEFINE cDireccion1 CHAR(40);
	DEFINE cDireccion2 CHAR(40);
	DEFINE cTelefono CHAR(14);
	DEFINE cGerente CHAR(40);
	DEFINE cSubgerente CHAR(40);
	DEFINE cTpoSucursal CHAR(2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET cNombre ='';
	LET cDireccion1 ='';
	LET cDireccion2='';
	LET cTelefono='';
	LET cGerente ='';
	LET cSubgerente ='';
	LET cTpoSucursal ='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRecuperacion=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		END EXCEPTION;
		
	--	SET DEBUG FILE TO '/tmp/mfinis/sp_consultarcatsucursales.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pRecuperacion ='' OR pRegistros='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		END IF;
		
        -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatsucursales2(cEmpresa,pSucursal,pRegistros,pRecuperacion)
		INTO cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal
		WITH RESUME;
		END FOREACH;
		
       IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cDireccion1,cDireccion2,cTelefono,cGerente,cSubgerente,cTpoSucursal;
		END IF;	
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_consultarcatsucursales2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarcatsucursales_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), p_sSucursal CHAR(4))
	RETURNING 	CHAR(6) AS retorno,
				INTEGER AS numFilas;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(6);
	DEFINE iNumFilas	INTEGER;
	DEFINE v_sMin           CHAR(4);
	DEFINE v_sMax           CHAR(4);
	Define p_sEmpresa CHAR(3);

	LET v_sValRetorno = '00000';
	LET iNumFilas=0;
	LET p_sEmpresa='001';
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN v_sValRetorno,iNumFilas;
		END IF;
	END EXCEPTION;

	--- SET DEBUG FILE TO "/tmp/mfinis/sp_ofi_consultarcatsucursales_totales.out";
	--- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;
	
	-- // DEBE PROPORCIONARSE LA EMPRESA
	IF NVL(p_sEmpresa,'') = '' THEN
		RETURN v_sValRetorno,iNumFilas;
	END IF;
	
	IF p_sSucursal is null THEN
		LET p_sSucursal = '';
	END IF;

	IF p_sSucursal = '' THEN
		SELECT MIN(sucursal), MAX(sucursal)
		  INTO v_sMin, v_sMax
		  FROM bdinteg:si_sucursales;
		
		FOREACH
			SELECT {+INDEX(bdinteg:si_sucursales idx_sucursal2)}  
			       count(*)
			  INTO iNumFilas
			  FROM bdinteg:si_sucursales suc
			 INNER JOIN bdinteg:si_ptf ptf ON ( ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo )
			  LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_col = ptf.cve_col )
			 WHERE sucursal BETWEEN v_sMin AND v_sMax
			   AND empresa = p_sEmpresa
			   AND tpo_sucursal = 'S'

			LET v_sValRetorno = '000000';

             IF (iNumFilas=0) THEN
            LET v_sValRetorno ='00017';
              END IF;	

			RETURN v_sValRetorno,iNumFilas WITH RESUME;
		END FOREACH;
	ELSE
		FOREACH
			SELECT count(*)
			  INTO iNumFilas
			  FROM bdinteg:si_sucursales suc
			 INNER JOIN bdinteg:si_ptf ptf ON ( ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo )
			  LEFT OUTER JOIN bdinteg:si_localidades loc ON (loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_col = ptf.cve_col )
			 WHERE suc.sucursal = p_sSucursal

			LET v_sValRetorno = '000000';

        IF (iNumFilas=0) THEN
            LET v_sValRetorno ='00017';
        END IF;	

			RETURN v_sValRetorno,iNumFilas WITH RESUME;
		END FOREACH;
	END IF;

  
	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de traer el total de registros que retorna el sp productivo sp_consultarcatsucursales2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), pNumSucursal CHAR(4), pNumZona CHAR(3), pNumRegional CHAR(3), pIdAsignado SMALLINT, pFechaIni DATE, pFechaFin DATE, pIdEstatus SMALLINT,pRecuperacion INTEGER, pRegistros INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(8) AS NumEmpleado, 	
			      CHAR(45) AS NomEmpleado, 	
			      CHAR(4) AS Sucursal, 	
			      CHAR(40) AS NomSucursal, 	
			      INTEGER AS IdFaltante, 	
			      CHAR(12) AS Auxiliar, 	
			      CHAR(3) AS NumZona,  	
			      CHAR(3) AS NumRegion, 	
			      INTEGER AS IdConcepto, 	
			      CHAR(80) AS DesConcepto, 	
			      INTEGER AS IdRecupera, 	
			      CHAR(80) AS DesRecupera, 	
			      INTEGER AS IdAsignado, 	
			      CHAR(80) AS DesAsignado, 	
			      INTEGER AS IdEstatus, 	
			      CHAR(80) AS DesEstatus, 	
			      MONEY(10,2) AS SaldoInicial,  	
			      MONEY(10,2) AS DescAcumulado, 	
			      MONEY(10,2) AS DescCalculado, 	
			      MONEY(10,2) AS SaldoActual,
			      CHAR(40) AS BancoCheque, 	
			      DATE AS FechaLiquida, 	
			      DATE AS FechaAsigna, 	
			      DATE AS FechaRegistro,
			      CHAR(8) AS UsuariAutoriza,
			      CHAR(26) AS Referencia,
			      MONEY(10,2) AS SaldoQueb
			      ;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNomEmpleado CHAR(45);
	DEFINE cSucursal CHAR(4);
	DEFINE cNomSucursal CHAR(40);
	DEFINE iIdFaltante SMALLINT;
	DEFINE cAuxiliar CHAR(12);
	DEFINE cNumZona CHAR(3); 
	DEFINE cNumRegion CHAR(3);
	DEFINE iIdConcepto SMALLINT;
	DEFINE cDesConcepto CHAR(80);
	DEFINE iIdRecupera SMALLINT;
	DEFINE cDesRecupera CHAR(80);
	DEFINE iIdAsignado SMALLINT;
	DEFINE cDesAsignado CHAR(80);
	DEFINE iIdEstatus SMALLINT;
	DEFINE cDesEstatus CHAR(80);
	DEFINE mSaldoInicial MONEY(10,2);
	DEFINE mDescAcumulado MONEY(10,2);
	DEFINE mDescCalculado MONEY(10,2);
	DEFINE mSaldoActual MONEY(10,2);
	DEFINE cBancoCheque CHAR(40);
	DEFINE dFechaLiquida DATE;
	DEFINE dFechaAsigna DATE;
	DEFINE dFechaRegistro DATE;
	DEFINE cUsuariAutoriza CHAR(8);
	DEFINE cReferencia CHAR(26);
	DEFINE mSaldoQueb MONEY(10,2);
    DEFINE iRecuperacion INTEGER;
	
	
	LET cCodRet = '00000';
	LET cNumEmpleado = '';
	LET cNomEmpleado ='';
	LET cSucursal ='';
	LET cNomSucursal='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iIdFaltante =0;
	LET cAuxiliar='';
	LET cNumZona = '';
	LET cNumRegion = '';
	LET iIdConcepto = 0;
	LET cDesConcepto ='';
	LET iIdRecupera=0;
	LET cDesRecupera = '';
	LET iIdAsignado = 0;
	LET cDesAsignado = '';
	LET iIdEstatus =0;
	LET cDesEstatus='';
	LET mSaldoInicial = 0;
	LET mDescAcumulado = 0;
	LET mDescCalculado = 0;
	LET mSaldoActual =0;
	LET cBancoCheque='';
	LET dFechaLiquida = DATE(1);
	LET dFechaAsigna = DATE(1);
	LET dFechaRegistro = DATE(1);
	LET cUsuariAutoriza = '';
	LET cReferencia = '';
	LET mSaldoQueb = 0;
	LET iRecuperacion=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		END IF;
		
        -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarconfaltante2(pNumEmpleado,pNumSucursal,pNumZona,pNumRegional,pIdAsignado,pFechaIni,pFechaFin,pIdEstatus,pRecuperacion,pRegistros)
		INTO cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb
		WITH RESUME;
		END FOREACH;
		
         IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mSaldoQueb;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO:OFI ',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarconfaltante2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarconfaltante_totales(pUsuario CHAR(8), pIdFuncion CHAR (10),p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_sNumZona CHAR(3), 
										p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, 
										p_dFechaFin DATE, p_iIdEstatus SMALLINT)

RETURNING 	CHAR(5) AS CodigoRetorno, 
			INTEGER as iNumFilas;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet       	CHAR(5);	
	DEFINE iNumFilas 		INTEGER;
	
	LET iSqlErr=0;
	LET v_sCodRet='00000';
	LET iNumFilas=0;
	
	
    --SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_consultarconfaltante_totales.out';
    --TRACE ON;
		
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, iNumFilas;
			END IF;
		END EXCEPTION;

		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET v_sCodRet = '00003';
			RETURN v_sCodRet, iNumFilas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_sCodRet;
		IF v_sCodRet <> '00000' THEN
			RETURN v_sCodRet, iNumFilas;
		END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_sCodRet;
		IF v_sCodRet <> '00000' THEN
			RETURN v_sCodRet, iNumFilas;
		END IF;
					
		
		IF NVL(p_sNumEmpleado,'') = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF NVL(p_sNumSucursal,'') = '' THEN 
			LET p_sNumSucursal = NULL;
		END IF
		
		IF NVL(p_sNumZona,'') = '' THEN 
			LET p_sNumZona = NULL;
		END IF
		
		IF NVL(p_sNumRegional,'') = '' THEN
			LET p_sNumRegional = NULL;
		END IF
		
		IF NVL(p_iIdAsignado,'') = '' THEN
			LET p_iIdAsignado = NULL;
		END IF 
		
		IF NVL(p_dFechaIni,'')= '' OR NVL(p_dFechaFin,'') = ''THEN
			LET p_dFechaIni = NULL;
			LET p_dFechaFin = NULL;
		END IF
		
		IF NVL(p_iIdEstatus,'') = '' THEN
			LET p_iIdEstatus = NULL;
		END IF 
		
		
			IF (p_iIdAsignado > 0 OR p_iIdAsignado IS NULL) and (p_iIdEstatus not in (4,7) or p_iIdEstatus IS NULL) THEN --Consulta para cuando el area sea especifica o todas las areas (no asignados,  o
		--area en especifico, o todas las areas sin restriciÃÂÃÂÃÂÃÂ³n)
			FOREACH
				SELECT count (*) as numfilas
				INTO iNumFilas
				FROM bdirech:rec_confaltante
				WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
				AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
				AND idasignado = NVL(p_iIdAsignado, idasignado) 
				AND fecharegistro BETWEEN NVL(p_dFechaIni, fecharegistro) AND NVL(p_dFechaFin,fecharegistro) 
				AND idestatus = NVL(p_iIdEstatus, idestatus)

						     IF (iNumFilas=0) THEN
            LET v_sCodRet ='01126';
        END IF;	
				RETURN v_sCodRet, iNumFilas WITH RESUME;
			END FOREACH
		ELIF p_iIdEstatus in (4,7) THEN --Consulta para cuando el area sea especifica o todas las areas (no asignados,  o area en especifico, o todas las areas sin restriciÃÂÃÂÃÂÃÂ³n)
		
					if (p_iIdAsignado > 0 OR p_iIdAsignado IS NULL) THEN
							FOREACH
								SELECT count (*) as numfilas
								INTO iNumFilas
								FROM bdirech:rec_confaltante RC
									INNER JOIN bdirech:rec_movquebrantos RM
									on RC.numempleado = RM.numempleado and RC.idfaltante=RM.idfaltante and 
									trim(RM.tipoperacion)=(Case when p_iIdEstatus=4 then 'SIF' ELSE 'FINALIZADO' end)--'SIF'
								WHERE RC.idfaltante <> 0 AND RC.numsucursal = NVL(p_sNumSucursal,RC.numsucursal) AND RC.numempleado = NVL(p_sNumEmpleado,RC.numempleado)
									AND RC.numzona = NVL(p_sNumZona,RC.numzona) AND RC.numregional = NVL(p_sNumRegional,RC.numregional) 
									AND RC.idasignado = NVL(p_iIdAsignado, RC.idasignado) 
									AND RM.fechareg BETWEEN NVL(p_dFechaIni, RM.fechareg) AND NVL(p_dFechaFin,RM.fechareg) 
									AND RC.idestatus = NVL(p_iIdEstatus, RC.idestatus)

                                             IF (iNumFilas=0) THEN
            LET v_sCodRet ='01126';
        END IF;	
			
								RETURN v_sCodRet, iNumFilas WITH RESUME;
							END FOREACH
							
					ELSE
						FOREACH
								SELECT count (*) as numfilas
								INTO iNumFilas
								FROM bdirech:rec_confaltante RC
									INNER JOIN bdirech:rec_movquebrantos RM
									on RC.numempleado = RM.numempleado and RC.idfaltante=RM.idfaltante and 
									trim(RM.tipoperacion)=(Case when p_iIdEstatus=4 then 'SIF' ELSE 'FINALIZADO' end) --'SIF'
								WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
									AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
									AND idasignado <> 1 /*(Sucursal)*/ AND fecharegistro BETWEEN NVL(p_dFechaIni,fecharegistro) AND NVL(p_dFechaFin,fecharegistro)
									AND idestatus = NVL(p_iIdEstatus, idestatus)
									--idasignado <> 1 son todas las areas que no sean sucursal.

                									     IF (iNumFilas=0) THEN
            LET v_sCodRet ='01126';
        END IF;					
											
								RETURN v_sCodRet, iNumFilas WITH RESUME;
							END FOREACH
					End if
		ELSE --Consulta solo para los faltantes que no esten asignados todas las areas que no sean sucursal		
			FOREACH
				SELECT count (*) as numfilas
				INTO iNumFilas
				FROM bdirech:rec_confaltante
				WHERE idfaltante <> 0 AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numempleado = NVL(p_sNumEmpleado,numempleado)
				AND numzona = NVL(p_sNumZona,numzona) AND numregional = NVL(p_sNumRegional,numregional) 
				AND idasignado <> 1 /*(Sucursal)*/ AND fecharegistro BETWEEN NVL(p_dFechaIni,fecharegistro) AND NVL(p_dFechaFin,fecharegistro)
				AND idestatus = NVL(p_iIdEstatus, idestatus)
				-- idasignado <> 1 son todas las areas que no sean sucursal.
                
              
                 IF (iNumFilas=0) THEN
            LET v_sCodRet ='01126';
        END IF;	
						
				RETURN v_sCodRet, iNumFilas WITH RESUME;
			END FOREACH
		END IF
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros del sp productivo spconsultarconfaltante2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultardeschistorico(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), pNumSucursal CHAR(4), pFechaDescuento DATE,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(8) AS numempleado, 
				  CHAR(4) AS numsucursal, 
				  CHAR(12) AS auxiliar, 
				  DATE AS fechadesc,
				  MONEY(10,0) AS sueldoquincena, 
				  MONEY (10,0) AS desccalculado, 
				  MONEY (10,0) AS descaplicado
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNumempleado CHAR(8);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cAuxiliar CHAR(12);
	DEFINE cNumsucursal CHAR(4);
	DEFINE dFechadesc DATE;
	DEFINE mSueldoquincena MONEY (10,0);
	DEFINE mDesccalculado MONEY (10,0);
	DEFINE mDescaplicado MONEY (10,0);

	
	
	LET cCodRet = '00000';
	LET cNumempleado = '';
	LET cAuxiliar = '';
	LET cNumsucursal='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechadesc= DATE(1);
	LET mSueldoquincena =0;
	LET mDesccalculado =0;
	LET mDescaplicado=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado;
		END EXCEPTION;
		
	--	SET DEBUG FILE TO '/tmp/mfinis/spconsultardeschistorico.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pFechaDescuento='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado;
		END IF;
	
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultardeschistorico2(pNumEmpleado,pNumSucursal,pFechaDescuento,pRegistros,pRecuperacion)
		INTO  cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado
		RETURN cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado
		WITH RESUME;
		END FOREACH;


		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumempleado, cNumsucursal,cAuxiliar,dFechadesc,mSueldoquincena,mDesccalculado,mDescaplicado;
		END IF;

		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultardeschistorico2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultardeschistorico_totales (pUsuario CHAR(8), pIdFuncion CHAR(10),p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_dFechaDescuento DATE)
RETURNING CHAR(5) AS retorno, INTEGER as numFilas;

DEFINE sql_err 				INTEGER;
DEFINE v_sCodRet			CHAR(5);
DEFINE iNumFilas			INTEGER;


LET iNumFilas=0;
	
LET v_sCodRet = '00000';
		
 
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET v_sCodRet = sql_err;
			RETURN v_sCodRet,iNumFilas;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_generarfechasquincenas_totales.out';
		--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET v_sCodRet = '00003';
			RETURN v_sCodRet,iNumFilas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_sCodRet;
		IF v_sCodRet <> '00000' THEN
			RETURN v_sCodRet,iNumFilas;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	IF NVL(p_dFechaDescuento, '') = '' THEN
		LET v_sCodRet = '00003';
		RETURN v_sCodRet,iNumFilas;
	END IF;
	
	IF p_sNumEmpleado = '' THEN
		LET p_sNumEmpleado = NULL;
	END IF
	
	IF p_sNumSucursal = '' THEN
		LET p_sNumSucursal = NULL;
	END IF
	
	FOREACH
		SELECT count(*) INTO 
		iNumFilas
		FROM bdirech:"informix".rec_deschistorico
		WHERE numempleado = NVL(p_sNumEmpleado, numempleado) AND numsucursal = NVL(p_sNumSucursal, numsucursal)
		AND fechadesc = p_dFechaDescuento
		
		
		     IF (iNumFilas=0) THEN
            LET v_sCodRet ='00017';
        END IF;	
		RETURN v_sCodRet,iNumFilas WITH RESUME;
	END FOREACH;
END;

END PROCEDURE

DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de filas que retorna el sp productivo spconsultardeschistorico2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultardescquincena(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pSucursal CHAR(4) , pFechaDescuento CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER )
		RETURNING CHAR(5) AS retorno,
				  CHAR(8) AS numempleado,
				  CHAR(4) AS numsucursal,
				  CHAR(12) AS auxiliar,
				  DATE AS fechadesc,
				  MONEY(10,0) AS sueldoquincena,
				  MONEY (10,0) AS desccalculado,
				  MONEY (10,0) AS descaplicado
			;

	DEFINE cCodRet CHAR(5);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cNumSucursal CHAR (4);
	DEFINE cAuxiliar CHAR(12);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaDesc DATE;
	DEFINE mSueldoQuincena MONEY(10,0);
	DEFINE mDescCalculado MONEY(10,0);
	DEFINE mDescAplicado MONEY(10,0);

	LET cCodRet = '00000';
	LET cNumEmpleado = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaDesc = DATE(1);
	LET cNumSucursal ='';
	LET cAuxiliar = '';
	LET mSueldoQuincena=0;
	LET mDescCalculado=0;
	LET mDescAplicado=0;



	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/spconsultardescquincena.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDescuento = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado;
		END IF;

			-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado;
		END IF;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultardescquincena2(pNumEmpleado,pSucursal,pFechaDescuento,pRegistros,pRecuperacion)
		INTO cCodRet,cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado
		RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado
		WITH RESUME;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumEmpleado,cNumSucursal,cAuxiliar,dFechaDesc,mSueldoQuincena,mDescCalculado,mDescAplicado;
		END IF;


	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultardescquincena2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultardescquincena_totales (pUsuario CHAR(8), pIdFuncion CHAR(10),p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_dFechaDescuento DATE)
RETURNING CHAR(5) AS retorno, INTEGER as numFilas;

DEFINE sql_err 				INTEGER;
DEFINE v_sCodRet			CHAR(5);
DEFINE iNumFilas			INTEGER;

		LET v_sCodRet = '00000';
		LET iNumFilas=0;
		LET sql_err=0;
 --****************************************************************
 --SET DEBUG FILE TO "/tmp/mfninis/sp_ofi_consultardescquincena_totales.out"
 --TRACE ON;                                            
 --****************************************************************

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet,iNumFilas;
			END IF;
		END EXCEPTION;
		
		
			
		IF NVL(p_dFechaDescuento, '') = '' THEN
			LET v_sCodRet = '00003';
			RETURN v_sCodRet,iNumFilas;
		END IF;
		
		IF p_sNumEmpleado = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF p_sNumSucursal = '' THEN
			LET p_sNumSucursal = NULL;
		END IF
		
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_sCodRet;
		IF v_sCodRet <> '00000' THEN
			RETURN v_sCodRet,iNumFilas;	
		END IF;
		
		
		FOREACH
		    SELECT count(*) INTO iNumFilas
			FROM bdirech:rec_descquincena 
			WHERE numempleado = NVL(p_sNumEmpleado, numempleado) AND numsucursal = NVL(p_sNumSucursal, numsucursal)
			AND fechadesc = p_dFechaDescuento

              
			
			     IF (iNumFilas=0) THEN
            LET v_sCodRet ='01265';
           
        END IF;	
			
			RETURN v_sCodRet,iNumFilas WITH RESUME;
		END FOREACH;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de filas que retorna el sp productivo spconsultardescquincena2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarempconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(8) AS NumEmpleado;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumEmpleado CHAR(8);
    DEFINE iNoRegistros INTEGER;
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNumEmpleado = '';
	LET iNoRegistros =0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumEmpleado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarempconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros ='' OR pRecuperacion=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumEmpleado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumEmpleado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdirech:"informix".spconsultarempconfaltante2(pRegistros,pRecuperacion)
			INTO  cCodRet,cNumEmpleado
			LET iNoRegistros = iNoRegistros+1;
			RETURN cCodRet,cNumEmpleado WITH RESUME;
		END FOREACH;

        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '01273';
			RETURN cCodRet,cNumEmpleado;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumEmpleado;
		END IF;   
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen ',
'FECHA: 17/08/2021',
'MODULO: OFI',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarempconfaltante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarempleado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS empresa,				
				  CHAR(45) AS nombre,
				  CHAR(4) AS sucursal,
				  CHAR (3) AS puesto,
				  CHAR(20) AS nombramiento,
				  CHAR (10) AS asistente,
				  CHAR (40) AS password
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cNombre CHAR(45);
	DEFINE cSucursal CHAR(4);
	DEFINE cPuesto CHAR(3);
	DEFINE cNombramiento CHAR(20);
	DEFINE cAsistente CHAR(10);
	DEFINE cPassword CHAR(40);
    DEFINE iContador INTEGER;
	
	
	LET cCodRet = '00000';
	LET cEmpresa = '0';
	LET cNombre = '';
	LET cSucursal ='';
	LET cPuesto ='';
	LET cNombramiento='';
	LET cAsistente='';
	LET cPassword ='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNumEmpleado = '0';
    LET iContador =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_y.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultarempleado(pNumEmpleado)
		INTO cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword
        LET iContador = iContador +1;
		RETURN cCodRet, cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword WITH RESUME;
		END FOREACH;
		
        IF iContador = 0 THEN
			LET cCodRet = '01264';
			RETURN cCodRet, cEmpresa,cNombre,cSucursal,cPuesto,cNombramiento,cAsistente,cPassword;
		END IF;


	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_consultarempleado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarerroresfaltantesarch(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20),pRecuperacion INTEGER, pRegistros INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(4) AS NumSucursal, 
				  CHAR(8) AS NumEmpleado, 
				  MONEY(10,2) AS SaldoInicial, 
				  DATE AS FechaRegistro, 
				  CHAR(1) AS v_sNumSucValida,
				  CHAR(1) AS v_sNumEmpValido, 
				  CHAR(1) AS v_sSaldoIniValido, 
				  CHAR(1) AS v_sFechaRegValida, 
				  CHAR(1) AS v_sNumAuxValido, 
				  CHAR(1) AS v_sRegistroValido
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNumSucursal CHAR(4);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumEmpleado CHAR(8);
	DEFINE mSaldoInicial MONEY(10,0);
	DEFINE dFechaRegistro DATE;
	DEFINE cV_sNumSucValida CHAR(1);
	DEFINE cV_sNumEmpValido CHAR(1);
	DEFINE cV_sSaldoIniValido CHAR(1);
	DEFINE cV_sFechaRegValida CHAR(1);
	DEFINE cV_sNumAuxValido CHAR(1);
	DEFINE cV_sRegistroValido CHAR(1);
	
	LET cCodRet = '00000';
	LET cNumSucursal = '0';
	LET mSaldoInicial = 0;
	LET dFechaRegistro =DATE(1);
	LET cV_sNumSucValida ='';
	LET cV_sNumEmpValido='';
	LET cV_sSaldoIniValido='';
	LET cV_sFechaRegValida ='';
	LET cV_sNumAuxValido ='';
	LET cV_sRegistroValido ='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNumEmpleado = '0';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarerroresfaltantesarch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarerroresfaltantesarch2(pNombreArchivo,pRegistros,pRecuperacion)
		INTO cCodRet,cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido
		RETURN cCodRet, cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido
		WITH RESUME;
		END FOREACH;
		
		
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSucursal,cNumEmpleado,mSaldoInicial,dFechaRegistro,cV_sNumSucValida,cV_sNumEmpValido,cV_sSaldoIniValido,cV_sFechaRegValida,cV_sNumAuxValido,cV_sRegistroValido;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarerroresfaltantesarch2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarerroresfaltantesarch_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20))
		RETURNING CHAR(5) AS codret, INTEGER AS numRegistros
				  
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE inumRegistros INTEGER;
	
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	LET cCodRet = '00000';
	LET inumRegistros=0;
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, inumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarerroresfaltantesarch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, inumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		RETURN cCodRet, inumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
			SELECT count (*)
			INTO inumRegistros
			FROM bdirech:rec_faltantesarch
			WHERE (numsucvalida = 0 OR numempvalido = 0 OR saldoinivalido = 0 OR fecharegvalida = 0 OR numauxvalido = 0 OR registrovalido = 0)
			AND nombrearchivo = pNombreArchivo;

			IF inumRegistros = 0 THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, inumRegistros;
			END IF;
		RETURN cCodRet, inumRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros que retorna el sp productivo spconsultarerroresfaltantesarch2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarfaltantesexcluidos(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8), pNumSucursal CHAR(4), pNumZona CHAR(3), pNumRegional CHAR(3), pIdAsignado SMALLINT, pFechaIni DATE, pFechaFin DATE,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado, CHAR(4) AS Sucursal, CHAR(40) AS NomSucursal, 
SMALLINT AS IdFaltante, CHAR(12) AS Auxiliar, CHAR(3) AS NumZona, CHAR(3) AS NumRegion, SMALLINT AS IdConcepto, CHAR(80) AS DesConcepto,
SMALLINT AS IdRecupera, CHAR(80) AS DesRecupera, SMALLINT AS IdAsignado, CHAR(80) AS DesAsignado, SMALLINT AS IdEstatus, CHAR(80) AS DesEstatus,
MONEY(10,2) AS SaldoInicial, MONEY(10,2) AS DescAcumulado, MONEY(10,2) AS DescCalculado, MONEY(10,2) AS SaldoActual, CHAR(40) AS BancoCheque,	
DATE AS FechaLiquida, DATE AS FechaAsigna, DATE AS FechaRegistro, CHAR(8) AS UsuariAutoriza, CHAR(26) AS Referencia, MONEY(10,2) AS DescQuincenaFijo
			      ;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNomEmpleado CHAR(45);
	DEFINE cSucursal CHAR(4);
	DEFINE cNomSucursal CHAR(40);
	DEFINE iIdFaltante SMALLINT;
	DEFINE cAuxiliar CHAR(12);
	DEFINE cNumZona CHAR(3); 
	DEFINE cNumRegion CHAR(3);
	DEFINE iIdConcepto SMALLINT;
	DEFINE cDesConcepto CHAR(80);
	DEFINE iIdRecupera SMALLINT;
	DEFINE cDesRecupera CHAR(80);
	DEFINE iIdAsignado SMALLINT;
	DEFINE cDesAsignado CHAR(80);
	DEFINE iIdEstatus SMALLINT;
	DEFINE cDesEstatus CHAR(80);
	DEFINE mSaldoInicial MONEY(10,0);
	DEFINE mDescAcumulado MONEY(10,0);
	DEFINE mDescCalculado MONEY(10,0);
	DEFINE mSaldoActual MONEY(10,0);
	DEFINE cBancoCheque CHAR(40);
	DEFINE dFechaLiquida DATE;
	DEFINE dFechaAsigna DATE;
	DEFINE dFechaRegistro DATE;
	DEFINE cUsuariAutoriza CHAR(8);
	DEFINE cReferencia CHAR(26);
	DEFINE mDescQuincenaFijo MONEY(10,0);
    DEFINE iRecuperacion INTEGER;
	
	
	LET cCodRet = '00000';
	LET cNumEmpleado = '';
	LET cNomEmpleado ='';
	LET cSucursal ='';
	LET cNomSucursal='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iIdFaltante =0;
	LET cAuxiliar='';
	LET cNumZona = '';
	LET cNumRegion = '';
	LET iIdConcepto = 0;
	LET cDesConcepto ='';
	LET iIdRecupera=0;
	LET cDesRecupera = '';
	LET iIdAsignado = 0;
	LET cDesAsignado = '';
	LET iIdEstatus =0;
	LET cDesEstatus='';
	LET mSaldoInicial = 0;
	LET mDescAcumulado = 0;
	LET mDescCalculado = 0;
	LET mSaldoActual =0;
	LET cBancoCheque='';
	LET dFechaLiquida = DATE(1);
	LET dFechaAsigna = DATE(1);
	LET dFechaRegistro = DATE(1);
	LET cUsuariAutoriza = '';
	LET cReferencia = '';
	LET mDescQuincenaFijo = 0;
	LET iRecuperacion =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarfaltantesexcluidos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''   THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		END IF;

        -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarfaltantesexcluidos2(pNumEmpleado,pNumSucursal,pNumZona,pNumRegional,pIdAsignado,pFechaIni,pFechaFin,pRegistros,pRecuperacion)
		INTO cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo
		WITH RESUME;
		END FOREACH;
		
				
       IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,cAuxiliar,cNumZona,cNumRegion,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdEstatus,cDesEstatus,mSaldoInicial,mDescAcumulado,mDescCalculado,mSaldoActual,cBancoCheque,dFechaLiquida,dFechaAsigna,dFechaRegistro,cUsuariAutoriza,cReferencia,mDescQuincenaFijo;
		END IF;	
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarfaltantesexcluidos2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarfaltantesexcluidos_totales (pUsuario CHAR(8), pIdFuncion CHAR(10),p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_sNumZona CHAR(3), 
p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, p_dFechaFin DATE)

RETURNING CHAR(5) AS CodigoRetorno, INTEGER as numFilas;

	DEFINE cCodRet CHAR(5);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE v_sCodRet       	CHAR(5);	
	DEFINE iNumFilas 	INTEGER;
	
	LET v_sCodRet = '00000';
	LET iNumFilas=0;

	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_ofi_consultarfaltantesexcluidos_totales.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,iNumFilas;
			END IF;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = ''   THEN
			LET cCodRet = '00003';
			RETURN v_sCodRet,iNumFilas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN v_sCodRet,iNumFilas;
		END IF;
		
		
		IF NVL(p_sNumEmpleado,'') = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF
		
		IF NVL(p_sNumSucursal,'') = '' THEN 
			LET p_sNumSucursal = NULL;
		END IF
		
		IF NVL(p_sNumZona,'') = '' THEN 
			LET p_sNumZona = NULL;
		END IF
		
		IF NVL(p_sNumRegional,'') = '' THEN
			LET p_sNumRegional = NULL;
		END IF
		
		IF NVL(p_iIdAsignado,'') = '' THEN
			LET p_iIdAsignado = NULL;
		END IF 
		
		IF NVL(p_dFechaIni,'')= '' OR NVL(p_dFechaFin,'') = ''THEN
			LET p_dFechaIni = NULL;
			LET p_dFechaFin = NULL;
		END IF
				
		IF p_iIdAsignado > 0 OR p_iIdAsignado IS NULL THEN 
		--Consulta para cuando el area sea especifica o todas las areas (no asignados, ÃÂ³ area en especifico, o todas las areas sin restriciÃÂ³n)
			FOREACH
				SELECT count(*) 
				INTO iNumFilas
				FROM bdirech:"informix".rec_confaltante
				WHERE numempleado = NVL(p_sNumEmpleado,numempleado) AND idfaltante <> 0 AND idconcepto <> '3' /*No robo ÃÂ³ asalto*/ 
				AND idasignado = NVL(p_iIdAsignado, idasignado) AND idestatus <> '6' /*No reversados*/
				AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numzona = NVL(p_sNumZona,numzona) 
				AND numregional = NVL(p_sNumRegional,numregional) AND fecharegistro BETWEEN NVL(p_dFechaIni, fecharegistro) 
				AND NVL(p_dFechaFin,fecharegistro) 
				
				 IF (iNumFilas=0) THEN
                  LET v_sCodRet ='01030';
                 END IF;	
				RETURN v_sCodRet,iNumFilas WITH RESUME;
			END FOREACH
			
		ELSE --Consulta solo para los faltantes que no esten asignados todas las areas que no sean sucursal		
			FOREACH
				SELECT count(*) 
				INTO iNumFilas
				FROM bdirech:"informix".rec_confaltante
				WHERE numempleado = NVL(p_sNumEmpleado,numempleado) AND idfaltante <> 0 AND idconcepto <> '3' /*No robo ÃÂ³ asalto*/ 
				AND idasignado <> 1 /*(Sucursal)*/ AND idestatus <> '6' /*No reversados*/
				AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numzona = NVL(p_sNumZona,numzona) 
				AND numregional = NVL(p_sNumRegional,numregional) AND fecharegistro BETWEEN NVL(p_dFechaIni,fecharegistro) 
				AND NVL(p_dFechaFin,fecharegistro)								
				-- idasignado <> 1 son todas las areas que no sean sucursal.

                 IF (iNumFilas=0) THEN
                  LET v_sCodRet ='01030';
                 END IF;	
                
				RETURN v_sCodRet,iNumFilas WITH RESUME;
			END FOREACH
		END IF
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros que retorna el sp productivo spconsultarfaltantesexcluidos2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarfaltantesreversoasig(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4),
							pNumZona CHAR(3), pNumRegional CHAR(3), pIdAsignado SMALLINT, pFechaIni DATE, pFechaFin DATE,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS retorno, 
				  CHAR(8) AS NumEmpleado, 
				  CHAR(45) AS NomEmpleado, 
				  CHAR(4) AS Sucursal, 
				  CHAR(40) AS NomSucursal, 
				  SMALLINT AS IdFaltante, 
				  SMALLINT AS IdConcepto, 
				  CHAR(80) AS DesConcepto, 
				  SMALLINT AS IdRecupera, 
				  CHAR(80) AS DesRecupera, 
				  SMALLINT AS IdAsignado, 
				  CHAR(80) AS DesAsignado, 
			      SMALLINT AS IdAsignadoAnt, 
				  SMALLINT AS IdEstatus, 
				  CHAR(80) AS DesEstatus, 
				  MONEY(10,2) AS SaldoActual,
				  DATE AS FechaAsigna, 
				  DATE AS FechaRegistro

			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cNomEmpleado CHAR (45);
	DEFINE cSucursal CHAR(12);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNomSucursal CHAR(40);
	DEFINE iIdFaltante SMALLINT;
	DEFINE iIdConcepto SMALLINT;
	DEFINE cDesConcepto CHAR(80);
	DEFINE iIdRecupera SMALLINT;
	DEFINE cDesRecupera CHAR(80);
	DEFINE iIdAsignado SMALLINT;
	DEFINE cDesAsignado CHAR(80);
	DEFINE iIdAsignadoAnt SMALLINT;
	DEFINE iIdEstatus SMALLINT;
	DEFINE cDesEstatus CHAR(80);
	DEFINE mSaldoActual MONEY(10,2);
	DEFINE dFechaAsigna  DATE;
	DEFINE dFechaRegistro  DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cNumEmpleado = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNomEmpleado ='';
	LET cSucursal = '';
	LET cNomSucursal='';
	LET iIdFaltante=0;
	LET iIdConcepto=0;
	LET cDesConcepto='';
	LET iIdRecupera=0;
	LET cDesRecupera='';
	LET iIdAsignado=0;
	LET cDesAsignado='';
	LET iIdAsignadoAnt=0;
	LET iIdEstatus=0;
	LET cDesEstatus='';
	LET mSaldoActual=0;
	LET dFechaAsigna=DATE(1);
	LET dFechaRegistro=DATE(1);
    LET iRecuperacion =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarfaltantesreversoasig.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		END IF;
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarfaltantesreversoasig2(pNumEmpleado,pNumSucursal,pNumZona,pNumRegional,pIdAsignado,pFechaIni,pFechaFin,pRegistros,pRecuperacion)
		INTO  cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro
		WITH RESUME;
		END FOREACH;
		
      IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumEmpleado,cNomEmpleado,cSucursal,cNomSucursal,iIdFaltante,iIdConcepto,cDesConcepto,iIdRecupera,cDesRecupera,iIdAsignado,cDesAsignado,iIdAsignadoAnt,iIdEstatus,cDesEstatus,mSaldoActual,dFechaAsigna,dFechaRegistro;
		END IF;	
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarfaltantesreversoasig2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarfaltantesreversoasig_totales (pUsuario CHAR(8), pIdFuncion CHAR(10),p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4),
							p_sNumZona CHAR(3), p_sNumRegional CHAR(3), p_iIdAsignado SMALLINT, p_dFechaIni DATE, p_dFechaFin DATE)

	RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS numFilas;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sCodRet			CHAR(5);
	DEFINE inumFilas 			INTEGER;

	LET inumFilas=0;
	
		LET v_sCodRet = '00000';


    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,inumFilas;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarfaltantesreversoasig.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET v_sCodRet = '00003';
			RETURN v_sCodRet,inumFilas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_sCodRet;
		IF v_sCodRet <> '00000' THEN
			RETURN v_sCodRet,inumFilas;
		END IF;
		
		

		IF NVL(p_sNumEmpleado,'') = '' THEN
			LET p_sNumEmpleado = NULL;
		END IF

		IF NVL(p_sNumSucursal,'') = '' THEN 
			LET p_sNumSucursal = NULL;
		END IF

		IF NVL(p_sNumZona,'') = '' THEN 
			LET p_sNumZona = NULL;
		END IF

		IF NVL(p_sNumRegional,'') = '' THEN
			LET p_sNumRegional = NULL;
		END IF

		IF NVL(p_iIdAsignado,'') = '' THEN
			LET p_iIdAsignado = NULL;
		END IF 

		IF NVL(p_dFechaIni,'')= '' OR NVL(p_dFechaFin,'') = ''THEN
			LET p_dFechaIni = NULL;
			LET p_dFechaFin = NULL;
		END IF

		FOREACH
			SELECT COUNT(*)  into inumFilas FROM(			
		   SELECT numempleado, numsucursal, idfaltante, idconcepto, idrecupera, idasignado, idasignadoant, idestatus, saldoactual, fechaasigna, fecharegistro
			FROM bdirech:"informix".rec_confaltante
			WHERE numempleado = NVL(p_sNumEmpleado,numempleado) AND idfaltante <> 0 AND idconcepto <> '3' /*No robo ÃÂÃÂ³ asalto*/ 
			AND idasignado IN(2, 3) /* Recursos Humanos y Operaciones*/
			AND idasignado = NVL(p_iIdAsignado, idasignado)
			AND idrecupera IN(1, 2, 6) /*Sucursal, Nomina y Nomina Fijo*/
			AND idestatus IN(1, 3) /*Pendiente de Aplicar y Baja*/
			AND saldoinicial = saldoactual AND saldoactual > 1
			AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numzona = NVL(p_sNumZona,numzona)
			AND numregional = NVL(p_sNumRegional,numregional)
			AND fecharegistro BETWEEN NVL(p_dFechaIni, fecharegistro) AND NVL(p_dFechaFin,fecharegistro)
			Union
			SELECT numempleado, numsucursal, idfaltante, idconcepto, idrecupera, idasignado, idasignadoant, idestatus, saldoactual, fechaasigna, fecharegistro			
			FROM bdirech:"informix".rec_confaltante
			WHERE numempleado = NVL(p_sNumEmpleado,numempleado) AND idfaltante <> 0 AND idconcepto <> '3' /*No robo ÃÂÃÂ³ asalto*/ 			
			AND idasignado = 6
			AND idestatus IN(4) /*quebranto*/			
			AND numsucursal = NVL(p_sNumSucursal,numsucursal) AND numzona = NVL(p_sNumZona,numzona)
			AND numregional = NVL(p_sNumRegional,numregional)
			AND fecharegistro BETWEEN NVL(p_dFechaIni, fecharegistro) AND NVL(p_dFechaFin,fecharegistro)			
			ORDER BY numsucursal, numempleado
				)  

			RETURN v_sCodRet,inumFilas WITH RESUME;
		END FOREACH
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros que retorna el sp productivo spconsultarfaltantesreversoasig2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSecuencia SMALLINT)
		RETURNING CHAR(5) AS codret,
				 CHAR(60) AS descripcion, 
				 CHAR(20) AS valor
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cDescripcion CHAR(60);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cValor CHAR(20);

	
	
	LET cCodRet = '00000';
	LET cDescripcion = '';
	LET cValor = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdSecuencia ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion, cValor;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(pIdSecuencia)
		INTO cCodRet, cDescripcion, cValor;
        
        IF (pIdSecuencia =1) THEN
        LET cValor = SUBSTR(cValor,1,2)||'/'||SUBSTR(cValor,4,2)||'/'|| SUBSTR(cValor,7,4);
        END IF;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cDescripcion, cValor;
		END IF;

		RETURN cCodRet, cDescripcion, cValor;

	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarparam',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_consultarprocesos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE ,pIdproceso SMALLINT)
		RETURNING CHAR(5) AS codret,
				  DATE	   AS FechaProceso,
				  SMALLINT AS IdProceso,
			  	  CHAR(40) AS DescripcionProceso,
				  CHAR(1)  AS Estatus
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE cDescripcionProceso CHAR(40);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIdProceso SMALLINT;
	DEFINE dFechaProceso DATE;
	DEFINE cEstatus CHAR(1);
    DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET cDescripcionProceso = '';
	LET iIdProceso = 0;
	LET dFechaProceso=DATE(1);
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEstatus='';
    LET iRecuperacion =0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spconsultarprocesos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso =''  OR pIdproceso='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spconsultarprocesos(pFechaProceso,pIdproceso)
		INTO cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus
        LET iRecuperacion = iRecuperacion+1;
		RETURN cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus
		WITH RESUME;
		END FOREACH;
 
        IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
            RETURN cCodRet, dFechaProceso, iIdProceso,cDescripcionProceso,cEstatus;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spconsultarprocesos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_eliminaerrores(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarrespaldos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".speliminaerrores()
		INTO  cCodRet;

        
       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;

		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo speliminaerrores',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarfechasquincenas(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  DATE AS fechaquincena
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaQuincena DATE;
    DEFINE iRecuperacion INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaQuincena=DATE(1);
	LET iRecuperacion =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaQuincena;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_generarfechasquincenas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaQuincena;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaQuincena;
		END IF;
		
			-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaQuincena;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spgenerarfechasquincenas2(pRegistros,pRecuperacion)
		INTO  cCodRet,dFechaQuincena
        LET iRecuperacion = iRecuperacion + 1;
		RETURN cCodRet,dFechaQuincena WITH RESUME;
        END FOREACH;

       LET pRegistros = 0;
        IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01268'; 
			RETURN cCodRet,dFechaQuincena;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFechaQuincena;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros que retorna el sp productivo spgenerarfechasquincenas2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarfechasquincenas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) AS CodigoRetorno,  INTEGER as numFilas;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumFilas INTEGER;


	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumFilas = 0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumFilas;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_generarfechasquincenas_totales.out';
		--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumFilas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumFilas;
		END IF;
		
		
		
	FOREACH
		select first 1 (SELECT 
		count(valor)  FROM bdirech:"informix".rec_param WHERE secuencia = 1)
		+
		(SELECT 
		count(DISTINCT(fechadesc)) FROM bdirech:"informix".rec_deschistorico )  as P into iNumFilas from bdirech:"informix".rec_param
		RETURN cCodRet, iNumFilas WITH RESUME;
	END FOREACH;
	
	
	
END
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el total de registros que retorna el sp productivo spgenerarfechasquincenas2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizaasignacion(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaActual DATE, pNumEmpleado CHAR(8), p_Usuario CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS NumeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumeroPoliza INTEGER;
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizaasignacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual ='' OR pNumEmpleado = '' OR p_Usuario = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizaasignacion2(pFechaActual,pNumEmpleado,p_Usuario)
		INTO  cCodRet,iNumeroPoliza;
  
        
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
		END IF;

        IF cCodRet ='00002' THEN
   			LET cCodRet ='01247';
		END IF;

        IF cCodRet ='00003' THEN
			LET cCodRet ='01248';
		END IF;

        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';
		END IF;

		RETURN cCodRet,iNumeroPoliza;

		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizaasignacion2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizaliquidacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaActual DATE, pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS numeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE inumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET inumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, inumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizaliquidacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual =''  OR pNumEmpleado='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizaliquidacion(pFechaActual,pNumEmpleado,pUsuario)
		INTO  cCodRet, inumeroPoliza;
        
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, inumeroPoliza;
		END IF;

          IF cCodRet ='000' THEN
			LET cCodRet ='00000'; 		END IF;
       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01247';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01272';         END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';         END IF;
		RETURN cCodRet, inumeroPoliza;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizaliquidacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizareasignacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaActual CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER as numeroPoliza
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iNumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaActual CHAR(10);
	
	LET cCodRet = '00000';
	LET iNumeroPoliza = 1;
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaActual = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_generarpolizareasignacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizareasignacion(pFechaActual,pUsuario)
		INTO cCodRet, iNumeroPoliza

       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
			RETURN cCodRet, iNumeroPoliza;
		END IF;
	
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
       IF cCodRet ='00002' THEN
			LET cCodRet ='01247';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01248';         END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';         END IF;

    

	RETURN cCodRet, iNumeroPoliza
		WITH RESUME;
		END FOREACH;
		
        
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizareasignacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizareversoasig(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaActual DATE, p_Usuario CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS numeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE inumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET inumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, inumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizareversoasig.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual =''  OR p_Usuario='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizareversoasig(pFechaActual,p_Usuario)
		INTO  cCodRet, inumeroPoliza;
        
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, inumeroPoliza;
		END IF;


        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01271';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01248'; 		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';         END IF;
		RETURN cCodRet, inumeroPoliza;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizareversoasig',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizareversoasig_quebranto(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaActual DATE, p_Usuario CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS numeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE inumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET inumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, inumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizareversoasig_quebranto.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual =''  OR p_Usuario='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, inumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizareversoasig_quebranto(pFechaActual,p_Usuario)
		INTO  cCodRet, inumeroPoliza;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, inumeroPoliza;
		END IF;


        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
		END IF;

        IF cCodRet ='00002' THEN
   			LET cCodRet ='01247';
		END IF;

        IF cCodRet ='00003' THEN
			LET cCodRet ='01248';
		END IF;

        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';
		END IF;

		RETURN cCodRet, inumeroPoliza;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizareversoasig_quebranto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarrespaldos(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaQuincena DATE)
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarrespaldos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena =''   THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".spgenerarrespaldos(pFechaQuincena)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01253';         END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01254'; 		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01255';         END IF;
        IF cCodRet ='00005' THEN
			LET cCodRet ='01251'; 		END IF;
        IF cCodRet ='00006' THEN
			LET cCodRet ='01252';         END IF;
 
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarrespaldos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_genrepdepositoscuentacpp(pUsuario CHAR(8), pIdFuncion CHAR(10),pfechaDe CHAR(10), pfechaHasta CHAR(10),pRutaDescarga CHAR(50))
    RETURNING CHAR(5) AS codret,
	CHAR(47) AS reporte_xls;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumsucursal         CHAR(4);
    DEFINE cNomsucursal         CHAR(40);
    DEFINE cNumempleado         CHAR(8);
    DEFINE cNomempleado         CHAR(45);
    DEFINE cDesconcepto         CHAR(80);
    DEFINE iDfaltante         SMALLINT;
    DEFINE dFecharegistro       DATE; 
    DEFINE mSaldoinicial       MONEY(10,2); 
    DEFINE mDescquincenafijo   MONEY(10,2); 
    DEFINE mMontoabono         MONEY(10,2);
    DEFINE mSaldoactual         MONEY(10,2);
    DEFINE dFechaasigna         DATE; 
    DEFINE cDesasignado         CHAR(80);
    DEFINE iDestatus           SMALLINT; 
    DEFINE iMovimientoabono   SMALLINT; 
    DEFINE cTpomovimiento     CHAR(1);
    DEFINE dFechaasignadeposito DATE;
    DEFINE dFechaliquida       DATE;
    DEFINE cAuxiliar           CHAR(12);
    DEFINE cReferencia         CHAR(26);
    DEFINE cUsuarioautoriza     CHAR(8);	
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
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dHoy DATE;
	DEFINE cStr7 CHAR(50);
	DEFINE cStr9 CHAR(50);
	DEFINE cIdPlantilla CHAR(5);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cNumsucursal='';
    LET cNomsucursal='';
    LET cNumempleado='';
    LET cNomempleado ='';
    LET cDesconcepto ='';
    LET iDfaltante =0;
    LET dFecharegistro  =     DATE(1); 
    LET mSaldoinicial    =0;
    LET mDescquincenafijo  =0;
    LET mMontoabono  =0;
    LET mSaldoactual  =0;
    LET dFechaasigna  =  DATE(1);
    LET cDesasignado  ='';
    LET iDestatus   =0;
    LET iMovimientoabono =0;
    LET cTpomovimiento ='';
    LET dFechaasignadeposito =DATE(1);
    LET dFechaliquida =  DATE(1);
    LET cAuxiliar ='';
    LET cReferencia  ='';
    LET cUsuarioautoriza  ='';
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
	LET dFechaHoy = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET cIdPlantilla = '';
	LET cNombreReporteHist = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF ven_transacc = 1 THEN
				ROLLBACK ;		
			END IF;
			RETURN cCodRet,cNombreRepXls;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
	    --SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_genrepdepositoscuentacpp.out';
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
		
		BEGIN WORK;
			
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		LET cNombreRepXls = 'DepositosCuentaBanCoppel_'||TO_CHAR(CURRENT, '%d%m%Y')||'_'||(TO_CHAR(CURRENT, '%H%M%S'))||'.xls';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  
		
			LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'C.C. SUC','NOMBRE DE SUCURSAL','NO. DE EMPLEADO','NOMBRE DE EMPLEADO','CONCEPTO','ID FALTANTE',";
		LET cCmd1 =""||TRIM(cCmd1)||"'FECHA DE REGISTRO','IMPORTE DEL FALTANTE O DAÃO','DESCUENTO QUINCENAL FIJO','SALDO','FECHA ASIGNACION',";
		LET cCmd1 =""||TRIM(cCmd1)||"'DESASIGNADO','ESTATUS'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ''''||numsucursal::CHAR(4),nomsucursal::CHAR(40),''''||numempleado::CHAR(8),nomempleado::CHAR(45),desconcepto::CHAR(80),idfaltante::CHAR(6),TO_CHAR(fecharegistro, '%d/%m/%Y'),saldoinicial::CHAR(12),descquincenafijo::CHAR(12),";
		LET cCmd1 =""||TRIM(cCmd1)||" saldoactual::CHAR(12),TO_CHAR(fechaasigna, '%d/%m/%Y'),desasignado::CHAR(80),idestatus::CHAR(6)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:rec_depfaltantes";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE fechaasignadeposito >= '"|| pfechaDe ||"' and fechaasignadeposito <= '"|| pfechaHasta ||"'))";
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃÂÃÂ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
		
		LET ven_transacc = 0;
			
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
	
		RETURN cCodRet,cNombreRepXls;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: OFI ',
'FUNCIONALIDAD: REPORTE DE CONSULTA DEPOSITOS A CUENTA BANCOPPEL',
'DESCRIPCION: SPL encargado de generar el reporte en excel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_genrepdescuentohistorico(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pSucursal CHAR(4) , pFechaDescuento CHAR(10),pRutaDescarga CHAR(50))
    RETURNING CHAR(5) AS codret,
	CHAR(47) AS reporte_xls;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumsucursal         CHAR(4);
    DEFINE cNomsucursal         CHAR(40);
    DEFINE cNumempleado         CHAR(8);
    DEFINE cNomempleado         CHAR(45);
    DEFINE cDesconcepto         CHAR(80);
    DEFINE iDfaltante         SMALLINT;
    DEFINE dFecharegistro       DATE; 
    DEFINE mSaldoinicial       MONEY(10,2); 
    DEFINE mDescquincenafijo   MONEY(10,2); 
    DEFINE mMontoabono         MONEY(10,2);
    DEFINE mSaldoactual         MONEY(10,2);
    DEFINE dFechaasigna         DATE; 
    DEFINE cDesasignado         CHAR(80);
    DEFINE iDestatus           SMALLINT; 
    DEFINE iMovimientoabono   SMALLINT; 
    DEFINE cTpomovimiento     CHAR(1);
    DEFINE dFechaasignadeposito DATE;
    DEFINE dFechaliquida       DATE;
    DEFINE cAuxiliar           CHAR(12);
    DEFINE cReferencia         CHAR(26);
    DEFINE cUsuarioautoriza     CHAR(8);	
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
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dHoy DATE;
	DEFINE cStr7 CHAR(50);
	DEFINE cStr9 CHAR(50);
	DEFINE cIdPlantilla CHAR(5);
	DEFINE cNombreReporteHist CHAR(100);
    DEFINE cFechaAux CHAR(10);
	--DEFINE ven_transacc SMALLINT;
	--DEFINE bInTransaction BOOLEAN;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cNumsucursal='';
    LET cNomsucursal='';
    LET cNumempleado='';
    LET cNomempleado ='';
    LET cDesconcepto ='';
    LET iDfaltante =0;
    LET dFecharegistro  =     DATE(1); 
    LET mSaldoinicial    =0;
    LET mDescquincenafijo  =0;
    LET mMontoabono  =0;
    LET mSaldoactual  =0;
    LET dFechaasigna  =  DATE(1);
    LET cDesasignado  ='';
    LET iDestatus   =0;
    LET iMovimientoabono =0;
    LET cTpomovimiento ='';
    LET dFechaasignadeposito =DATE(1);
    LET dFechaliquida =  DATE(1);
    LET cAuxiliar ='';
    LET cReferencia  ='';
    LET cUsuarioautoriza  ='';
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
	LET dFechaHoy = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET cIdPlantilla = '';
	LET cNombreReporteHist = '';
    --LET cFechaAux = SUBSTR(pFechaDescuento,7,5)||'/'||SUBSTR(pFechaDescuento,1,2)||'/'||SUBSTR(pFechaDescuento,4,2);
    LET cFechaAux = SUBSTR(pFechaDescuento,4,2)||'/'||SUBSTR(pFechaDescuento,1,2)||'/'||SUBSTR(pFechaDescuento,7,5);
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
		
	   -- SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_genrepdescuentohistorico.out';
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

        IF TRIM(pNumEmpleado)='' THEN
        LET pNumEmpleado ='NULL';
        END IF;
		
        IF TRIM(pSucursal)='' THEN
        LET pSucursal ='NULL';
        END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		--LET cNombreRepXls = 'ReporteDescuentoQuincenal_'||TO_CHAR(CURRENT, '%d%m%Y')||'_'||(TO_CHAR(CURRENT, '%H%M%S'))||'.xls';
		LET cNombreRepXls = 'ReporteDescuentoQuincenal.xls';
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'NO. DE EMPLEADO','C.C. SUCURSAL','AUXILIAR','FECHA DESCUENTO','IMPORTE DEL DESCUENTO','DESCUENTO APLICADO'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT numempleado::CHAR(8),''''||numsucursal::CHAR(4),''''||numsucursal::CHAR(4)||numempleado::CHAR(8),'"||cFechaAux||"'::CHAR(10),desccalculado::CHAR(12),descaplicado::CHAR(12)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirech:rec_deschistorico";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE fechadesc =  '"||pFechaDescuento ||"' and  numempleado = NVL("||pNumEmpleado||", numempleado) AND numsucursal = NVL("||pSucursal||", numsucursal)))";
	
   
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃÂÃÂ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: OFI ',
'FUNCIONALIDAD: REPORTE DE CONSULTA DESCUENTO QUINCENAL',
'DESCRIPCION: SPL encargado de generar el reporte en excel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_genrepdescuentoquincenal(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pSucursal CHAR(4) , pFechaDescuento CHAR(10),pRutaDescarga CHAR(50))
    RETURNING CHAR(5) AS codret,
	CHAR(47) AS reporte_xls;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumsucursal         CHAR(4);
    DEFINE cNomsucursal         CHAR(40);
    DEFINE cNumempleado         CHAR(8);
    DEFINE cNomempleado         CHAR(45);
    DEFINE cDesconcepto         CHAR(80);
    DEFINE iDfaltante         SMALLINT;
    DEFINE dFecharegistro       DATE; 
    DEFINE mSaldoinicial       MONEY(10,2); 
    DEFINE mDescquincenafijo   MONEY(10,2); 
    DEFINE mMontoabono         MONEY(10,2);
    DEFINE mSaldoactual         MONEY(10,2);
    DEFINE dFechaasigna         DATE; 
    DEFINE cDesasignado         CHAR(80);
    DEFINE iDestatus           SMALLINT; 
    DEFINE iMovimientoabono   SMALLINT; 
    DEFINE cTpomovimiento     CHAR(1);
    DEFINE dFechaasignadeposito DATE;
    DEFINE dFechaliquida       DATE;
    DEFINE cAuxiliar           CHAR(12);
    DEFINE cReferencia         CHAR(26);
    DEFINE cUsuarioautoriza     CHAR(8);	
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
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dHoy DATE;
	DEFINE cStr7 CHAR(50);
	DEFINE cStr9 CHAR(50);
	DEFINE cIdPlantilla CHAR(5);
	DEFINE cNombreReporteHist CHAR(100);
    DEFINE cFechaAux CHAR(10);
    DEFINE cFechaAux2 CHAR(10);
	--DEFINE ven_transacc SMALLINT;
	--DEFINE bInTransaction BOOLEAN;
		
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cNumsucursal='';
    LET cNomsucursal='';
    LET cNumempleado='';
    LET cNomempleado ='';
    LET cDesconcepto ='';
    LET iDfaltante =0;
    LET dFecharegistro  =     DATE(1); 
    LET mSaldoinicial    =0;
    LET mDescquincenafijo  =0;
    LET mMontoabono  =0;
    LET mSaldoactual  =0;
    LET dFechaasigna  =  DATE(1);
    LET cDesasignado  ='';
    LET iDestatus   =0;
    LET iMovimientoabono =0;
    LET cTpomovimiento ='';
    LET dFechaasignadeposito =DATE(1);
    LET dFechaliquida =  DATE(1);
    LET cAuxiliar ='';
    LET cReferencia  ='';
    LET cUsuarioautoriza  ='';
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
	LET dFechaHoy = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET cIdPlantilla = '';
	LET cNombreReporteHist = '';
    --LET cFechaAux = SUBSTR(pFechaDescuento,7,5)||'/'||SUBSTR(pFechaDescuento,1,2)||'/'||SUBSTR(pFechaDescuento,4,2);
    LET cFechaAux = SUBSTR(pFechaDescuento,1,2)||'/'||SUBSTR(pFechaDescuento,4,2)||'/'||SUBSTR(pFechaDescuento,7,5);
     LET cFechaAux2 = SUBSTR(pFechaDescuento,4,2)||'/'||SUBSTR(pFechaDescuento,1,2)||'/'||SUBSTR(pFechaDescuento,7,5);
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
		
	   -- SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_genrepdescuentoquincenal.out';
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
		

        IF TRIM(pNumEmpleado)='' THEN
        LET pNumEmpleado ='NULL';
        END IF;
		
        IF TRIM(pSucursal)='' THEN
        LET pSucursal ='NULL';
        END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		--LET cNombreRepXls = 'ReporteDescuentoQuincenal_'||TO_CHAR(CURRENT, '%d%m%Y')||'_'||(TO_CHAR(CURRENT, '%H%M%S'))||'.xls';
        LET cNombreRepXls = 'ReporteDescuentoQuincenal.xls';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGralXls = TRIM(pRutaDescarga)||TRIM(cNombreRepXls);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT 'NO. DE EMPLEADO','C.C. SUCURSAL','AUXILIAR','FECHA DESCUENTO','IMPORTE DEL DESCUENTO','DESCUENTO APLICADO'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT numempleado::CHAR(8),''''||numsucursal::CHAR(4),''''||numsucursal::CHAR(4)||numempleado::CHAR(8),'"||cFechaAux2||"'::CHAR(10),desccalculado::CHAR(12),descaplicado::CHAR(12)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirech:rec_descquincena";
	--	LET cCmd1 =""||TRIM(cCmd1)||" WHERE fechadesc =  DATE('"||pFechaDescuento ||"') and  numempleado = NVL('"||pNumEmpleado||"', numempleado) AND numsucursal = NVL('"||pSucursal||"', numsucursal)))";
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE fechadesc =  '"||cFechaAux ||"'  and  numempleado = NVL("||pNumEmpleado||", numempleado) AND numsucursal = NVL("||pSucursal||", numsucursal)))";
   
		--GENERACION DE ARCHIVO XLS
		LET cSql = '';
		LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGralXls)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
		
		-- Eliminamos el caracter delimitador ';' al final de la lÃÂÃÂ­nea
		LET cSql = '';
		LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGralXls)||".tmp > "||TRIM(cRutaGralXls);
		SYSTEM TRIM(cSql);
		
		-- Se manipula el archivo para agregar el salto de lÃÂÃÂ­nea
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
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'MODULO: OFI ',
'FUNCIONALIDAD: REPORTE DE CONSULTA DESCUENTO QUINCENAL',
'DESCRIPCION: SPL encargado de generar el reporte en excel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_grabarcifracontrol(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaQuincena DATE, pTipoCifraCtrl SMALLINT, pMonto MONEY(18,2))
		RETURNING CHAR(5) AS codret
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgrabarcifracontrol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena = '' OR pTipoCifraCtrl='' OR pMonto='' THEN
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
		
		EXECUTE PROCEDURE bdirech:"informix".spgrabarcifracontrol(pFechaQuincena,pTipoCifraCtrl,pMonto)
        INTO cCodRet;
		
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '01266';
			RETURN cCodRet;
		END IF;


       IF cCodRet ='00001' THEN
			LET cCodRet ='01266'; 		END IF;


		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgrabarcifracontrol',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_grabarconfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4), 
					pIdConcepto INTEGER, pIdRecupera INTEGER,pIdAsignado INTEGER, pSaldo MONEY(10,0), pFechaRegistro DATE, pUsuarioAutoriza CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS Numfaltante,
				  CHAR(26) AS Referencia
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumfaltante INTEGER;
	DEFINE cReferencia CHAR(26);
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumfaltante=0;
	LET cReferencia='';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumfaltante,cReferencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgrabarconfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdConcepto = '' OR pIdRecupera = '' OR pIdAsignado ='' OR pSaldo = '' OR pFechaRegistro = '' OR pUsuarioAutoriza ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumfaltante,cReferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumfaltante,cReferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

        EXECUTE PROCEDURE bdirech:"informix".spgrabarconfaltante(pNumEmpleado,pNumSucursal,pIdConcepto,pIdRecupera,pIdAsignado,pSaldo,pFechaRegistro,pUsuarioAutoriza)
		INTO  cCodRet,iNumfaltante,cReferencia;

        IF cCodRet ='00001' THEN
			LET cCodRet ='01262'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01247';         END IF;
		
        RETURN cCodRet,iNumfaltante,cReferencia;
		

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgrabarconfaltante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_grabarconfaltantearch(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaAsigna CHAR(10),pNombreArchivo CHAR(20))
		RETURNING CHAR(5) AS codret
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNombreArchivo CHAR(20);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaAsigna DATE;
	
	LET cCodRet = '00000';
	LET cNombreArchivo='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaAsigna = DATE(1);
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF cCodRet ="-255" THEN
			LET cCodRet="01025";
			END IF;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgrabarconfaltantearch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaAsigna = ''  OR pNombreArchivo = '' THEN
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
		
		LET pFechaAsigna = SUBSTRING(TRIM(pFechaAsigna) FROM 6 FOR 2)||'/'||SUBSTRING(TRIM(pFechaAsigna) FROM 9 FOR 2) ||'/'||SUBSTRING(TRIM(pFechaAsigna) FROM 1 FOR 4);
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spgrabarconfaltantearch2(pUsuario,pFechaAsigna,pNombreArchivo)
		INTO cCodRet
		RETURN cCodRet
		WITH RESUME;
		END FOREACH;
		
		 IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgrabarconfaltantearch2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_grabarmovfaltante(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8), pNumSucursal CHAR(4), 
pIdFaltante INTEGER, pTipoMovimiento CHAR(1), pFecha DATE, pIdRecupera INTEGER, pMontoMovimiento MONEY(10,0), pTransaccion CHAR(4),
 pContable CHAR(1),pUsuarioAutoriza CHAR(8), pReferencia CHAR(26))
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumfaltante INTEGER;
	DEFINE cReferencia CHAR(26);
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumfaltante=0;
	LET cReferencia='';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgrabarmovfaltante.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' OR pNumSucursal = '' OR pIdFaltante = '' OR pTipoMovimiento = '' OR pFecha ='' OR pIdRecupera = '' OR pMontoMovimiento = '' OR pTransaccion ='' OR pContable='' OR pUsuarioAutoriza='' OR pReferencia=''   THEN
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

		EXECUTE PROCEDURE bdirech:"informix".spgrabarmovfaltante2(pNumEmpleado,pNumSucursal,pIdFaltante,pTipoMovimiento,pFecha,pIdRecupera,pMontoMovimiento,pTransaccion,pContable,pUsuarioAutoriza,pReferencia)
		INTO  cCodRet;

        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01257';         END IF;

		RETURN cCodRet;
        
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgrabarmovfaltante2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_insertaerrores(pUsuario CHAR(8), pIdFuncion CHAR(10),pDescripcion CHAR(80))
		RETURNING CHAR(5) AS codret;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_insertarrecparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
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

       INSERT INTO bdirech:"informix".rec_errores (descripcion) VALUES(pDescripcion);

       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '99999';
		RETURN cCodRet;
		END IF;

		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de insertar en la tabla rec_errores',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_insertrecerror(pUsuario CHAR(8), pIdFuncion CHAR(10),pDescripcion CHAR(80))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);	
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ofi_insertrecerror.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' THEN
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

       INSERT INTO bdirech:"informix".rec_errores (descripcion) VALUES(pDescripcion);

		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de insertar en la tabla rec_errores',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_lecturaarchivocargafaltantes(pUsuario CHAR(8), pIdFuncion CHAR(10),pRutaArchivo CHAR(100), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;

	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE sEnTransacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(500);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE iNroSecuencia INTEGER;
	DEFINE iNroLinea INTEGER;
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE cLecturaArchivoDatos CHAR(1);
	DEFINE iIdReg INTEGER;
	DEFINE cConcatMsn CHAR(30);
	DEFINE iNumCaracteres INTEGER;
	DEFINE iPosTrama INTEGER;
	DEFINE cBanDetError CHAR(1);

	DEFINE cSecuencia CHAR(11);
	DEFINE cNumSucursal CHAR(4);
	DEFINE cNumEmpleado CHAR(8);
	DEFINE mSaldoInicial MONEY(10,2);
	DEFINE cFecha CHAR(10);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cNum_Credito_Tar CHAR(20);
	DEFINE cNum_Tarjeta CHAR(20);
	DEFINE cTipo_Tar CHAR(1);
	DEFINE cStatus_Tar CHAR(1);
	DEFINE cNumCte_Tar CHAR(20);
	DEFINE cNombre_Tar CHAR(30);
	DEFINE cProdDestino CHAR(20);
	DEFINE cSiglasProdAct CHAR(2);
	DEFINE cSiglasProdUpd CHAR(2);
	DEFINE cNomProdUpd CHAR(100);
	DEFINE cProdUpd CHAR(4);
	DEFINE cDomicilioEnvio CHAR(20);
	DEFINE cSucursal CHAR(20);
	DEFINE cAceptacion CHAR(20);
	DEFINE cMarca CHAR(1);

	DEFINE cDesMensajeError_Rep CHAR(120);
	DEFINE cTipoTarjeta_Rep CHAR(1);
	DEFINE cNomCliente_Rep CHAR(107);
	DEFINE cMarcaje_Rep CHAR(3);
	DEFINE cSolPlastico_Rep CHAR(2);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE ctabname	CHAR(128); --AAME RQM 10 682 -4
	DEFINE ctipodir CHAR (1); --AAME RQM 10 682 -4

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;

	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET sEnTransacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cPathdbaccess = '/informix/bin/';
	LET iNroSecuencia = 0;
	LET iNroLinea = 0;
	LET cCaracterInvalido = 'f';
	LET cLecturaArchivoDatos = 'f';
	LET iIdReg = 0;
	LET cConcatMsn = '';
	LET iNumCaracteres = 0;
	LET iPosTrama = 0;
	LET cBanDetError = 'f';

	LET cSecuencia = '';
	LET cNumSucursal = '';
	LET cNumEmpleado = '';
	LET mSaldoInicial = 0.0;
	LET cFecha = '';
	LET cNumTarjeta = '';
	LET cNum_Credito_Tar = '';
	LET cNum_Tarjeta = '';
	LET cTipo_Tar = '';
	LET cStatus_Tar = '';
	LET cNumCte_Tar = '';
	LET cNombre_Tar = '';
	LET cProdDestino = '';
	LET cSiglasProdAct = '';
	LET cSiglasProdUpd = '';
	LET cNomProdUpd = '';
	LET cProdUpd = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cAceptacion = '';
	LET cMarca='';

	LET cDesMensajeError_Rep = '';
	LET cTipoTarjeta_Rep = '';
	LET cNomCliente_Rep = '';
	LET cMarcaje_Rep = '';
	LET cSolPlastico_Rep = '';
	LET iLineaError_Rep = 0;
	LET iProcesados = 0;
	 --AAME RQM 10 682 -4
	LET cCodRet = TRIM(cCodRet);
	LET pNombreArchivo = TRIM(pNombreArchivo);
	LET pUsuario = TRIM(pUsuario);
	LET pRutaArchivo = TRIM(pRutaArchivo);
	LET ctabname = '';
	LET ctipodir = '';

	BEGIN

		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;

                UPDATE bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_lecturarchivodatos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR  pRutaArchivo = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';

            UPDATE bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes --VALIDAR SI SE REEMPLAZA CON sw_cp_statuslecturaarchivotdcTDCOro
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
        
            UPDATE bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;


			RETURN cCodRet;
		END IF;


        -- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,pNombreArchivo,'I','','','LECTURA','');


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;

        DELETE FROM bdirech:"informix".rec_faltantesarch WHERE nombrearchivo =pNombreArchivo;

		SELECT tabname
		INTO ctabname
		FROM systables
		WHERE tabname = 'sp_ofi_rec_faltantesarch_tmp';

		IF NVL(ctabname,'') <> '' THEN
			DROP TABLE bdicnweb:"informix".sp_ofi_rec_faltantesarch_tmp;
		END IF;


		CREATE TABLE bdicnweb:"informix".sp_ofi_rec_faltantesarch_tmp(
																numsucursal CHAR(20),
																numempleado CHAR(20),
																saldoinicial CHAR(20),
																fecharegistro CHAR(10),				
																PRIMARY KEY (numsucursal, numempleado)
		);
		
		

		-- SE ELIMINAN CARACTERES DE RETORNO DE CARRO (DOS)
		LET cSQL = '';
		LET cSQL = '/usr/bin/tr "\r" " " < '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||' > '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;

		LET cSQL = '';
		LET cSQL = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'; /usr/bin/mv '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);

		-- GUARDA EL QUERY DEL LOAD
		LET cSQL = '';
		LET cSQL = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" INSERT INTO bdicnweb:sp_ofi_rec_faltantesarch_tmp(";
		LET cSQL = TRIM(cSQL)||"numsucursal,numempleado,saldoinicial,fecharegistro)' | /informix/bin/dbaccess sysmaster > /dev/null 2>&1";
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;

		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);

		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;

        LET iLinea=0;
		
		FOREACH
			SELECT arch.numsucursal,arch.numempleado,arch.saldoinicial,SUBSTR(arch.fecharegistro,4,2)||'/'||SUBSTR(arch.fecharegistro,1,2)||'/'||SUBSTR(arch.fecharegistro,7,4) as fecharegistro
			INTO cNumSucursal, cNumEmpleado, mSaldoInicial, cFecha
			FROM bdicnweb:"informix".sp_ofi_rec_faltantesarch_tmp AS arch
				
			INSERT INTO bdirech:"informix".rec_faltantesarch(numsucursal,numempleado,saldoinicial,fecharegistro,numsucvalida,
			numempvalido,saldoinivalido,fecharegvalida,numauxvalido,registrovalido,nombrearchivo)
			VALUES (cNumSucursal, cNumEmpleado, mSaldoInicial,DATE(cFecha), '', '', '', '', '', '', pNombreArchivo);

            LET iLinea = iLinea+1;
		END FOREACH;

       
        IF iLinea = 0 THEN
			LET cCodRet = '01122'; --EL ARCHIVO SELECCIONADO NO ES VÃLIDO, VERIFIQUE

			UPDATE bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

			RETURN cCodRet;

		ELSE
		LET iLinea = iLinea;
        LET pUsuario=pUsuario;
		UPDATE bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
		SET  status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError,
		total_registros = iLinea
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

        RETURN cCodRet;
	

		END IF;
		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 30/04/2021',
'MODULO: OFI',
'FUNCIONALIDAD: carga el archivo de faltantes en la tabla rec_faltantesarch',
'BD:bdicnweb ';

CREATE PROCEDURE "informix".sp_ofi_obtenerfechahoy(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  DATE as fecha
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE dFecha DATE;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE pEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET dFecha = DATE(1);
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '000';
	LET pEmpresa ='001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerfechahoy.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_obtenerfechahoy(pEmpresa)INTO dFecha;
		
		RETURN cCodRet, dFecha;

        

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha;
		END IF;

		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_obtenerfechahoy',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_validaemp_reversoquebranto(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumemp char(8), pValida INTEGER)
		RETURNING CHAR(5) AS codret
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE inumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET inumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validaemp_reversoquebranto.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pNumemp='' OR pValida='' THEN
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
		

		EXECUTE PROCEDURE bdirech:"informix".sp_validaemp_reversoquebranto(pNumemp,pValida)
		INTO  cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01258';         END IF;


		RETURN cCodRet;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_validaemp_reversoquebranto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_validararchivos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro CHAR(10),pNombreArchivo CHAR(20))
		RETURNING CHAR(5) AS codret
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cNombreArchivo CHAR(20);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaRegistro DATE;
	
	LET cCodRet = '00000';
	LET cNombreArchivo='';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaRegistro = DATE(1);
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spvalidararchivos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaRegistro = ''  OR pNombreArchivo = '' THEN
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
		
		LET pFechaRegistro = SUBSTRING(TRIM(pFechaRegistro) FROM 6 FOR 2)||'/'||SUBSTRING(TRIM(pFechaRegistro) FROM 9 FOR 2) ||'/'||SUBSTRING(TRIM(pFechaRegistro) FROM 1 FOR 4);

		EXECUTE PROCEDURE bdirech:"informix".spvalidararchivos(pFechaRegistro,pNombreArchivo,pUsuario)
		INTO cCodRet;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
      
		
		IF cCodRet ='00002' THEN
			LET cCodRet ='00492';
		END IF;
     IF cCodRet ='00003' THEN
			LET cCodRet ='01260';         END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spvalidararchivos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_validarcifracontrol(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaQuincena DATE, pTipoCifraCtrl SMALLINT)
		RETURNING CHAR(5) AS codret,
				  MONEY(18,2) AS diferencia
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE mDiferencia MONEY(18,2);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET mDiferencia=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mDiferencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spvalidarcifracontrol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaQuincena =''  OR pTipoCifraCtrl='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mDiferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mDiferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		EXECUTE PROCEDURE bdirech:"informix".spvalidarcifracontrol(pFechaQuincena,pTipoCifraCtrl)
		INTO  cCodRet, mDiferencia;

          IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, mDiferencia;
		END IF;
    
       
       
       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01261';         END IF;


		RETURN cCodRet, mDiferencia;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spvalidarcifracontrol',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_validarfaltantesarch(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaAsigna CHAR(10), pNombreArchivo CHAR(20))
		RETURNING CHAR(5) AS codret,
				INTEGER as errores
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iErrores INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaAsigna DATE;
	
	LET cCodRet = '00000';
	LET iErrores = 0;
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaAsigna = DATE(1);
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iErrores;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spvalidarfaltantesarch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaAsigna = '' OR pNombreArchivo='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iErrores;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iErrores;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		 LET pFechaAsigna = SUBSTRING(TRIM(pFechaAsigna) FROM 6 FOR 2)||'/'||SUBSTRING(TRIM(pFechaAsigna) FROM 9 FOR 2) ||'/'||SUBSTRING(TRIM(pFechaAsigna) FROM 1 FOR 4);
		
		EXECUTE PROCEDURE bdirech:"informix".spvalidarfaltantesarch2(pFechaAsigna,pNombreArchivo)
		INTO cCodRet, iErrores;

         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iErrores;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		END IF;

		RETURN cCodRet, iErrores;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spvalidarcifracontrol',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_validarprocesos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaProceso DATE ,pIdproceso SMALLINT)
		RETURNING CHAR(5) AS codret,
				  CHAR(2)  AS Estatus,
				  INTEGER AS CantErrores
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iCantErrores INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEstatus CHAR(1);
	 
	
	LET cCodRet = '00000';
	LET iCantErrores=0;
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEstatus='';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEstatus,iCantErrores;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spvalidarprocesos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso =''  OR pIdproceso='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEstatus,iCantErrores;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEstatus,iCantErrores;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos(pFechaProceso,pIdproceso)
		INTO  cCodRet, cEstatus,iCantErrores;
        
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cEstatus,iCantErrores;
		END IF;

       IF cCodRet ='00001' THEN
			LET cCodRet ='01262'; 		END IF;
       IF cCodRet ='00002' THEN
			LET cCodRet ='01263';         END IF;
    
		RETURN cCodRet, cEstatus,iCantErrores;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spvalidarprocesos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_verificastatusarchivocargafaltantes(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS bandera_det_error,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,error_proceso,error,total_registros
		INTO cStatus,cBanDetError,cErrorProceso,cError,iTotal
		FROM bdicnweb:"informix".sw_ofi_statuslecturaarchivocargafaltantes
		WHERE usuario = TRIM(pUsuario) AND nombre_archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0;
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/05/2021',
'MODULO: OFI ',
'FUNCIONALIDAD: ', 
'DESCRIPCION: SPL encargado de hacer la validacion inicio/fin para el proceso de lectura de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_polizadepcoppel(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet 				 CHAR(5);
	DEFINE iSqlErr 				 INTEGER;
	DEFINE cCodRetSp 			 CHAR(5);
	DEFINE iCodRetSp 			 INTEGER;
	
	DEFINE wtesoreria 					CHAR(4);
	DEFINE pempresa   CHAR(3);
	DEFINE vtranenvio                    CHAR(4);
	DEFINE wsucursal                     CHAR(4);
	DEFINE wdivisa 						CHAR(2);
	DEFINE wprocedencia					CHAR(4);
	DEFINE vnaturaleza                   CHAR(1);
	DEFINE vtipo_tran                    CHAR(2);
	DEFINE wmonto                        MONEY(14,2);
	DEFINE wfecha_hoy DATE;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_polizadepcoppel.out';
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
		
		SELECT fecha_hoy
		INTO wfecha_hoy
		FROM bdinteg:"informix".si_fechas;
		
		FOREACH
		   	SELECT op.empresa,op.cod_trans,op.sucursal,op.divisa,op.sucursal,op.monto
	         INTO pempresa,vtranenvio,wsucursal,wdivisa,wprocedencia,wmonto
	         FROM bdisuc:"informix".ss_operaciones op, bdisuc:"informix".ss_temp_deposito_coppel tmp
	        WHERE op.cod_trans = '0072'
		      AND op.fecha_operacion = wfecha_hoy
	          AND op.reversado NOT IN ('1','SI','si')
	          AND op.monto > 0
	          AND op.folio_oper = tmp.folio_oper
	          

	       SELECT valor INTO wtesoreria
			FROM   bdisuc:"informix".ss_param_cajagen
			WHERE  codigo = "0034" AND empresa=pempresa;
			
			SELECT naturaleza,tipo_tran INTO vnaturaleza,vtipo_tran
				 FROM   bdinteg:si_transacc
				 WHERE  sistema='02' AND se_contabiliza='S' 
				 AND    empresa = pempresa AND numero = vtranenvio;
			
			EXECUTE PROCEDURE bdisuc:"informix".sp_contacg(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,
								 wprocedencia,vnaturaleza,wmonto,vtipo_tran) INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_poliza_faltsob";
			END IF;
		END FOREACH
		
		--EXECUTE PROCEDURE bdisuc:"informix".sp_poliza_depcoppel()
		--INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_poliza_depcoppel";
		END IF;
		
		RETURN cCodRet;
			

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 11/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Depositos Coppel',
'DESCRIPCION: SPL encargado de la poliza depositos coppel',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 23/11/2021',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Depositos Coppel',
'DESCRIPCION: Se realiza ajuste al sufijo bdisuc:"informix".ss_param_cajagen',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainforelacionctebcpcp(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
        CHAR(20) AS num_cliente,
        CHAR(107) AS nombre_cliente,
		DATE AS fecha_nacimiento,
        SMALLINT AS tipo_relacion,
        CHAR(100) AS descripcion_tipo_relacion,
        CHAR(107) AS nombre_analista,
        CHAR(20) AS num_cliente_coppel,
        CHAR(104) AS nombre_cliente_coppel,
        CHAR(10) AS fecha_nac_coppel,
        CHAR(10) AS fecha_relacion,
        DECIMAL(5,2) AS eficiencia,
        SMALLINT AS meses_historia,
        CHAR(1) AS puntualidad,
        DECIMAL(14,6) AS abonos_vencidos,
        CHAR(1) AS situacion_especial,
        SMALLINT AS causa_sitesp,
        CHAR(100) AS descripcion_causa_sitesp,
        CHAR(26) AS nombre1,
        CHAR(26) AS nombre2,
        CHAR(26) AS apell_paterno,
        CHAR(26) AS apell_materno,
        CHAR(4) AS sucursal,
        CHAR(13) AS rfc,
        CHAR(10) AS fecha_consulta,
        DECIMAL(14,6) AS abonomes;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMensajeRetorno CHAR(100);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE dFechaNacimiento DATE;
	DEFINE iTipoRelacion SMALLINT;
	DEFINE cDescripcionTipoRelacion CHAR(100);
	DEFINE cNombreAnalista CHAR(107);
	DEFINE cNumClienteCoppel CHAR(20);
	DEFINE cNombreClienteCoppel CHAR(104);
	DEFINE cFechaNacimientoCoppel CHAR(10);
	DEFINE cFechaRelacion CHAR(10);
	DEFINE dEficiencia DECIMAL(5,2);
	DEFINE iMesesHistoria SMALLINT;
	DEFINE cPuntualidad CHAR(1);
	DEFINE dAbonosVencidos DECIMAL(14,6);
	DEFINE cSituacionEspecial CHAR(1);
	DEFINE iCausaSituacionEspecial SMALLINT;
	DEFINE cDescripcionCausaSituacionEspecial CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApellidoPaterno CHAR(26);
	DEFINE cApellidoMaterno CHAR(26);
	DEFINE cSucursal CHAR(4);
	DEFINE cRfc CHAR(13);
	DEFINE cFechaConsulta CHAR(10);
	DEFINE dAbonoMes DECIMAL(14,6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cMensajeRetorno = '';
	LET cNumCliente = '';
	LET dFechaNacimiento = NULL;
	LET cNombreCliente = '';
	LET iTipoRelacion = 0;
	LET cDescripcionTipoRelacion = '';
	LET cNombreAnalista = '';
	LET cNumClienteCoppel = '';
	LET cNombreClienteCoppel = '';
	LET cFechaNacimientoCoppel = '';
	LET cFechaRelacion = '';
	LET dEficiencia = NULL;
	LET iMesesHistoria = 0;
	LET cPuntualidad = '';
	LET dAbonosVencidos = NULL;
	LET cSituacionEspecial = '';
	LET iCausaSituacionEspecial = 0;
	LET cDescripcionCausaSituacionEspecial = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cSucursal = '';
	LET cRfc = '';
	LET cFechaConsulta = '';
	LET dAbonoMes = NULL;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, iTipoRelacion, cDescripcionTipoRelacion, cNombreAnalista, 
				cNumClienteCoppel, cNombreClienteCoppel, cFechaNacimientoCoppel, cFechaRelacion, dEficiencia, iMesesHistoria, cPuntualidad, 
				dAbonosVencidos, cSituacionEspecial, iCausaSituacionEspecial, cDescripcionCausaSituacionEspecial, cNombre1, cNombre2, 
				cApellidoPaterno, cApellidoMaterno, cSucursal, cRfc, cFechaConsulta, dAbonoMes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainforelacionctebcpcp.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, iTipoRelacion, cDescripcionTipoRelacion, cNombreAnalista, 
				cNumClienteCoppel, cNombreClienteCoppel, cFechaNacimientoCoppel, cFechaRelacion, dEficiencia, iMesesHistoria, cPuntualidad, 
				dAbonosVencidos, cSituacionEspecial, iCausaSituacionEspecial, cDescripcionCausaSituacionEspecial, cNombre1, cNombre2, 
				cApellidoPaterno, cApellidoMaterno, cSucursal, cRfc, cFechaConsulta, dAbonoMes;
		END IF;
		
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, iTipoRelacion, cDescripcionTipoRelacion, cNombreAnalista, 
				cNumClienteCoppel, cNombreClienteCoppel, cFechaNacimientoCoppel, cFechaRelacion, dEficiencia, iMesesHistoria, cPuntualidad, 
				dAbonosVencidos, cSituacionEspecial, iCausaSituacionEspecial, cDescripcionCausaSituacionEspecial, cNombre1, cNombre2, 
				cApellidoPaterno, cApellidoMaterno, cSucursal, cRfc, cFechaConsulta, dAbonoMes;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdinteg:'informix'.sp_relacion_consultainfocte (pNumCliente) INTO
			cCodRetSp, cMensajeRetorno, cNumCliente, cNombreCliente, dFechaNacimiento, iTipoRelacion, cDescripcionTipoRelacion, cNombreAnalista,
				cNumClienteCoppel, cNombreClienteCoppel, cFechaNacimientoCoppel, cFechaRelacion, dEficiencia, iMesesHistoria, cPuntualidad, 
				dAbonosVencidos, cSituacionEspecial, iCausaSituacionEspecial, cDescripcionCausaSituacionEspecial, cNombre1, cNombre2, cApellidoPaterno, 
				cApellidoMaterno, cSucursal, cRfc, cFechaConsulta, dAbonoMes;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_relacion_consultainfocte';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN -- NO SE ENCONTRO INFORMACIÃN EN COPPEL. FAVOR DE VALIDAR EL NÃMERO DE CLIENTE COPPEL
			--LET cCodRet = '00243';
			LET cCodRet = '90000';
			LET cMensajeRetorno = 'NO SE ENCONTRO INFORMACIÃN EN COPPEL. FAVOR DE VALIDAR EL NÃMERO DE CLIENTE COPPEL';
		ELIF cCodRetSp::INTEGER = 3 THEN -- EL NUMERO DE CLIENTE NO EXISTE
			LET cCodRet = '00022';
		END IF;
		
		RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, iTipoRelacion, UPPER(NVL(cDescripcionTipoRelacion, '')), cNombreAnalista, 
				cNumClienteCoppel, cNombreClienteCoppel, cFechaNacimientoCoppel, cFechaRelacion, dEficiencia, iMesesHistoria, cPuntualidad, 
				dAbonosVencidos, cSituacionEspecial, iCausaSituacionEspecial, cDescripcionCausaSituacionEspecial, cNombre1, cNombre2, 
				cApellidoPaterno, cApellidoMaterno, cSucursal, cRfc, cFechaConsulta, dAbonoMes;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2014',
'DESCRIPCION: Genera una consulta para obtener la informaciÃ³n general del cliente en bancoppel y coppel',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 28/10/2021',
'DESCRIPCION: Se modifica para reemplazar el campo vencidos udis por abonos vencidos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfosolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20))
        RETURNING CHAR(5) AS codret,
                        CHAR(20) AS numcte,        
                        CHAR(104) AS nombre_cte,      
                        CHAR(13) AS rfc,           
                        CHAR(4) AS sucursal, 
                        CHAR(20) AS num_cte_coppel,      
                        DECIMAL(18,2) AS linea_coppel, 
                        DECIMAL(18,2) AS eficiencia_pago, 
                        SMALLINT AS meses_hist,
                        CHAR(2) AS puntualidad,
                        DECIMAL(18,2) AS abonos_vencidos,
                        CHAR(1) AS situacion_credito,
                        SMALLINT AS causa,
                        CHAR(40) AS desc_situacion_especial,
                        CHAR(20) AS num_solicitud,
                        DATE AS fecha_sol,
                        DATE AS fecha_cambio_status,
                        DECIMAL(18,2) AS bc_score ,
                        DECIMAL(18,2) AS score_prop,
                        DECIMAL(18,2) AS resultado_total,
                        CHAR(2) AS status_solicitud,
                        CHAR(3) AS causa_status_solicitud,
                        CHAR(100) AS comportamiento_sic,
						DATE AS dtFechaResp,
						INTEGER AS iSecuenciaOs,
                        DATE AS fecha_sol_os,
                        CHAR(1) AS status_os,
                        CHAR(1) AS situacion_especia_os,
                        SMALLINT AS causa_situacion_especial_os,
                        CHAR(100) AS descripcion_situacion_especial_os,
                        CHAR(100) AS descripcion_motivo_os,
                        DATE AS fecha_os_tel,
                        CHAR(1) AS respuesta_os_tel,
                        CHAR(2) AS atendio,
                        DECIMAL(18,2) AS ingreso_mensual,
                        DECIMAL(18,2) AS ingreso_lc,     
                        DECIMAL(18,2) AS compromisos_banco,
                        DECIMAL(18,2) AS compromisos_sic,
                        DECIMAL(18,2) AS compromisos_coppel,
                        DECIMAL(18,2) AS cma,
                        DECIMAL(18,2) AS tab,
                        DECIMAL(18,2) AS linea_teorica,
                        DECIMAL(18,2) AS monto_solicitud,
                        DECIMAL(18,2) AS monto_max_sol,
                        CHAR(4) AS num_prod1, 
                        CHAR(40) AS desc_num_prod1,
                        CHAR(4) AS num_prod2, 
                        CHAR(40) AS desc_num_prod2,
                        INTEGER AS cma_cop,
                        INTEGER AS tab_cop,
                        INTEGER AS cra_cop,     
                        INTEGER AS monto_sol_cop,
                        INTEGER AS linea_teorica_cop,     
                        INTEGER AS puntos_parcn,
                        INTEGER AS par_altoriesgo,      
                        INTEGER AS par_celulares,
                        INTEGER AS par_prestamos,
                        CHAR(1) AS envio_cop,
                        CHAR(20) AS num_solicitud_ref,
                        CHAR(2) AS status_sol2,
                        CHAR(3) AS causa_status_sol2,
                        DATE AS fecha_cambio_status2,
                        CHAR(1) AS permite_cambio,
                        DECIMAL(18,2) AS monto_aut,
                        DECIMAL(18,2) AS limite_credito_pesos,
                        CHAR(100) AS comportamiento_coppel,
						INTEGER AS idSolicitudMovil,
						DECIMAL(5,2) AS evaluacion_fico,
						CHAR(3) AS causa_solicitud1, 
						CHAR(3) AS causa_solicitud12,
						DECIMAL(5,2) AS evaluacion_fico4,
						CHAR(3) AS CancelTemporalidad, 
						CHAR(3) AS CancelTemporalidad2,
						CHAR(1) AS Genero;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iCodRetSp INTEGER;
        -- VARIABLES DEL SP
        DEFINE cMensajeRetorno CHAR(80);
        DEFINE cNumeroCliente CHAR(20);
        DEFINE cNombreCliente CHAR(104);
        DEFINE cRfc CHAR(13);
        DEFINE cSucursal CHAR(4);
        DEFINE cNumClienteCoppel CHAR(20);
        DEFINE dLineaCoppel DECIMAL(18,2);
        DEFINE dEficienciaPago DECIMAL(18,2);
        DEFINE iMesesHist SMALLINT;
        DEFINE cPuntualidad CHAR(2);
        DEFINE dAbonosVen DECIMAL(18,2);
        DEFINE cSituacionCredito CHAR(1);
        DEFINE iCausa SMALLINT;
        DEFINE cDescripcionSituacionEspecial CHAR(40);
        DEFINE cNumeroSolicitud CHAR(20);
        DEFINE dFechaSolicitud DATE;
        DEFINE dFechaCambioEstatus DATE;
        DEFINE dBcScore DECIMAL(18,2);
        DEFINE dScoreProp DECIMAL(18,2);
        DEFINE dResultadoTotal DECIMAL(18,2);
        DEFINE cStatusSolicitud CHAR(2);
        DEFINE cCausaStatusSolicitud CHAR(3);
        DEFINE cComportamientoSic CHAR(100);
        DEFINE dFechaSolOs DATE;
        DEFINE cStatusOs CHAR(1);
        DEFINE cSituacionEspecialOs CHAR(1);
        DEFINE iCausaSituacionEspecialOs SMALLINT;
        DEFINE cDescripcionSituacionEspecialOs CHAR(100);
        DEFINE cDescripcionMotivoOs CHAR(100);
        DEFINE dFechaOsTel DATE;
        DEFINE cRespuestaOsTel CHAR(1);
        DEFINE cAtendido CHAR(2);
        DEFINE dIngresoMensual DECIMAL(18,2);
        DEFINE dIngresoLc DECIMAL(18,2);
        DEFINE dCompromisosBanco DECIMAL(18,2);
        DEFINE dCompromisosSic DECIMAL(18,2);
        DEFINE dCompromisosCoppel DECIMAL(18,2);
        DEFINE dCma DECIMAL(18,2);
        DEFINE dTab DECIMAL(18,2);
        DEFINE dLineaTeorica DECIMAL(18,2);
        DEFINE dMontoSolicitud DECIMAL(18,2);
        DEFINE dMontoMaximoSolicitud DECIMAL(18,2);
        DEFINE cNumProducto1 CHAR(4);
        DEFINE cNombreProducto1 CHAR(40);
        DEFINE cNumProducto2 CHAR(4);
        DEFINE cNombreProducto2 CHAR(40);
        DEFINE iCmaCoppel INTEGER;
        DEFINE iTabCoppel INTEGER;
        DEFINE iCraCoppel INTEGER;
        DEFINE iMontoSolicitadoCoppel INTEGER;
        DEFINE iLineaTeoricaCoppel INTEGER;
        DEFINE iPuntosParcn INTEGER;
        DEFINE iParAltoRiesgo INTEGER;
        DEFINE iParCelulares INTEGER;
        DEFINE iParPrestamos INTEGER;
        DEFINE cEnvioCoppel CHAR(1);
        DEFINE cNumSolicitudRef CHAR(20);
        DEFINE cStatusSol2 CHAR(2);
        DEFINE cCausaStatusSol2 CHAR(3);
        DEFINE dFechaCambioStatus2 DATE;
        DEFINE cPermiteCambio CHAR(1);
        DEFINE dMontoAutorizado DECIMAL(18,2);
        DEFINE dLimiteCreditoPesos DECIMAL(18,2);
        DEFINE cComportamientoCoppel CHAR(100);
		DEFINE cMensajeRetornoMovil CHAR(80);
		DEFINE cNumeroSolicitudMovil CHAR(20);
		DEFINE iIdSolicitudMovil INTEGER;
		DEFINE dEvaluacionScoring DECIMAL(5,2);
		DEFINE cCausaSolicitud1 CHAR(3);
		DEFINE cCausaSolicitud2 CHAR(3);
		DEFINE dEvaluacionScoring4 DECIMAL(5,2);
		DEFINE dtFechaResp	DATE;
		DEFINE iSecuenciaOs INTEGER;
		DEFINE cCancelTemporalidad CHAR(3);
		DEFINE cCancelTemporalidad2 CHAR(3);
		DEFINE cSexo CHAR(1);
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET iCodRetSp = 0;
        -- VARIABLES DEL SP
        LET cNumeroCliente = '';
        LET cNombreCliente = '';
        LET cRfc = '';
        LET cSucursal = '';
        LET cNumClienteCoppel = '';
        LET dLineaCoppel = NULL;
        LET dEficienciaPago = NULL;
        LET iMesesHist = 0;
        LET cPuntualidad = '';
        LET dAbonosVen = NULL;
        LET cSituacionCredito = '';
        LET iCausa = 0;
        LET cDescripcionSituacionEspecial = '';
        LET cNumeroSolicitud = '';
        LET dFechaSolicitud = NULL;
        LET dFechaCambioEstatus = NULL;
        LET dBcScore = NULL;
        LET dScoreProp = NULL;
        LET dResultadoTotal = NULL;
        LET cStatusSolicitud = '';
        LET cCausaStatusSolicitud = '';
        LET cComportamientoSic = '';
        LET dFechaSolOs = NULL;
        LET cStatusOs = '';
        LET cSituacionEspecialOs = '';
        LET iCausaSituacionEspecialOs = 0;
        LET cDescripcionSituacionEspecialOs = '';
        LET cDescripcionMotivoOs = '';
        LET dFechaOsTel = NULL;
        LET cRespuestaOsTel = '';
        LET cAtendido = '';
        LET dIngresoMensual = NULL;
        LET dIngresoLc = NULL;
        LET dCompromisosBanco = NULL;
        LET dCompromisosSic = NULL;
        LET dCompromisosCoppel = NULL;
        LET dCma = NULL;
        LET dTab = NULL;
        LET dLineaTeorica = NULL;
        LET dMontoSolicitud = NULL;
        LET dMontoMaximoSolicitud = NULL;
        LET cNumProducto1 = '';
        LET cNombreProducto1 = '';
        LET cNumProducto2 = '';
        LET cNombreProducto2 = '';
        LET iCmaCoppel = 0;
        LET iTabCoppel = 0;
        LET iCraCoppel = 0;
        LET iMontoSolicitadoCoppel = 0;
        LET iLineaTeoricaCoppel = 0;
        LET iPuntosParcn = 0;
        LET iParAltoRiesgo = 0;
        LET iParCelulares = 0;
        LET iParPrestamos = 0;
        LET cEnvioCoppel = '';
        LET cNumSolicitudRef = '';
        LET cStatusSol2 = '';
        LET cCausaStatusSol2 = '';
        LET dFechaCambioStatus2 = NULL;
        LET cPermiteCambio = '';
        LET dMontoAutorizado = NULL;
        LET dLimiteCreditoPesos = NULL;
        LET cComportamientoCoppel = '';
        LET cMensajeRetornoMovil = '';
		LET cNumeroSolicitudMovil = '';
		LET iIdSolicitudMovil = 0;
		LET dEvaluacionScoring = NULL;
		LET cCausaSolicitud1 = '';
		LET cCausaSolicitud2 = '';
		LET dEvaluacionScoring4 = NULL;
		LET dtFechaResp	=DATE(1);
		LET iSecuenciaOs =0;
		LET cCancelTemporalidad ="";
		LET cCancelTemporalidad2 ="";
		LET cSexo = '';
		
		--, cCausaSolicitud1, cCausaSolicitud2
                
        BEGIN       
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfosolicitudmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                END IF;
                
                -- VALIDACIÃ?N DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                END IF;
				
                -- EXECUTE PROCEDURE bdisolic:sp_mc_obteninfosolicitud(cEmpresa, pNumSolicitud)
				EXECUTE PROCEDURE bdisolic:sp_mc_obteninfosolicitudsoc(cEmpresa, pNumSolicitud)
                        INTO cCodRetSp, cMensajeRetorno, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, 
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs,
								dtFechaResp, iSecuenciaOs, dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, cCausaSolicitud1, cCausaSolicitud2, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                
                LET iCodRetSp = cCodRetSp::INTEGER;
                
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN EJECUCION DE SP PRODUCTIVO sp_mc_obteninfosolicitudgen';
                ELIF iCodRetSp = 1 THEN
                        LET cCodRet = '00003';
                                                RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                ELIF iCodRetSp = 2 THEN
                        LET cCodRet = '00017';
                                                RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
                END IF;
                                
                                
				LET iCodRetSp='000000';
				
				EXECUTE PROCEDURE bdisolic:sp_valida_solicitud_movil(cEmpresa, pNumSolicitud)
				INTO cCodRetSp, cMensajeRetornoMovil, cNumeroSolicitudMovil, iIdSolicitudMovil;

				LET iCodRetSp = cCodRetSp::INTEGER;                             
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN EJECUCION DE SP PRODUCTIVO sp_valida_solicitud_movil';
				END IF;
				
				-- CalificaciÃÂ³n del Scoring, seccion 3 (FICO Scoring)
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calificacion_scoring(pUsuario, pIdFuncion, pNumSolicitud, '3')
				INTO cCodRet, dEvaluacionScoring;

				IF cCodRet::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRet::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdicnweb:sp_calificacion_scoring';
				END IF;
				
				IF cCodRet <> "00000" THEN
					LET dEvaluacionScoring = 0;
				END IF;
				
				-- CalificaciÃÂ³n del Scoring, seccion 4 (FICO Scoring)
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calificacion_scoring(pUsuario, pIdFuncion, pNumSolicitud, '4')
				INTO cCodRet, dEvaluacionScoring4;

				IF cCodRet::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRet::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdicnweb:sp_calificacion_scoring';
				END IF;
				
				IF cCodRet <> "00000" THEN
					LET dEvaluacionScoring4 = 0;
				END IF;
				
				LET cCodRet = '00000';
                RETURN cCodRet, cNumeroCliente, cNombreCliente, cRfc, cSucursal, cNumClienteCoppel, dLineaCoppel, dEficienciaPago, iMesesHist, 
                                cPuntualidad, dAbonosVen, cSituacionCredito, iCausa, cDescripcionSituacionEspecial, cNumeroSolicitud, dFechaSolicitud, 
                                dFechaCambioEstatus, dBcScore, dScoreProp, dResultadoTotal, cStatusSolicitud, cCausaStatusSolicitud, cComportamientoSic, dtFechaResp, iSecuenciaOs,
                                dFechaSolOs, cStatusOs, cSituacionEspecialOs, iCausaSituacionEspecialOs, cDescripcionSituacionEspecialOs, cDescripcionMotivoOs, 
                                dFechaOsTel, cRespuestaOsTel, cAtendido, dIngresoMensual, dIngresoLc, dCompromisosBanco, dCompromisosSic, dCompromisosCoppel, 
                                dCma, dTab, dLineaTeorica, dMontoSolicitud, dMontoMaximoSolicitud, cNumProducto1, cNombreProducto1, cNumProducto2, cNombreProducto2, 
                                iCmaCoppel, iTabCoppel, iCraCoppel, iMontoSolicitadoCoppel, iLineaTeoricaCoppel, iPuntosParcn, iParAltoRiesgo, iParCelulares, 
                                iParPrestamos, cEnvioCoppel, cNumSolicitudRef, cStatusSol2, cCausaStatusSol2, dFechaCambioStatus2, cPermiteCambio, dMontoAutorizado, 
                                dLimiteCreditoPesos, cComportamientoCoppel, iIdSolicitudMovil, dEvaluacionScoring, cCausaSolicitud1, cCausaSolicitud2, dEvaluacionScoring4, cCancelTemporalidad, cCancelTemporalidad2,cSexo;
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 20/12/2013",
"DESCRIPCION: Consulta la informacion de una solicitud para mesa de control",
"AUTOR: SAUL ORTIZ BAEZA",
"FECHA: 07/05/2015",
"DESCRIPCION: se implemeto el llamado del sp sp_valida_solicitud_movil para obtener el id de solicitud movil.",
"AUTOR: Oscar Flores conde",
"FECHA: 04/07/2015",
"DESCRIPCION: Se agrega el dato correspondiente a la seccion 3 del resumen de scoring (FICO Scoring)",
"AUTOR: Oscar Flores conde",
"FECHA: 06/01/2016",
"DESCRIPCION: Se agregan los datos de salida correspondientes a causas de solicitudes",
"AUTOR: L. Montserrat LeÃÂ³n Amador",
"FECHA: 05/09/2016",
"DESCRIPCION: Se agrega el dato correspondiente a la seccion 4 del resumen de scoring (FICO Scoring)",
"AUTOR: Johnattan Esquivel SÃ¡nchez",
"FECHA: 01/08/2018",
"DESCRIPCION: Se aplica mantto MC",
"AUTOR: Rodolfo Conde Flores",
"FECHA: 31/07/2019",
"DESCRIPCION: Se agrega retorno de dato Genero e invocacion de spl productivo sp_mc_obteninfosolicitudsoc_mod",
"AUTOR: Daniel Reyes Guillen",
"FECHA: 28/10/2021",
"DESCRIPCION: Se cambia el campo vencidos udis por abonos vencidos",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_mc_consultaparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSol CHAR(20))
                RETURNING CHAR(5) AS codret,
						  INTEGER AS puntos_parcn;            
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;       
		DEFINE iPuntos_parcn INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;  
		LET iPuntos_parcn = 0;

        BEGIN   
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,iPuntos_parcn;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_mc_consultaparam.out';
                -- TRACE ON;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSol = '' THEN
                        LET cCodRet = '00003';
						RETURN cCodRet,iPuntos_parcn;
                END IF;
               
                --SELECT FIRST 1 puntos_parcn INTO iPuntos_parcn  FROM  bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud=TRIM(pNumSol);
                SELECT evaluacion INTO iPuntos_parcn  FROM  bdisolic:"informix".ss_resumen_scoring WHERE empresa = '001' AND num_solicitud = pNumSol AND seccion = '6';
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET iPuntos_parcn =0;
					RETURN cCodRet,iPuntos_parcn;
				END IF;
	
               	RETURN cCodRet,iPuntos_parcn;
        END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/11/2021',
'DESCRIPCION: Sp encargado de recuperar el valor semÃ¡foro de la tabla ss_nuevo_parametrico',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_respuestawsconscoppelmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumClienteReferencia CHAR(20), pPuntualidad CHAR(3), pEficiencia DECIMAL(5,2), pLimiteCredito INTEGER,
				pMesesHistoria INTEGER, pSdoRopa INTEGER, pSdoMuebles INTEGER, pSdoPrestamos INTEGER, pVdoRopa INTEGER, pVdoMuebles INTEGER,
				pVdoPrestamos INTEGER, pAbonoMesRopa INTEGER, pAbonoMesMuebles INTEGER, pAbonoMesPrestamos INTEGER, 
				pSdotiempoaire INTEGER,pSdonegociosafi INTEGER,pSdotiemporeestruc INTEGER,pVdotiempoaire INTEGER,pVdonegociosafi INTEGER,
				pVdotiemporeestruc INTEGER,pAbonomestiempoaire INTEGER,pAbonomesnegociosafi INTEGER,pAbonomestiemporeestruc INTEGER,pSituacionEspecial CHAR(2),
				pCausa SMALLINT, pCreditoAutorizado INTEGER, pFechaUltimaCompra DATE, pNombreCopppel CHAR(104), pFechaNacimientoCoppel DATE)
		RETURNING CHAR(5) AS codret,
				DECIMAL(14,6) AS vencido,
				CHAR(100) AS descripcion_situacion_especial,
				DECIMAL(14,6) AS abono_mes;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensaje CHAR(80);
	DEFINE dVencido DECIMAL(14,6);
	DEFINE cDescripcionSitEspecial CHAR(100);
	DEFINE dAbonoMes DECIMAL(14,6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensaje = '';
	LET dVencido = NULL;
	LET cDescripcionSitEspecial = '';
	LET dAbonoMes = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dVencido, cDescripcionSitEspecial, dAbonoMes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_respuestawsconscoppelmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dVencido, cDescripcionSitEspecial, dAbonoMes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dVencido, cDescripcionSitEspecial, dAbonoMes;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_respuestaconscoppel(cEmpresa, pNumCliente, pNumClienteReferencia, pPuntualidad, pEficiencia, pLimiteCredito, pMesesHistoria, 
													pSdoRopa, pSdoMuebles, pSdoPrestamos, pVdoRopa, pVdoMuebles, pVdoPrestamos, pAbonoMesRopa, pAbonoMesMuebles, pAbonoMesPrestamos,
													pSdotiempoaire,pSdonegociosafi,pSdotiemporeestruc,pVdotiempoaire,pVdonegociosafi,pVdotiemporeestruc,pAbonomestiempoaire,pAbonomesnegociosafi,pAbonomestiemporeestruc,													
													pSituacionEspecial, pCausa, pCreditoAutorizado, pFechaUltimaCompra, pNombreCopppel, pFechaNacimientoCoppel)
		INTO cCodRetSp, cMensaje, dVencido, cDescripcionSitEspecial, dAbonoMes;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		END IF;
		
		RETURN cCodRet, dVencido, cDescripcionSitEspecial, dAbonoMes;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/04/2014',
'DESCRIPCION: Guarda los datos en la tabla de coppel lo que fue resultado del WS de consulta de datos del cliente en Grupo Coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_aumcred_validarinfocrediticiaofi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumTarjeta CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(80) AS mensaje_retorno,
		CHAR(60) AS desc_status;
		
		
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSp 		CHAR(6);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cEmpresa 		CHAR(3);
	DEFINE cMensajeRetorno	CHAR(80);
	DEFINE cDescStatus   	CHAR(60);
	
	DEFINE cNumCredito		CHAR(20);
	DEFINE cStatusCred		CHAR(2);
	DEFINE cMtoVen		    DECIMAL(14,2);
	
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp		= '';
	LET iCodRetSp		= 0;
	LET cEmpresa 		= '001';
	LET cMensajeRetorno	= '';
	LET cDescStatus   	= '';
	
	
	LET cNumCredito		= '';
	LET cStatusCred		= '';
	LET cMtoVen     	= 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMensajeRetorno, cDescStatus; 
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_aumcred_validarinfocrediticiaofi.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pNumCte = '' AND pNumTarjeta = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRetorno, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRetorno, cDescStatus;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_validarinfocrediticia_ofi(cEmpresa, pNumCte, pNumTarjeta)
		INTO cCodRetSp, cMensajeRetorno, cDescStatus;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP sp_validarinfocrediticia_ofi";
		ELIF iCodRetSp = 000003 THEN
              LET cCodRet = '00022';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000004 THEN
              LET cCodRet = '00868';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000005 THEN
			  FOREACH WITH HOLD
			  	 SELECT a.num_credito, a.status_cred, nvl(b.monto_vencido + b.mto_venc_trasp,0)
			  	 INTO cNumCredito, cStatusCred, cMtoVen
			  	 FROM bdicred:"informix".sd_maecred a,
				      bdicred:"informix".sd_maesdos b 
			  	 WHERE a.empresa = cEmpresa 
				   AND a.numcte = pNumCte
				   AND a.num_credito = b.num_credito
				 ORDER BY fecha_apertura DESC
				 
			  END FOREACH
			  					
			  IF (cStatusCred IN ('BT','E2','E3')) THEN					
			  	 LET cCodRet = '00885';
			  ELIF (cStatusCred IN ('BA','E1') AND cMtoVen > 0) THEN
			  	 LET cCodRet = '00886';
			  ELIF (cStatusCred = 'CV')	THEN				
				 LET cCodRet = '00887';
			  ELIF (cStatusCred = 'FC') THEN
				 LET cCodRet = '00888';
			  END IF;
			  RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000006 THEN
              LET cCodRet = '00869';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000007 THEN
              LET cCodRet = '00870';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000008 THEN
              LET cCodRet = '00871';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000009 THEN
              LET cCodRet = '00872';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000010 THEN
              LET cCodRet = '00873';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000011 THEN
              LET cCodRet = '00874';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELIF iCodRetSp = 000012 THEN
              LET cCodRet = '00875';
              RETURN cCodRet, cMensajeRetorno, cDescStatus;
		ELSE
			  RETURN cCodRet, cMensajeRetorno, cDescStatus;  
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 26/09/2016',
'MODULO: CrÃÂ©dito',
'FUNCIONALIDAD: Aumento LÃÂ­nea de CrÃÂ©dito Central',
'DESCRIPCION: Valida la informaciÃÂ³n crediticia de un cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genarchprocesosucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100), pReporte CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE cNombreArchivoHist CHAR(45);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(3);
	DEFINE dFech DATE;
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	
	DEFINE iSecuencia INTEGER;
	DEFINE dFecha_alta DATE;
	DEFINE cTelefono CHAR(10);
	DEFINE cStatus CHAR(60);
	DEFINE cPromotor CHAR(8);
	DEFINE cProducto CHAR(4);
	DEFINE cNumcte CHAR(20);	
	DEFINE cNum_cte_ro CHAR(20);
	DEFINE cNum_cte_bi CHAR(20);
	DEFINE cNum_cte CHAR(20);
	DEFINE cNum_cliente_coinc CHAR(20);	
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNombre2_2 CHAR(26);
	DEFINE cNombre2_1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre CHAR(26);
	DEFINE cNoSolicitud CHAR(12);
	DEFINE dNoSolicitud CHAR(12);
	DEFINE cGenerico CHAR(20);
	DEFINE cEjecutivo CHAR(8);
	DEFINE cSucCobranza CHAR(4);
	DEFINE cFecha_nacimiento2 CHAR(10);
	DEFINE cFecha_nacimiento1 CHAR(10);
	DEFINE cFecha_nacimiento CHAR(10);
	DEFINE cTipoCte CHAR(10);	
	DEFINE cFecha CHAR(10);		
	DEFINE cCte_nuevo_existente CHAR(10);
	DEFINE cCiudad CHAR(65);
	DEFINE cCausa CHAR(40);
	DEFINE cTpo_biometria CHAR(1);
	DEFINE cFecha_bi CHAR(30);
	DEFINE cBiometria CHAR(2);
	DEFINE cApellido_paterno2 CHAR(26);
	DEFINE cApellido_paterno1 CHAR(26);
	DEFINE cApellido_paterno CHAR(26);
	DEFINE cApellido_materno2 CHAR(26);
	DEFINE cApellido_materno1 CHAR(26);
	DEFINE cApellido_materno CHAR(26);
	
	DEFINE cDescStatus CHAR(40);
	DEFINE cDebito CHAR(10);
	DEFINE cCredito CHAR(10);
	DEFINE cInversion CHAR(10);
	DEFINE cDescProducto CHAR(32);
	DEFINE iExiste INT;
	DEFINE cTel_cel CHAR(13);
	DEFINE cEst_tel_cel CHAR(15);
	DEFINE cTel_cas CHAR(13);
	DEFINE cEst_tel_cas CHAR(15);
	
	DEFINE dFechaAlta DATE;
	DEFINE iCodigo CHAR(8);
	DEFINE cDescripcion CHAR(40);
	DEFINE dFechaMovto DATE;
	DEFINE dFechaCompara DATE;
	DEFINE iCont INTEGER;
	DEFINE iIdx INTEGER;
	DEFINE iRegCommit INTEGER;
	DEFINE cTipo_mov_huella CHAR(2);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET cNombreArchivoHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	
	LET dFecha = '';
	LET dHora = '';
	LET dFechaHora = '';
	LET dFech = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	
	LET iSecuencia = 0;			
	LET dFecha_alta	= '';					
	LET cTelefono	= '';					
	LET cStatus	= '';				
	LET cPromotor	= '';			
	LET cProducto	= '';			
	LET cNumcte	= '';				
	LET cNum_cte_ro	= '';			
	LET cNum_cte_bi	= '';			
	LET cNum_cte = '';			
	LET cNum_cliente_coinc	= '';	
	LET cNum_cliente	= '';		
	LET cNombre2_2	= '';			
	LET cNombre2_1	= '';			
	LET cNombre2 = '';			
	LET cNombre1 = '';			
	LET cNombre	= '';				
	LET cNoSolicitud	= '';		
	LET dNoSolicitud	= '';
	LET cGenerico	= '';
	LET cEjecutivo	= '';	
	LET cSucCobranza = '';
	LET cFecha_nacimiento2	= '';	
	LET cFecha_nacimiento1	= '';	
	LET cFecha_nacimiento	= '';
	LET cTipoCte	= '';
	LET cFecha	= '';				
	LET cCte_nuevo_existente = '';
	LET cCiudad	= '';			
	LET cCausa	= 'NO ENCONTRADA';	
	LET cTpo_biometria = '';	
	LET cFecha_bi = '';
	LET cBiometria	= '';			
	LET cApellido_paterno2	= '';	
	LET cApellido_paterno1	= '';	
	LET cApellido_paterno	= '';	
	LET cApellido_materno2	= '';	
	LET cApellido_materno1	= '';	
	LET cApellido_materno	= '';

	LET cDescStatus = '';
	LET cDebito = '';
	LET cCredito = '';
	LET cInversion = '';
	LET cDescProducto = '';
	LET iExiste = 0;
	LET cTel_cel = '';
	LET cEst_tel_cel = '';
	LET cTel_cas = '';
	LET cEst_tel_cas = '';
	
	LET dFechaAlta = '';
	LET iCodigo = 0;
	LET cDescripcion = '';
	LET dFechaMovto = '';
	LET dFechaCompara = '';
	LET iCont = 0;
	LET iIdx = 0;
	LET iRegCommit = 500;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/informix/jagl/bdicnweb/sp_cnsif_genarchprocesosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pReporte = '' OR 
		pFechaInicial IS NULL OR pFechaFinal IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		
		---> SE ASIGNAN VALORES DE FECHA PARA CONSULTAR SOLO DEL DIA ACTUAL
		LET pFechaInicial = TODAY-1;		LET pFechaFinal = TODAY-1;		
		LET dFechaInicial=LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
	    LET dFechaFinal  =LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pReporte = 'ALTA_CTE_PRO' THEN
			
			LET cStr8 = 'ALTA_CTE_PRO';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'ALTA_PRODUCTOS_'||TRIM(cFechaHoraArchivo)||'.xls';
			------------------------------------------------
			--- Depuracion tablas
				
			TRUNCATE TABLE "informix".sw_tmp_alta_ctes_prod_mae;
			TRUNCATE TABLE "informix".sw_mantenimiento_clientes_productos;
				
			
			--- Extraccion de informacion de cuentas
			LET iCont = 0;
			---> sc_maechq
			BEGIN WORK;	
			FOREACH WITH HOLD
				SELECT  {+AVOID_FULL (bdicheq:"informix".sc_maechq ), AVOID_FULL(bdicheq:"informix".sc_maenoc), AVOID_FULL(bdicheq:"informix".sc_mae_estatus)} a.fecultdep, a.sucursal, b.ejecutivo, a.producto, c.descripcion, a.num_cte
				INTO dFecha, cSucursal, cPromotor, cProducto, cStatus, cNumcte
				FROM bdicheq:"informix".sc_maechq AS a 
				INNER JOIN bdicheq:"informix".sc_maenoc b ON b.cuenta = a.cuenta  
				INNER JOIN bdicheq:"informix".sc_mae_estatus c ON a.status_cta = c.cod_estatus
				WHERE a.fecultdep = dFechaHoy
				AND a.producto = '1100'
				
				LET iCont = iCont + 1;
	
				INSERT INTO "informix".sw_tmp_alta_ctes_prod_mae(numcte, fecha, sucursal, ejecutivo, producto, status_cta, usuario_inserta) 
				VALUES(cNumcte, dFecha, cSucursal, cPromotor, cProducto, cStatus, pUsuario);
				
				LET cNumcte =  '';
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cProducto =  '';
				LET cStatus =  '';
							
				IF iCont >= iRegCommit THEN ---CAMBIAR A 500
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET iCont = 0;
			---> sc_maechq
			BEGIN WORK;	
			FOREACH WITH HOLD
				SELECT {+AVOID_FULL (bdicheq:"informix".sc_maechq ), AVOID_FULL(bdicheq:"informix".sc_maenoc), AVOID_FULL(bdicheq:"informix".sc_mae_estatus)} b.fecha_alta, a.sucursal, b.ejecutivo, a.producto, c.descripcion, a.num_cte
				INTO dFecha, cSucursal, cPromotor, cProducto, cStatus, cNumcte
				FROM bdicheq:"informix".sc_maechq AS a 
				INNER JOIN bdicheq:"informix".sc_maenoc b ON b.cuenta = a.cuenta  
				INNER JOIN bdicheq:"informix".sc_mae_estatus c ON a.status_cta = c.cod_estatus
				WHERE  a.producto <> '1100'
				AND b.fecha_alta = dFechaHoy
				
				LET iCont = iCont + 1;
	
				INSERT INTO "informix".sw_tmp_alta_ctes_prod_mae(numcte, fecha, sucursal, ejecutivo, producto, status_cta, usuario_inserta) 
				VALUES(cNumcte, dFecha, cSucursal, cPromotor, cProducto, cStatus, pUsuario);
				
				LET cNumcte =  '';
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cProducto =  '';
				LET cStatus =  '';
							
				IF iCont >= iRegCommit THEN ---CAMBIAR A 500
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET iCont = 0;
			---> sd_maecred
			BEGIN WORK;	
			FOREACH WITH HOLD				
				SELECT a.fecha_apertura, a.sucursal , a.ejecutivo, a.num_producto, b.descripcion, a.numcte
				INTO dFecha, cSucursal, cPromotor, cProducto, cStatus, cNumcte
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_tipocartera b ON a.status_cred = b.status_cred
				WHERE a.fecha_apertura = dFechaHoy
				AND a.status_cred IN ('AA','BA','BT', 'FF', 'CV', 'FC', 'FI', 'E1','E2','E3')
				
				LET iCont = iCont + 1;
	
				INSERT INTO "informix".sw_tmp_alta_ctes_prod_mae(numcte, fecha, sucursal, ejecutivo, producto, status_cta, usuario_inserta) 
				VALUES(cNumcte, dFecha, cSucursal, cPromotor, cProducto, cStatus, pUsuario);
				
				LET cNumcte =  '';
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cProducto =  '';
				LET cStatus =  '';
			
				IF iCont >= iRegCommit THEN 
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET iCont = 0;
			---> sd_maecredcrd
			BEGIN WORK;	
			FOREACH WITH HOLD				
				SELECT a.fecha_apertura, a.sucursal , a.ejecutivo, a.num_producto, b.descripcion, a.numcte
				INTO dFecha, cSucursal, cPromotor, cProducto, cStatus, cNumcte
				FROM bdicred:"informix".sd_maecredcrd a
				INNER JOIN bdicred:"informix".sd_tipocartera b ON a.status_cred = b.status_cred
				WHERE a.fecha_apertura = dFechaHoy
				AND a.status_cred IN ('AA','BA','BT', 'FF', 'CV', 'FC', 'FI', 'E1','E2','E3')
				
				LET iCont = iCont + 1;
	
				INSERT INTO "informix".sw_tmp_alta_ctes_prod_mae(numcte, fecha, sucursal, ejecutivo, producto, status_cta, usuario_inserta) 
				VALUES(cNumcte, dFecha, cSucursal, cPromotor, cProducto, cStatus, pUsuario);
				
				LET cNumcte =  '';
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cProducto =  '';
				LET cStatus =  '';
			
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET iCont = 0;
			---> sw_mantenimiento_clientes_productos
			BEGIN WORK;	
			FOREACH WITH HOLD
				SELECT a.fecha, a.sucursal, a.ejecutivo, a.producto, a.status_cta, a.numcte, b.apell_paterno,  b.apell_materno, b.nombre1, b.nombre2, c.fecha_nac, b.fecha_alta
				INTO  dFecha, cSucursal, cPromotor, cProducto, cStatus, cNumcte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, dFechaAlta
				FROM  "informix".sw_tmp_alta_ctes_prod_mae AS a
				INNER JOIN bdinteg:"informix".si_cliente b ON b.numcte = a.numcte
				INNER JOIN bdinteg:"informix".si_ctepf c ON c.numcte = a.numcte
				WHERE a.fecha BETWEEN pFechaInicial AND pFechaFinal
				AND a.usuario_inserta = pUsuario
				
				IF dFecha > dFechaAlta THEN
					LET cCte_nuevo_existente = 'EXISTENTE';
				ELIF dFecha <= dFechaAlta THEN
					LET cCte_nuevo_existente = 'NUEVO';
				END IF;
				
				INSERT INTO "informix".sw_mantenimiento_clientes_productos
					(fecha, sucursal, promotor, cliente, producto, status_cta, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, usuario_inserta)
				VALUES
					(dFecha, cSucursal, cPromotor, cCte_nuevo_existente, cProducto, cStatus, cNumcte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, pUsuario);			
				
				LET iCont = iCont + 1;
				
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cProducto =  '';
				LET cStatus =  '';
				LET cNumcte =  '';
				LET cApellido_paterno =  '';
				LET cApellido_materno =  '';
				LET cNombre =  '';
				LET cNombre2 =  '';
				LET cFecha_nacimiento =  '';
				LET dFechaAlta = '';
				LET cCte_nuevo_existente = '';
				
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PROMOTOR','CLIENTE NUEVO/EXISTENTE','PRODUCTO','STATUS SOLICITUD','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, promotor, cliente, producto, UPPER(status_cta), ''''||numcte, apell_paterno,apell_materno,nombre1,nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), '') ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_clientes_productos";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";	
			------------------------------------------------
				
		ELIF pReporte = 'ALTA_CTE' THEN
		
			LET cStr8 = 'ALTA_CTE';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'ALTA_CLIENTES_'||TRIM(cFechaHoraArchivo)||'.xls';
			
			--- Depuracion tablas

			TRUNCATE TABLE "informix".sw_mantenimiento_clientes;

					
			---Extraccion de informacion
			
			LET iCont = 0;
			BEGIN WORK;				
			FOREACH WITH HOLD
						
				SELECT DISTINCT cliente
				INTO cNumcte
				FROM bdidigital@coppelimg_tcp:dg_expediente ex
				INNER JOIN bdinteg:"informix".si_cliente cte
					ON ex.cliente = cte.numcte
					AND cte.tipo_cliente = '1'
				WHERE ex.empresa = cEmpresa
				AND ex.cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033','0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')
				AND ex.secuencia = 1
				and ex.fecha_alta BETWEEN pFechaInicial AND pFechaFinal
				AND ex.prod_nombre IN ('ALTA CLIENTES', 'ALTA CLIENTES MENORES DE EDAD')
                AND cuenta = '99999999999'
				
				
				SELECT pFechaInicial, a.sucursal, a.ejecutivo, a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, pf.fecha_nac,'U'
				INTO dFecha,cSucursal,cPromotor,cNumcte,cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento,cTipoCte 
				FROM  bdinteg:"informix".si_cliente AS a
				INNER JOIN bdinteg:"informix".si_ctepf AS pf ON a.numcte = pf.numcte
				WHERE a.fecha_insert <> pFechaInicial
				AND a.numcte = cNumcte
				AND tipo_cliente = '1';
				
				
				LET iCont = iCont + 1;

				INSERT INTO "informix".sw_mantenimiento_clientes
			  		(fecha, sucursal, promotor, cliente, producto, status_cta, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, usuario_inserta,tipo_cliente)
			  	VALUES
			  		(dFecha, cSucursal, cPromotor, '', '', '', cNumcte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, pUsuario,cTipoCte);			
			  
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cNumcte =  '';
				LET cApellido_paterno =  '';
				LET cApellido_materno =  '';
				LET cNombre =  '';
				LET cNombre2 =  '';
				LET cFecha_nacimiento =  '';
				LET cTipoCte =  '';
				
				
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET iCont = 0;
			BEGIN WORK;				
			FOREACH WITH HOLD
													
				SELECT {+INDEX (bdinteg:"informix".si_cliente "informix".idx_fecha_insert)} a.fecha_insert, a.sucursal, a.ejecutivo, a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, pf.fecha_nac,a.tipo_cliente
				INTO dFecha,cSucursal,cPromotor,cNumcte,cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento,cTipoCte 
				FROM  bdinteg:"informix".si_cliente AS a
				INNER JOIN bdinteg:"informix".si_ctepf AS pf ON a.numcte = pf.numcte
				WHERE a.fecha_insert = dFechaHoy
		
				LET iCont = iCont + 1;

				INSERT INTO "informix".sw_mantenimiento_clientes
			  		(fecha, sucursal, promotor, cliente, producto, status_cta, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, usuario_inserta,tipo_cliente)
			  	VALUES
			  		(dFecha, cSucursal, cPromotor, '', '', '', cNumcte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, pUsuario,cTipoCte);			
			  
				LET dFecha =  '';
				LET cSucursal =  '';
				LET cPromotor =  '';
				LET cNumcte =  '';
				LET cApellido_paterno =  '';
				LET cApellido_materno =  '';
				LET cNombre =  '';
				LET cNombre2 =  '';
				LET cFecha_nacimiento =  '';
				LET cTipoCte =  '';
				
				
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!

			
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PROMOTOR','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO', 'TIPO CLIENTE' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, promotor, ''''||numcte, apell_paterno,apell_materno,nombre1,nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''),tipo_cliente ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_clientes";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";	
		
		ELIF pReporte = 'ALTA_SOL_MOV' THEN
		
			LET cStr8 = 'ALTA_SOL_MOV';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'ALTA_SOLICITUDES_MOVILES_'||TRIM(cFechaHoraArchivo)||'.xls';
			
			--- Depuracion tablas
			TRUNCATE TABLE "informix".sw_mantenimiento_moviles;
			
			---Extraccion de informacion		
			
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
			
				SELECT c.fecha_insert,c.sucursal,c.user_insert,'', c.num_producto, c.num_solicitud, c.numcte,  e.apell_paterno, e.apell_materno, 
					e.nombre1, e.nombre2, f.fecha_nac, a.telefono,c.status_solicitud,''
				INTO   cFecha, cSucursal, cPromotor, cGenerico, cProducto, cNoSolicitud, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, cTelefono, cDescStatus, cCiudad
				FROM bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b, bdisolic:ss_solicitudes c,	bdinteg:si_cliente e, bdinteg:si_ctepf f 
				where not a.folio is null and not a.numcte is null and a.folio=b.folio_movil and b.num_solicitud=c.num_solicitud and a.numcte=e.numcte 
				and a.numcte=f.numcte and a.fecha_insert=c.fecha_insert and a.fecha_insert = dFechaHoy
					
				SELECT {+INDEX (bdinteg:"informix".si_estados "informix".inx_estado)} FIRST 1 usu.ejecutivo, usu.sucursal, usu.generico1,ci.nombre
				INTO cEjecutivo,cSucCobranza,cGenerico,cCiudad
				FROM bdinteg:"informix".si_usuario_movil usu
					INNER JOIN bdinteg:"informix".si_sucursales su ON su.sucursal = usu.sucursal
					INNER JOIN bdinteg:"informix".si_estados ci ON ci.estado = su.estado
				WHERE ejecutivo = cPromotor AND activo=1
				GROUP BY usu.ejecutivo, usu.sucursal, usu.generico1,ci.nombre;
				
				INSERT INTO "informix".sw_mantenimiento_moviles (fecha, sucursal, promotor, cobranza, producto, folio, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, telefono, status_cierre, status_actual, ciudad, usuario_inserta)
				VALUES (cFecha, cSucCobranza, cPromotor, cGenerico, cProducto, cNoSolicitud, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, cTelefono, cDescStatus, cDescStatus, cCiudad, pUsuario);
				
				LET iCont = iCont + 1;

		
				LET cFecha = '';
				LET dFechaHora = '';
				LET dFech = '';
				LET cSucursal = '';
				LET cPromotor = '';
				LET cGenerico = '';
				LET cEjecutivo = '';
				LET cSucCobranza = '';
				LET cProducto = '';
				LET cNoSolicitud = '';
				LET dNoSolicitud = '';
				LET cNum_cte = '';
				LET cApellido_paterno = '';
				LET cApellido_materno = '';
				LET cNombre = '';
				LET cNombre2 = ''; 
				LET cFecha_nacimiento = '';
				LET cTelefono = '';
				LET cDescStatus = '';
				LET cCiudad = '';
				

				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			
			END FOREACH;
			COMMIT WORK;
			
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
			
				SELECT a.fecha_insert,b.sucursal,b.user_insert,'', b.producto, b.num_solicitud, b.numcte,  e.apell_paterno, e.apell_materno, 
					e.nombre1, e.nombre2, f.fecha_nac, a.telefono,"RT",''
				INTO   cFecha, cSucursal, cPromotor, cGenerico, cProducto, cNoSolicitud, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, 
				cFecha_nacimiento, cTelefono, cDescStatus, cCiudad
				FROM bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b,	bdinteg:si_cliente e, bdinteg:si_ctepf f
				WHERE not a.folio IS NULL AND NOT a.numcte is null AND a.folio=b.folio_movil AND b.num_solicitud = "" 
				AND a.numcte=e.numcte AND a.numcte=f.numcte AND a.fecha_insert = dFechaHoy
					
				SELECT {+INDEX (bdinteg:"informix".si_estados "informix".inx_estado)} FIRST 1 usu.ejecutivo, usu.sucursal, usu.generico1,ci.nombre
				INTO cEjecutivo,cSucCobranza,cGenerico,cCiudad
				FROM bdinteg:"informix".si_usuario_movil usu
					INNER JOIN bdinteg:"informix".si_sucursales su ON su.sucursal = usu.sucursal
					INNER JOIN bdinteg:"informix".si_estados ci ON ci.estado = su.estado
				WHERE ejecutivo = cPromotor AND activo=1
				GROUP BY usu.ejecutivo, usu.sucursal, usu.generico1,ci.nombre;
				
				INSERT INTO "informix".sw_mantenimiento_moviles (fecha, sucursal, promotor, cobranza, producto, folio, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, telefono, status_cierre, status_actual, ciudad, usuario_inserta)
				VALUES (cFecha, cSucCobranza, cPromotor, cGenerico, cProducto, cNoSolicitud, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, cTelefono, cDescStatus, cDescStatus, cCiudad, pUsuario);
				
				LET iCont = iCont + 1;

		
				LET cFecha = '';
				LET dFechaHora = '';
				LET dFech = '';
				LET cSucursal = '';
				LET cPromotor = '';
				LET cGenerico = '';
				LET cEjecutivo = '';
				LET cSucCobranza = '';
				LET cProducto = '';
				LET cNoSolicitud = '';
				LET dNoSolicitud = '';
				LET cNum_cte = '';
				LET cApellido_paterno = '';
				LET cApellido_materno = '';
				LET cNombre = '';
				LET cNombre2 = ''; 
				LET cFecha_nacimiento = '';
				LET cTelefono = '';
				LET cDescStatus = '';
				LET cCiudad = '';
				

				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			
			END FOREACH;
			COMMIT WORK;
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PROMOTOR','COBRANZA','PRODUCTO','NUMERO SOLICITUD','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO','CELULAR CLIENTE','STATUS ACTUAL','CIUDAD' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, promotor, cobranza, producto, ''''||folio, ''''||numcte, apell_paterno,apell_materno,nombre1,nombre2, fecha_nac, telefono, status_actual, ciudad ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_moviles";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";		
		
		ELIF pReporte = 'BIOMETRIA' THEN
			
			LET cStr8 = 'BIOMETRIA';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'BIOMETRIA_'||TRIM(cFechaHoraArchivo)||'.xls';
			
			--- Depuracion tablas
			TRUNCATE TABLE "informix".sw_mantenimiento_biometria;
					
			---Extraccion de informacion
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
			
				SELECT {+INDEX (bdicnweb:"informix".sw_mantenimiento_clientes "informix".idx_sw_mantenimiento_clientes_numcte)} c.fecha_insert, cte.sucursal, cte.promotor, cte.numcte, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.fecha_nac, c.tpo_biometria
				INTO dFecha, cSucursal, cPromotor, cNum_cte_bi, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, cTpo_biometria 
				FROM  "informix".sw_mantenimiento_clientes cte
				INNER JOIN bdinteg:"informix".si_cliente c ON cte.numcte = c.numcte
				
				IF cTpo_biometria = 0 THEN
					
					--SELECT NVL(TRIM(descripcion),'')
					SELECT descripcion 
					INTO cDescripcion
					FROM bdinteg:"informix".si_biometria_rechazo A
					WHERE A.numcte = cNum_cte_bi
					AND A.fecha_insert=
					(
						SELECT Max(b.fecha_insert )
						FROM bdinteg:"informix".si_biometria_rechazo b
						WHERE b.numcte = A.numcte
					)
					;
					LET cDescripcion = NVL(TRIM(cDescripcion),'');
					
					LET cBiometria = 'NO';
					LET cCausa = UPPER(cDescripcion);
							
				ELIF cTpo_biometria = 1 THEN
					LET cBiometria = 'SI';
					LET cCausa = 'N/A';
				END IF;
				
				LET	cCte_nuevo_existente = 'NUEVO';	
			
				
				INSERT INTO "informix".sw_mantenimiento_biometria
					(fecha, sucursal, promotor, cliente, numcte, biometria, causa, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, fecha_alta, usuario_inserta)
				VALUES
					(dFecha, cSucursal, cPromotor, cCte_nuevo_existente, cNum_cte_bi, cBiometria, cCausa, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, dFecha, pUsuario);
				
				LET iCont = iCont + 1;
				
				LET	dFecha = '';				
				LET	cSucursal = '';			
				LET	cPromotor = '';			
				LET	cCte_nuevo_existente = '';
				LET	cNum_cte_bi = '';		
				LET	cNum_cte_ro = '';			
				LET	cBiometria = '';			
				LET	cCausa = '';
				LET	cTpo_biometria = '';	
				LET cFecha_bi = '';
				LET	cApellido_paterno = '';	
				LET	cApellido_materno = '';	
				LET	cNombre = '';				
				LET	cNombre2 = '';				
				LET	cFecha_nacimiento = '';	
				LET	dFecha_alta = '';	
				LET iCodigo = 0;
				LET cDescripcion = '';
				
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PROMOTOR','CLIENTE NUEVO/EXISTENTE','NUMERO CLIENTE','BIOMETRIA CAPTURADA','CAUSA','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO','FECHA ALTA CLIENTE' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, promotor, cliente, ''''||numcte, biometria, causa, apell_paterno,apell_materno,nombre1,nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''), NVL(TO_CHAR(fecha_alta, '%d/%m/%Y'), '') ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_biometria";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";	
			
		ELIF pReporte = 'SITUACION_P109' THEN
			
			LET cStr8 = 'SITUACION_P109';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'CLIENTES_SITUACION_P109_'||TRIM(cFechaHoraArchivo)||'.xls';			
			
			--- Depuracion tablas
			TRUNCATE TABLE "informix".sw_mantenimiento_p109;
			
			---Extraccion de informacion
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
			
				SELECT {+INDEX (bdisitesp:"informix".se_ctessitespcte "informix".se_ctessitespcte_idx2), INDEX (bdinteg:"informix".si_ctepf "informix".idx_ctepf_hora_insert), INDEX (bdinteg:"informix".si_cliente "informix".idx_si_clientex)} DATE(t.fechamovto) AS fecha ,t.sucursal, t.empleadoefectuo, t.numcte, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, ct.fecha_nac
				, DATE(t.fechamovto), DATE(c.fecha_insert)
				INTO cFecha, cSucursal,  cPromotor, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, dFechaMovto, dFechaCompara 
				FROM bdisitesp:"informix".se_ctessitespcte t
					INNER JOIN bdinteg:"informix".si_cliente c ON t.numcte = c.numcte
					INNER JOIN bdinteg:"informix".si_ctepf ct ON t.numcte = ct.numcte
				WHERE t.situacion = 'P' AND t.causa = '109'
				AND DATE(t.fchalta) = dFechaHoy
				AND DATE(t.fechamovto) = DATE(
					(
					Select max(b.fecha) 
					from bdinteg:"informix".si_bitacora_ife b
					WHERE t.numcte = b.numcte
					)
				)
				
				IF dFechaMovto > dFechaCompara THEN
					LET cCte_nuevo_existente = 'EXISTENTE';
				ELIF dFechaMovto <= dFechaCompara THEN
					LET cCte_nuevo_existente = 'NUEVO';
				END IF;
				
				------------DEBITO-----------------
				FOREACH
					SELECT producto 
					INTO cProducto
					FROM bdicheq:"informix".sc_maechq 
					WHERE num_cte = cNum_cte	
					
					LET iExiste = iExiste + 1;
				END FOREACH;
				
				IF iExiste > 0 THEN
					LET cDebito = 'DÃBITO/';
					LET iExiste = 0;
				END IF;	
			
				------------CREDITO-----------------
				LET	cProducto = '';
				FOREACH
					SELECT num_producto 
					INTO cProducto
					FROM bdicred:"informix".sd_maecred 
					WHERE numcte = cNum_cte	
					
					LET iExiste = iExiste + 1;
				END FOREACH;	
				
				IF iExiste > 0 THEN
					LET cCredito = 'CRÃDITO/';
					LET iExiste = 0;
				END IF;
			
				------------INVERSION-----------------
				LET	cProducto = '';
				FOREACH
					SELECT num_producto 
					INTO cProducto
					FROM bdicred:"informix".sd_maecredcrd 
					WHERE numcte = cNum_cte	
				
					LET iExiste = iExiste + 1;
				END FOREACH;
				
				IF iExiste > 0 THEN
					LET cInversion = 'INVERSIÃN/';
					LET iExiste = 0;
				END IF;
				
				LET cDescProducto = TRIM(cDebito)||TRIM(cCredito)||TRIM(cInversion);
				LET cDescProducto = SUBSTR(TRIM(cDescProducto), 1, (LENGTH(TRIM(cDescProducto)) - 1));
				
				INSERT INTO "informix".sw_mantenimiento_p109
					(fecha, sucursal, producto, promotor ,cliente, numcte,apell_paterno, apell_materno ,nombre1, nombre2, fecha_nac, usuario_inserta)
				VALUES(cFecha,	cSucursal, cDescProducto, cPromotor, cCte_nuevo_existente, cNum_cte, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, pUsuario);
				
				LET iCont = iCont + 1;
				
				LET	cFecha  = '';				
				LET	cSucursal = '';				
				LET	cProducto = '';				
				LET	cPromotor = '';				
				LET	cCte_nuevo_existente = '';	
				LET	cNum_cte = '';				
				LET	cApellido_paterno = '';		
				LET	cApellido_materno = '';		
				LET	cNombre	 = '';				
				LET	cNombre2 = '';						
				LET	cFecha_nacimiento = '';	
				LET iExiste = 0;
				LET cDebito = '';
				LET cCredito = '';
				LET cInversion = '';
				LET cDescProducto = '';
				LET dFechaMovto = '';
				LET dFechaCompara = '';
				
				IF iCont >= iRegCommit THEN ---CAMBIAR A 500
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;	
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PRODUCTO','PROMOTOR','CLIENTE NUEVO/EXISTENTE','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, NVL(producto,'NINGUNO'), promotor ,cliente, ''''||numcte,apell_paterno,apell_materno,nombre1,nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), '') ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_p109";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";		
					
		ELIF pReporte = 'SITUACION_U3' THEN
					
			LET cStr8 = 'SITUACION_U3';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'CLIENTES_SITUACION_U3_'||TRIM(cFechaHoraArchivo)||'.xls';			
	
			--- Depuracion tablas
			
			TRUNCATE TABLE "informix".sw_mantenimiento_u3;
			
			
			---Extraccion de informacion
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD		
		
				SELECT {+AVOID_FULL (bdisitesp:"informix".se_ctessitespcte), AVOID_FULL (bdinteg:"informix".si_bitacora_dictamenes), AVOID_FULL (bdinteg:"informix".si_cliente), AVOID_FULL (bdinteg:"informix".si_ctepf)} DATE(t.fchalta) AS fecha ,t.numcte, d.numcte_coinc, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, ct.fecha_nac
				INTO cFecha, cNum_cliente, cNum_cliente_coinc, cApellido_paterno1, cApellido_materno1, cNombre1, cNombre2_1, cFecha_nacimiento1
				FROM bdisitesp:"informix".se_ctessitespcte t
				INNER JOIN bdinteg:"informix".si_bitacora_dictamenes d ON t.numcte = d.numcte
				INNER JOIN bdinteg:"informix".si_cliente c ON t.numcte = c.numcte
				INNER JOIN bdinteg:"informix".si_ctepf ct ON t.numcte = ct.numcte
				WHERE t.situacion = 'U' AND t.causa = '3'
				AND DATE(t.fchalta) = dFechaHoy
			
				IF NVL(cNum_cliente_coinc,'') <> '' THEN
					SELECT c.apell_paterno,  c.apell_materno, c.nombre1, c.nombre2, ct.fecha_nac
					INTO cApellido_paterno2, cApellido_materno2, cNombre2, cNombre2_2, cFecha_nacimiento2
					FROM bdinteg:"informix".si_cliente c 
					INNER JOIN bdinteg:"informix".si_ctepf ct ON c.numcte = ct.numcte
					WHERE c.numcte = cNum_cliente_coinc;
				END IF;
				
				INSERT INTO "informix".sw_mantenimiento_u3
					(fecha,numcte,apell_paterno_1,apell_materno_1,nombre1_1,nombre2_1,fecha_nac_1,numcte_coinc,apell_paterno_2,apell_materno_2,nombre1_2,nombre2_2,fecha_nac_2, usuario_inserta)
				VALUES
					(cFecha, cNum_cliente, cApellido_paterno1, cApellido_materno1, cNombre1, cNombre2_1, cFecha_nacimiento1,cNum_cliente_coinc, cApellido_paterno2, cApellido_materno2, cNombre2, cNombre2_2, cFecha_nacimiento2, pUsuario);
				
				LET iCont = iCont + 1;
				
				LET cFecha = '';	
				LET cNum_cliente = '';
				LET cApellido_paterno1 = '';
				LET cApellido_materno1 = '';
				LET cNombre1 = '';
				LET cNombre2_1 = '';
				LET cFecha_nacimiento1 = '';
				
				LET cNum_cliente_coinc = '';	
				LET cApellido_paterno2 = '';
				LET cApellido_materno2 = '';
				LET cNombre2 = '';
				LET cNombre2_2 = '';
				LET cFecha_nacimiento2 = '';
				
				IF iCont >= iRegCommit THEN 
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','CLIENTE 1 N DE CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO','CLIENTE 2 N DE CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||numcte,apell_paterno_1,apell_materno_1,nombre1_1,nombre2_1, REPLACE(NVL(TO_CHAR(fecha_nac_1, '%d/%m/%Y'), ''),'\',''), ''''||numcte_coinc, apell_paterno_2, apell_materno_2, nombre1_2, nombre2_2, REPLACE(NVL(TO_CHAR(fecha_nac_2, '%d/%m/%Y'), ''),'\','') ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_u3";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";	
			
		ELIF pReporte = 'HUELLA' THEN
		
			LET cStr8 = 'HUELLA';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'MANTENIMIENTO_HUELLA_'||TRIM(cFechaHoraArchivo)||'.xls';			
			
			--- Depuracion tablas
			TRUNCATE TABLE "informix".sw_mantenimiento_huellas;
			
			---Extraccion de informacion
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
				
				SELECT {+AVOID_FULL (bdinteg:"informix".si_cte_huella), AVOID_FULL (bdinteg:"informix".si_huella_linea)} 
				h.numcte ,MAX(h.secuencia) AS secuencia, hl.tipo_mov_huella
				INTO cNum_cliente, iSecuencia, cTipo_mov_huella
				FROM bdinteg:"informix".si_cte_huella h
				INNER JOIN bdinteg:"informix".si_huella_linea hl on hl.numcte=h.numcte and hl.secuencia=h.secuencia
				WHERE DATE(h.fecha_alta) = dFechaHoy
                AND DATE(h.fecha_alta) = DATE(h.fech_ult_camb)
				AND h.secuencia <> 1
				and hl.tipo_mov_huella in (2,4)
				GROUP BY  numcte, tipo_mov_huella
			
				IF NVL(cNum_cliente,'') <> '' THEN
					SELECT DATE(h.fecha_alta), h.sucursal,h.usuario, c.apell_paterno,  c.apell_materno, c.nombre1, c.nombre2, ct.fecha_nac
					INTO cFecha, cSucursal, cPromotor,cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento
					FROM bdinteg:si_cte_huella h
					INNER JOIN bdinteg:"informix".si_cliente c ON h.numcte = c.numcte
					INNER JOIN bdinteg:"informix".si_ctepf ct ON h.numcte = ct.numcte
					WHERE h.numcte = cNum_cliente AND h.secuencia = iSecuencia;
				END IF;
				
				INSERT INTO "informix".sw_mantenimiento_huellas
					(fecha, sucursal, usuario, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, usuario_inserta, tipo_mov_huella)
				VALUES(cFecha, cSucursal, cPromotor, cNum_cliente,cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, pUsuario, cTipo_mov_huella);
				
				LET iCont = iCont + 1;
				
				LET cFecha = '';
				LET cSucursal = '';
				LET cPromotor = '';
				LET cNum_cliente = '';
				LET cApellido_paterno = '';
				LET cApellido_materno = '';
				LET cNombre = '';
				LET cNombre2 = '';
				LET cFecha_nacimiento = '';
				LET iSecuencia = 0;
				LET cTipo_mov_huella = '';
				
				IF iCont >= iRegCommit THEN 
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','SUCURSAL','PROMOTOR','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO','TIPO DE PROCESO' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), ''''||sucursal, usuario, ''''||numcte, apell_paterno,apell_materno,nombre1,nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''), CASE WHEN (tipo_mov_huella = 2) then 'Mantenimiento de Huella' WHEN (tipo_mov_huella = 4) then 'Mantenimiento de Datos' END ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_mantenimiento_huellas";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta ='"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";	
			
		ELIF pReporte = 'TELEFONO' THEN
		
			LET cStr8 = 'TELEFONO';   
			LET dFechaHoy = TODAY-1;			LET dHoraHoy = TODAY-1;			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'VALIDACION_TELEFONO_'||TRIM(cFechaHoraArchivo)||'.xls';			
			
			--- Depuracion tablas

			TRUNCATE TABLE "informix".sw_validacion_tel;

			
			---Extraccion de informacion
			LET iCont = 0;
			BEGIN WORK;			
			FOREACH WITH HOLD
				/*
				SELECT {+AVOID_FULL (bdinteg:"informix".si_telefonos_actual), AVOID_FULL (bdinteg:"informix".si_cliente), AVOID_FULL (bdinteg:"informix".si_ctepf)} DISTINCT(t.numcte),
				DATE(t.fecha_hora), t.user_insert, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, DATE(ct.fecha_nac)
				INTO cNum_cliente, cFecha, cPromotor, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento
				FROM bdinteg:"informix".si_telefonos_actual t
				INNER JOIN bdinteg:"informix".si_cliente c ON t.numcte = c.numcte
				INNER JOIN bdinteg:"informix".si_ctepf ct ON t.numcte = ct.numcte
				WHERE t.empresa='001' AND DATE(t.fecha_hora) = dFechaHoy ORDER BY 2 ASC*/
				
				/*SELECT {+AVOID_FULL (bdinteg:"informix".si_telefonos_actual)} 
				DISTINCT(t.numcte), DATE(t.fecha_hora), t.user_insert
				INTO cNum_cliente, cFecha, cPromotor
				FROM bdinteg:"informix".si_telefonos_actual t
				WHERE t.empresa='001' AND DATE(t.fecha_hora) = dFechaHoy ORDER BY 2 ASC*/

				SELECT 
				{+AVOID_FULL (bdinteg:"informix".si_telefonos)}
				DISTINCT(t.numcte), DATE(t.fecha_hora), t.user_insert
				INTO cNum_cliente, cFecha, cPromotor
				FROM bdinteg:"informix".si_telefonos t
				WHERE t.fecha_hora >= dFechaHoy 
				AND t.status_tel = 'A'
				ORDER BY 2 ASC

				SELECT
				{+AVOID_FULL (bdinteg:"informix".si_cliente), AVOID_FULL (bdinteg:"informix".si_ctepf)}
				c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, ct.fecha_nac
				INTO cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento
				FROM bdinteg:"informix".si_cliente c
				INNER JOIN bdinteg:"informix".si_ctepf ct ON c.numcte = ct.numcte
				WHERE c.numcte = cNum_cliente;
				
				FOREACH
				
					SELECT FIRST 1 telefono, tel_confirmado 
					INTO cTel_cel, cEst_tel_cel
					FROM bdinteg:"informix".si_telefonos_actual WHERE tipo_tel = 2 AND numcte = cNum_cliente ORDER BY secuencia DESC
					
					IF NVL(cEst_tel_cel,'') = '' OR cEst_tel_cel = '0' THEN
						LET cEst_tel_cel = 'NO CONFIRMADO';
					ELIF cEst_tel_cel = '1' THEN
						LET cEst_tel_cel = 'CONFIRMADO';
					END IF;
					
				END FOREACH;
				
				FOREACH
				
					SELECT FIRST 1 telefono, tel_confirmado 
					INTO cTel_cas, cEst_tel_cas
					FROM bdinteg:"informix".si_telefonos_actual WHERE tipo_tel = 1 AND numcte = cNum_cliente ORDER BY secuencia DESC
					
					IF NVL(cEst_tel_cas,'') = '' OR cEst_tel_cas = '0' THEN
						LET cEst_tel_cas = 'NO CONFIRMADO';
					ELIF cEst_tel_cas = '1' THEN
						LET cEst_tel_cas = 'CONFIRMADO';
					END IF;
					
				END FOREACH;
				
				INSERT INTO "informix".sw_validacion_tel
					(fecha, promotor, numcte, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, tel_cel, est_tel_cel, tel_cas, est_tel_cas, usuario_inserta)
				VALUES(cFecha, cPromotor, cNum_cliente, cApellido_paterno, cApellido_materno, cNombre, cNombre2, cFecha_nacimiento, cTel_cel, cEst_tel_cel, cTel_cas, cEst_tel_cas, pUsuario);
				
				LET iCont = iCont + 1;
				
				LET cFecha = '';
				LET cPromotor = '';
				LET cNum_cliente = '';
				LET cApellido_paterno = '';
				LET cApellido_materno = '';
				LET cNombre = '';
				LET cNombre2 = '';
				LET cFecha_nacimiento = '';
				LET cTel_cel = '';
				LET cEst_tel_cel = '';
				LET cTel_cas = '';
				LET cEst_tel_cas = '';
				
				IF iCont >= iRegCommit THEN 
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			COMMIT WORK;	-- Prueba!!
			
			LET cCmd1 ="";	
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA','PROMOTOR','NO. CLIENTE','APELLIDO PATERNO','APELLIDO MATERNO','PRIMER NOMBRE','SEGUNDO NOMBRE','FECHA NACIMIENTO','TELEFONO CELULAR','ESTATUS TELEFONO CELULAR','TELEFONO DE CASA','ESTATUS TELEFONO CASA' ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''), promotor, ''''||numcte, apell_paterno, apell_materno, nombre1, nombre2, NVL(TO_CHAR(fecha_nac, '%d/%m/%Y'), ''), NVL(tel_cel,''), NVL(est_tel_cel,''), NVL(tel_cas,''), NVL(est_tel_cas,'') ";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM ""informix"".sw_validacion_tel vt ";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha BETWEEN '"|| dFechaInicial ||"' AND '"|| dFechaFinal||"' AND usuario_inserta = '"|| pUsuario||"' ORDER BY fecha,id_serial ASC)";
			
		END IF;
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
--			LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
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
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			
		COMMIT WORK;
		
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		
		-- NOTIFICACION CORREO ELECTRONICO
		/*
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','WEB_PROSUC','WEB_PROSUC',pUsuario,'','','1','','','','','','NOTIFICACION GENERACION ARCHIVO XLS',
	    'GENERACION DEL ARCHIVO XLS','',pReporte,'','','',1,0,0,0,0,current,current) INTO cCodRetSp;

		
		LET cStr7 = 'GENERACIÃN DEL ARCHIVO XLS';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(pIdPlantilla),
		TRIM(pIdPlantilla), 
		pUsuario, 
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		'',
		TRIM(cStr7),
		TRIM(cStr8),
		'',
		TRIM(pTituloPlantilla),
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
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Uriel Camacho Mejia',
'FECHA 10/11/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: EXTRACCION DE REPORTES',
'DESCRIPCION: SPL encargado generar los reportes en formato xls.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 03/12/2018',
'DESCRIPCION: Se modifica SPL para agregar ceros a la izquierda y mantener el tamanio de los campos correspondientes a Sucursal y Ejecutivo.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 06/12/2018',
'DESCRIPCION: Se modifica SPL de acuerdo a los cambios solicitados, se agregan descripciones de estatus.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 07/12/2018',
'DESCRIPCION: Se corrige descripcion NINGUNO.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 18/12/2018',
'DESCRIPCION: Se modifica SPL para eliminar columnas correspondientes al reporte ALTA_CLIENTES_.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 31/01/2019',
'DESCRIPCION: Se modifica SPL para quitar uniones de consultas en reporte de productos, asi como el envio de commit cada 500 registros en las insercciones de tablas',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 12/02/2019',
'DESCRIPCION: Se modifica SPL para optimizar query correspondiente al reporte BIOMETRIA.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 13/02/2019',
'DESCRIPCION: Se modifica SPL para corregir manejo de transacciones.',
'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 25/02/2019',
'DESCRIPCION: Se corrige INC 56 0342 Diferencias en los reportes recibidos de solicitudes mÃ³viles.',
'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 30/10/2020',
'DESCRIPCION: Se corrige INC 61 316 Mantenimiento a reporte de mantenimiento de huellas de clientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_lecturarchivodatostdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pRutaArchivo CHAR(100), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;

	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE sEnTransacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(500);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE iNroSecuencia INTEGER;
	DEFINE iNroLinea INTEGER;
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE cLecturaArchivoDatos CHAR(1);
	DEFINE iIdReg INTEGER;
	DEFINE cConcatMsn CHAR(30);
	DEFINE iNumCaracteres INTEGER;
	DEFINE iPosTrama INTEGER;
	DEFINE cBanDetError CHAR(1);

	DEFINE cSecuencia CHAR(11);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNum_Credito CHAR(20);
	DEFINE cNum_Producto_Cred CHAR(4);
	DEFINE cStatus_Cred CHAR(2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cNum_Credito_Tar CHAR(20);
	DEFINE cNum_Tarjeta CHAR(20);
	DEFINE cTipo_Tar CHAR(1);
	DEFINE cStatus_Tar CHAR(1);
	DEFINE cNumCte_Tar CHAR(20);
	DEFINE cNombre_Tar CHAR(30);
	DEFINE cProdDestino CHAR(20);
	DEFINE cSiglasProdAct CHAR(2);
	DEFINE cSiglasProdUpd CHAR(2);
	DEFINE cNomProdUpd CHAR(100);
	DEFINE cProdUpd CHAR(4);
	DEFINE cDomicilioEnvio CHAR(20);
	DEFINE cSucursal CHAR(20);
	DEFINE cAceptacion CHAR(20);
	DEFINE cMtoVen DECIMAL(14,2);
	
	DEFINE cDesMensajeError_Rep CHAR(120);
	DEFINE cTipoTarjeta_Rep CHAR(1);
	DEFINE cNomCliente_Rep CHAR(107);
	DEFINE cMarcaje_Rep CHAR(3);
	DEFINE cSolPlastico_Rep CHAR(2);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE ctabname	CHAR(128); --AAME RQM 10 682 -4
	DEFINE ctipodir CHAR (1); --AAME RQM 10 682 -4
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;

	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET sEnTransacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET iNroSecuencia = 0;
	LET iNroLinea = 0;
	LET cCaracterInvalido = 'f';
	LET cLecturaArchivoDatos = 'f';
	LET iIdReg = 0;
	LET cConcatMsn = '';
	LET iNumCaracteres = 0;
	LET iPosTrama = 0;	
	LET cBanDetError = 'f';

	LET cSecuencia = '';
	LET cNumCredito = '';
	LET cNum_Credito = '';
	LET cNum_Producto_Cred = '';
	LET cStatus_Cred = '';
	LET cNumTarjeta = '';
	LET cNum_Credito_Tar = '';
	LET cNum_Tarjeta = '';
	LET cTipo_Tar = '';
	LET cStatus_Tar = '';
	LET cNumCte_Tar = '';
	LET cNombre_Tar = '';
	LET cProdDestino = '';
	LET cSiglasProdAct = '';
	LET cSiglasProdUpd = '';
	LET cNomProdUpd = '';
	LET cProdUpd = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cAceptacion = '';
	LET cMtoVen = 0;
	
	LET cDesMensajeError_Rep = '';
	LET cTipoTarjeta_Rep = '';
	LET cNomCliente_Rep = '';
	LET cMarcaje_Rep = '';
	LET cSolPlastico_Rep = '';
	LET iLineaError_Rep = 0;
	LET iProcesados = 0;
	 --AAME RQM 10 682 -4
	LET cCodRet = TRIM(cCodRet);
	LET pNombreArchivo = TRIM(pNombreArchivo);
	LET pUsuario = TRIM(pUsuario);	
	LET pRutaArchivo = TRIM(pRutaArchivo);
	LET ctabname = '';
	LET ctipodir = '';
	
	BEGIN

		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;

			
				UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
				SET  status = 'E', error_proceso = 'S', error = cCodRet 
				WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
				
				RETURN cCodRet,cBanDetError; 
			END IF;
		END EXCEPTION;		
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_lecturarchivodatostdc.out';
		--TRACE ON;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pRutaArchivo = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturaarchivotdc(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,pNombreArchivo,'I','','','LECTURA','');

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		--AAME RQM 10 682-4 Se quita if exits de consulta	
		SELECT tabname 
		INTO ctabname
		FROM systables 
		WHERE tabname = 'sw_cp_cargaarchivotdc_tmp';
		
		IF NVL(ctabname,'') <> '' THEN
			DROP INDEX bdicnweb:"informix".idx_sw_carga_archivo_dtc;
			DROP TABLE bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp;
		END IF;
		
		-- SE CREAN TABLAS TEMPORALES
		/*
		CREATE TABLE bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp(
																num_credito CHAR(20),
																num_tarjeta CHAR(20),
																prod_destino CHAR(20),
																domicilio_envio CHAR(20),
																sucursal CHAR(20),
																aceptacion CHAR(20)
															   );	
															  */
		CREATE TABLE bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp(
																num_credito CHAR(20),
																num_tarjeta CHAR(20),
																prod_destino CHAR(20),
																domicilio_envio CHAR(20),
																sucursal CHAR(20),
																aceptacion CHAR(20),
																PRIMARY KEY (num_credito, num_tarjeta)																
		)in dbssc_sdodiarioc01;	
		CREATE INDEX "informix".idx_sw_carga_archivo_dtc ON "informix".sw_cp_cargaarchivotdc_tmp 
		(num_credito) USING btree in dbs_movhis_idx5 online;
				
		-- LIMPIA TABLAS
		DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		DELETE FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
	
		-- SE ELIMINAN CARACTERES DE RETORNO DE CARRO (DOS)
		LET cSQL = '';
		LET cSQL = '/usr/bin/tr "\r" " " < '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||' > '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;
		
		LET cSQL = '';
		LET cSQL = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'; /usr/bin/mv '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		-- GUARDA EL QUERY DEL LOAD
		LET cSQL = '';
		LET cSQL = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" INSERT INTO bdicnweb:sw_cp_cargaarchivotdc_tmp(";
		LET cSQL = TRIM(cSQL)||"num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion)' | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1";
		--Ruta Pruebas 
		--LET cSQL = TRIM(cSQL)||"num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion)' | /informix/bin/dbaccess sysmaster > /dev/null 2>&1";
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		--AAME 20190624 Se quita el insert select a peticion de BD y se agrega un FOREACH para realizar el insert
		-- SE LLENA TABLA PRINCIPAL
		/*INSERT INTO bdicnweb:"informix".sw_cp_procesadetallearchivotdc(num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion,
		status_cred,tipo_tarjeta,status_tar,numcte,nombre,origen_reg,error_proceso,usuario,nombre_archivo,direccion_mac,fecha_insert)
		SELECT arch.num_credito,arch.num_tarjeta,arch.prod_destino,arch.domicilio_envio,arch.sucursal,arch.aceptacion,
		cred.status_cred, tar.tipo_tarjeta, tar.status_tar, tar.numcte, tar.nombre,
		'A', '', pUsuario, pNombreArchivo, pDireccionMac, CURRENT
		FROM bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp AS arch, 
			 bdicred:"informix".sd_maecred AS cred, 
			 bdicred:"informix".sd_tarjeta AS tar
		WHERE arch.num_credito = cred.num_credito
		AND cred.num_credito = tar.num_credito
		AND arch.num_tarjeta = tar.num_tarjeta;*/
		
		FOREACH
			SELECT arch.num_credito,arch.num_tarjeta,arch.prod_destino,arch.domicilio_envio,arch.sucursal,arch.aceptacion,
			cred.status_cred, tar.tipo_tarjeta, tar.status_tar, tar.numcte, tar.nombre		
			INTO cNumCredito, cNumTarjeta, cProdDestino, cDomicilioEnvio, cSucursal, cAceptacion, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp AS arch, 
				 bdicred:"informix".sd_maecred AS cred, 
				 bdicred:"informix".sd_tarjeta AS tar
			WHERE arch.num_credito = cred.num_credito
			AND cred.num_credito = tar.num_credito
			AND arch.num_tarjeta = tar.num_tarjeta
			
			INSERT INTO bdicnweb:"informix".sw_cp_procesadetallearchivotdc(num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion,
			status_cred,tipo_tarjeta,status_tar,numcte,nombre,origen_reg,error_proceso,usuario,nombre_archivo,direccion_mac,fecha_insert)
			VALUES (cNumCredito, cNumTarjeta, cProdDestino, cDomicilioEnvio, cSucursal, cAceptacion, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar, 'A', '', pUsuario, pNombreArchivo, pDireccionMac, CURRENT);
		
		END FOREACH;		
		LET cNumCredito=''; LET cNumTarjeta=''; LET cDomicilioEnvio = ''; LET cSucursal=''; LET cAceptacion=''; LET cStatus_Cred=''; LET cTipoTarjeta_Rep=''; LET cStatus_Tar=''; LET cNumCte_Tar=''; LET cNombre_Tar='';				
		
		FOREACH
			
			SELECT num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion
			INTO cNumCredito,cNumTarjeta,cProdDestino,cDomicilioEnvio,cSucursal,cAceptacion
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp
			
			-- SE AGREGAN VALIDACIONES PARA REGISTRO DE INFORMACIÃN A REPORTERÃA
			SELECT tipo_tarjeta,nombre
			INTO cTipoTarjeta_Rep,cNomCliente_Rep
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc
			WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
			AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
			
			/* AAME RQM 10 682-4 La variable cMarcaje_Rep no tiene relacion con cAceptacion, para esta validacion las dos variables de marcaje y Solplastico inician en NO
			IF NVL(cAceptacion,'') = '' THEN
				LET cMarcaje_Rep = 'NO';
			ELSE
				LET cMarcaje_Rep = 'SI';
			END IF;
			LET cSolPlastico_Rep = '';*/
			LET cMarcaje_Rep = 'NO';
			LET cSolPlastico_Rep = 'NO';
			
			LET iLinea = iLinea + 1;
			
			--** NÃMERO DE CRÃDITO **--
			IF NVL(cNumCredito,'') = '' THEN
				LET cCampo = 'NÃMERO DE CRÃDITO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE CRÃDITO';
				
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumCredito, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE CRÃDITO';
					LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
				
					IF LENGTH(cNumCredito) <> 12 THEN
						LET cCampo = 'NÃMERO DE CRÃDITO';
						LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO CUMPLE CON LA LONGITUD CORRECTA (12 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
					
						SELECT a.num_credito, a.num_producto, a.status_cred, nvl(b.monto_vencido + b.mto_venc_trasp,0)
						INTO cNum_Credito, cNum_Producto_Cred, cStatus_Cred, cMtoVen
						FROM bdicred:"informix".sd_maecred a,
						     bdicred:"informix".sd_maesdos b 
						WHERE a.num_credito = cNumCredito
						  AND a.num_credito = b.num_credito;
			
						IF NVL(cNum_Credito,'') = '' THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							SELECT num_credito
							INTO cNum_Credito
							FROM bdicred:"informix".sd_tarjeta
							WHERE num_tarjeta = cNumTarjeta;	
							
							IF NVL(cNum_Credito,'') = '' THEN
								LET cDesMensajeError_Rep = 'INFORMACIÃN CARGADA DEL CREDITO Y TARJETA NO COINCIDE CON LA ACTUAL';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;	
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;								
							ELSE
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO NO EXISTE';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							END IF;
							
						END IF;
						
						IF NOT ( NVL(UPPER(cStatus_Cred),' ') IN ('AA','E1') AND cMtoVen = 0) THEN 
--						(NVL(UPPER(cStatus_Cred),'') <> 'AA' OR (cMtoVen > 0 AND NVL(UPPER(cStatus_Cred),'') <> 'E1')   THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							--AAME RQM 10 682-4 Se identifica el mensaje por el estatus si es vencido o Cancelado
							IF (cMtoVen > 0 ) THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							ELIF NVL(UPPER(cStatus_Cred),'') IN ('FF','FI') THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA CANCELADO';
							END IF;

							--LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			--** NÃMERO DE TARJETA **--
			IF NVL(cNumTarjeta,'') = '' THEN
				LET cCampo = 'NÃMERO DE TARJETA';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE TARJETA';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumTarjeta, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE TARJETA';
					LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
				
					IF LENGTH(cNumTarjeta) <> 16 THEN
						LET cCampo = 'NÃMERO DE TARJETA';
						LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO CUMPLE CON LA LONGITUD CORRECTA (16 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
				
						SELECT num_credito, num_tarjeta, tipo_tarjeta, status_tar, numcte, nombre
						INTO cNum_Credito_Tar, cNum_Tarjeta, cTipo_Tar, cStatus_Tar, cNumCte_Tar, cNombre_Tar
						FROM bdicred:"informix".sd_tarjeta
						WHERE num_tarjeta = cNumTarjeta;
			
						IF NVL(cNum_Tarjeta,'') = '' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO EXISTE';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
						
						IF NVL(UPPER(cStatus_Tar),'') <> 'A' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO SE ENCUENTRA ACTIVO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
							
						IF NVL(cNum_Credito_Tar,'') <> NVL(cNum_Credito,'') THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO CORRESPONDE AL NÃMERO DE CRÃDITO REPORTADO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
						
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
								
						IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_cargaarchivotdc_tmp WHERE num_tarjeta = cNum_Tarjeta) > 1 THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'SE ENCONTRARON NÃMEROS DE TARJETA DUPLICADOS';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
			
						IF NVL(UPPER(cTipo_Tar),'') = 'A' THEN
							IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
								WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac AND
								num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A') > 1 THEN
								--LET cCampo = 'NÃMERO DE TARJETA';
								LET cDesMensajeError_Rep = 'NO SE ENCONTRÃ EL NÃMERO DE TARJETA TITULAR';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							END IF;
							
						END IF;
					END IF;
				END IF;
			END IF;
			
			--** PRODUCTO DESTINO **--
			IF NVL(cProdDestino,'') = '' THEN
				LET cCampo = 'PRODUCTO DESTINO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE PRODUCTO DESTINO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cProdDestino, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'PRODUCTO DESTINO';
					LET cDesMensajeError = 'EL NÃMERO DE PRODUCTO DESTINO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
					
					IF LENGTH(cProdDestino) <> 4 THEN
						LET cCampo = 'PRODUCTO DESTINO';
						LET cDesMensajeError = 'EL NÃMERO DE PRODUCTO DESTINO NO CUMPLE CON LA LONGITUD CORRECTA (4 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
						
						SELECT num_credito, num_producto, status_cred
						INTO cNum_Credito, cNum_Producto_Cred, cStatus_Cred
						FROM bdicred:"informix".sd_maecred
						WHERE num_credito = cNumCredito;
						
						IF cProdDestino = cNum_Producto_Cred THEN
							--LET cCampo = 'PRODUCTO DESTINO';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO ES VÃLIDO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;	
						ELSE
						
							LET cSiglasProdAct = SUBSTR(cNum_Producto_Cred,1,2);
							LET cSiglasProdUpd = SUBSTR(cProdDestino,1,2);
							
							FOREACH
								EXECUTE PROCEDURE bdicred:"informix".sp_consulta_prod_upgrade('001', cSiglasProdAct, cSiglasProdUpd)
								INTO cCodRetSp,cDesCodRetSp,cNomProdUpd,cProdUpd
							
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_consulta_prod_upgrade';
								END IF;
							END FOREACH;
							
							IF cProdDestino <> NVL(cProdUpd,'') THEN
								--LET cCampo = 'PRODUCTO DESTINO';
								LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO ES VÃLIDO';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							END IF;
							
						END IF;
						
						IF NVL(UPPER(cTipo_Tar),'') = 'A' THEN
							IF cProdDestino <> NVL((SELECT prod_destino FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
													WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac AND
													num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A'),'') THEN
								--LET cCampo = 'PRODUCTO DESTINO';
								LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO CORRESPONDE AL NÃMERO DE PRODUCTO DESTINO REPORTADO EN EL NÃMERO DE TARJETA TITULAR';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							END IF;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			--** DOMICILIO DE ENVÃO **--
			IF NVL(cDomicilioEnvio,'') = '' THEN
				LET cCampo = 'DOMICILIO DE ENVÃO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UNA CLAVE DE DOMICILIO DE ENVÃO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
				--AAME RQM 10 682-4 Se quita IF NOT EXITS
				LET cDomicilioEnvio = TRIM(cDomicilioEnvio);
				SELECT tipo_dir 
				INTO ctipodir
				FROM bdinteg:"informix".si_tipo_dir_upg 
				WHERE empresa ='001' AND tipo_dir = cDomicilioEnvio;			
			
				IF NVL(ctipodir,'') = '' THEN
					--LET cCampo = 'DOMICILIO DE ENVÃO';
					LET cDesMensajeError_Rep = 'EL DOMICILIO DE ENVÃO NO ES CORRECTO';
					--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				
					UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
					WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
					AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
					
					EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
					cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
					INTO cCodRetSp,cDesCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
					ELIF cCodRetSp::INTEGER > 0 THEN
						IF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00003';
						ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
						END IF;
						
						UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
						SET  status = 'E', error_proceso = 'S', error = cCodRet 
						WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
						
						RETURN cCodRet,cBanDetError;
					END IF;
					LET iLineaError_Rep = iLineaError_Rep + 1;
					LET cDesMensajeError_Rep = '';
					CONTINUE FOREACH;
				END IF;
					
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cDomicilioEnvio, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'DOMICILIO DE ENVÃO';
					LET cDesMensajeError = 'EL DOMICILIO DE ENVÃO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
					
					IF LENGTH(cDomicilioEnvio) <> 1 THEN
						LET cCampo = 'DOMICILIO DE ENVÃO';
						LET cDesMensajeError = 'EL DOMICILIO DE ENVÃO NO CUMPLE CON LA LONGITUD CORRECTA (1 DÃGITO)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
						
						IF NVL(cDomicilioEnvio,'') = '3' THEN
						
							--** SUCURSAL **--
							IF NVL(cSucursal,'') = '' THEN
								LET cCampo = 'SUCURSAL';
								LET cDesMensajeError = 'NO HA PROPORCIONADO EL NÃMERO DE SUCURSAL';
								INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							ELSE
							
								LET cCaracterInvalido = 'f';
								EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cSucursal, 'N')
								INTO cIdCodRetSp, cCaracterInvalido;
								
								IF cCaracterInvalido = 't' THEN
									LET cCampo = 'SUCURSAL';
									LET cDesMensajeError = 'EL NÃMERO DE SUCURSAL NO ES UN DATO NUMÃRICO';
									INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
									VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								ELSE
								
									IF LENGTH(cSucursal) <> 4 THEN
										LET cCampo = 'SUCURSAL';
										LET cDesMensajeError = 'EL NÃMERO DE SUCURSAL NO CUMPLE CON LA LONGITUD CORRECTA (4 DÃGITOS)';
										INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
										VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
									END IF;
									--AAME RQM 10 682-4 Se quita el IF NOT EXITS
									SELECT sucursal 
									INTO cSucursal
									FROM bdinteg:"informix".si_sucursales 
									WHERE sucursal = cSucursal;
									
									IF NVL(cSucursal,'') = '' THEN
										--LET cCampo = 'SUCURSAL';
										LET cDesMensajeError_Rep = 'EL NÃMERO DE SUCURSAL NO EXISTE';
										--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
										--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
										
										UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
										WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
										AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
										
										EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
										cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
										INTO cCodRetSp,cDesCodRetSp;
										
										IF cCodRetSp::INTEGER < 0 THEN 
											RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
										ELIF cCodRetSp::INTEGER > 0 THEN
											IF cCodRetSp::INTEGER = 1 THEN
												LET cCodRet = '00003';
											ELIF cCodRetSp::INTEGER = 2 THEN
												LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
											END IF;
											
											UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
											SET  status = 'E', error_proceso = 'S', error = cCodRet 
											WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
											
											RETURN cCodRet,cBanDetError;
										END IF;
										LET iLineaError_Rep = iLineaError_Rep + 1;
										LET cDesMensajeError_Rep = '';
										CONTINUE FOREACH;
									END IF;
									
								END IF;
							END IF;
						END IF;							
					END IF;					
				END IF;
			END IF;
			
			--** MARCA DE ACEPTACIÃN **--
			IF NVL(cAceptacion,'') = '' THEN
				LET cCampo = 'MARCA DE ACEPTACIÃN';
				LET cDesMensajeError = 'NO HA PROPORCIONADO MARCA DE ACEPTACIÃN';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				IF NVL(cAceptacion,'') NOT IN ('M','V') THEN
					LET cCampo = 'MARCA DE ACEPTACIÃN';
					LET cDesMensajeError = 'LA MARCA DE ACEPTACIÃN NO PERTENECE A MASTERCARD O VISA';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				END IF;
			END IF;
			
			-- SE INICIALIZAN VARIABLES
			LET cTipoTarjeta_Rep = '';
			LET cNomCliente_Rep = '';
			LET cMarcaje_Rep = '';
			LET cSolPlastico_Rep = '';
			
			-- Se contabilizan errores de negocio (REPORTERÃA)
			IF cDesMensajeError_Rep <> '' THEN
				LET iLineaError_Rep = iLineaError_Rep + 1;
				LET cDesMensajeError_Rep = '';
			END IF;
			
		END FOREACH;
		
		--Activa BotÃ³n Errores
		IF cDesMensajeError <> '' THEN
			LET cBanDetError = 't';
		END IF;
		
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;
		
		-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÃN
		IF iLinea = 0 THEN	
			LET cCodRet = '01122'; --EL ARCHIVO SELECCIONADO NO ES VÃLIDO, VERIFIQUE
			
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError;
		
		ELSE
			LET iProcesados = iLinea - iLineaError_Rep;
		END IF;
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		LET iLinea = NVL(iLinea,0);
		LET iProcesados = NVL(iProcesados,0);
		LET iLineaError_Rep = NVL(iLineaError_Rep,0);
		
		UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		SET  status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError,
		total_registros = iLinea, total_procesados = iProcesados, total_noprocesados = iLineaError_Rep
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		LET cLecturaArchivoDatos = 't';
		RETURN cCodRet,cBanDetError;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÃN MASIVA',
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n de informaciÃ³n y la carga de datos a tablas temporales (Cambio de Producto de TDC Masivo ).',
'AUTOR: Uriel CaamaÃ±o',
'FECHA: 08/03/2018',
'DESCRIPCION: Se le agregan llaves primarias e Ã­ndices a la tabla sw_cp_cargaarchivotdc_tmp.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_lecturarchivodatostdcrep(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pRutaArchivo CHAR(100), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;

	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE sEnTransacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(500);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE iNroSecuencia INTEGER;
	DEFINE iNroLinea INTEGER;
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE cLecturaArchivoDatos CHAR(1);
	DEFINE iIdReg INTEGER;
	DEFINE cConcatMsn CHAR(30);
	DEFINE iNumCaracteres INTEGER;
	DEFINE iPosTrama INTEGER;
	DEFINE cBanDetError CHAR(1);

	DEFINE cSecuencia CHAR(11);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNum_Credito CHAR(20);
	DEFINE cNum_Producto_Cred CHAR(4);
	DEFINE cStatus_Cred CHAR(2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cNum_Credito_Tar CHAR(20);
	DEFINE cNum_Tarjeta CHAR(20);
	DEFINE cTipo_Tar CHAR(1);
	DEFINE cStatus_Tar CHAR(1);
	DEFINE cNumCte_Tar CHAR(20);
	DEFINE cNombre_Tar CHAR(30);
	DEFINE cProdDestino CHAR(20);
	DEFINE cSiglasProdAct CHAR(2);
	DEFINE cSiglasProdUpd CHAR(2);
	DEFINE cNomProdUpd CHAR(100);
	DEFINE cProdUpd CHAR(4);
	DEFINE cDomicilioEnvio CHAR(20);
	DEFINE cSucursal CHAR(20);
	DEFINE cAceptacion CHAR(20);
	DEFINE cMtoVen DECIMAL(14,2);
	
	DEFINE cDesMensajeError_Rep CHAR(120);
	DEFINE cTipoTarjeta_Rep CHAR(1);
	DEFINE cNomCliente_Rep CHAR(107);
	DEFINE cMarcaje_Rep CHAR(3);
	DEFINE cSolPlastico_Rep CHAR(2);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE cContieneInfo CHAR(1);
	DEFINE cStatusProceso CHAR(1);
	DEFINE ctipodir CHAR (1); --AAME RQM 10 682 -4
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;

	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET sEnTransacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET iNroSecuencia = 0;
	LET iNroLinea = 0;
	LET cCaracterInvalido = 'f';
	LET cLecturaArchivoDatos = 'f';
	LET iIdReg = 0;
	LET cConcatMsn = '';
	LET iNumCaracteres = 0;
	LET iPosTrama = 0;	
	LET cBanDetError = 'f';

	LET cSecuencia = '';
	LET cNumCredito = '';
	LET cNum_Credito = '';
	LET cNum_Producto_Cred = '';
	LET cStatus_Cred = '';
	LET cNumTarjeta = '';
	LET cNum_Credito_Tar = '';
	LET cNum_Tarjeta = '';
	LET cTipo_Tar = '';
	LET cStatus_Tar = '';
	LET cNumCte_Tar = '';
	LET cNombre_Tar = '';
	LET cProdDestino = '';
	LET cSiglasProdAct = '';
	LET cSiglasProdUpd = '';
	LET cNomProdUpd = '';
	LET cProdUpd = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cAceptacion = '';
	LET cMtoVen = 0;
	
	LET cDesMensajeError_Rep = '';
	LET cTipoTarjeta_Rep = '';
	LET cNomCliente_Rep = '';
	LET cMarcaje_Rep = '';
	LET cSolPlastico_Rep = '';
	LET iLineaError_Rep = 0;
	LET iProcesados = 0;
	LET cContieneInfo = 'f';
	LET cStatusProceso = '';
	LET ctipodir =''; --AAME RQM 10 682 -4
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
			
				UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
				SET  status = 'E', error_proceso = 'S', error = cCodRet 
				WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
				
				RETURN cCodRet,cBanDetError;
			END IF;
		END EXCEPTION;		
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_lecturarchivodatostdcrep.out';
		--TRACE ON;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pRutaArchivo = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturaarchivotdc(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,TRIM(pNombreArchivo),'I','','','LECTURA','');

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
			
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_cp_cargaarchivotdcrep_tmp') THEN
			DROP INDEX bdicnweb:"informix".idx_sw_carga_archivo_dtc;
			DROP TABLE bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp;
		END IF;
		
		-- SE CREAN TABLAS TEMPORALES
		CREATE TABLE bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp(
																num_credito CHAR(20),
																num_tarjeta CHAR(20),
																domicilio_envio CHAR(20),
																sucursal CHAR(20),
																aceptacion CHAR(20),
																PRIMARY KEY (num_credito, num_tarjeta)																
		);	
		CREATE INDEX "informix".idx_sw_carga_archivo_dtc ON "informix".sw_cp_cargaarchivotdcrep_tmp 
		(num_credito) USING btree;
				
		-- LIMPIA TABLAS
		DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		DELETE FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
	
		-- SE ELIMINAN CARACTERES DE RETORNO DE CARRO (DOS)
		LET cSQL = '';
		LET cSQL = '/usr/bin/tr "\r" " " < '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||' > '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;
		
		LET cSQL = '';
		LET cSQL = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'; /usr/bin/mv '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		-- GUARDA EL QUERY DEL LOAD
		LET cSQL = '';
		LET cSQL = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" INSERT INTO bdicnweb:sw_cp_cargaarchivotdcrep_tmp(";
		LET cSQL = TRIM(cSQL)||"num_credito,num_tarjeta,domicilio_envio,sucursal,aceptacion)' | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1";
		--LET cSQL = TRIM(cSQL)||"num_credito,num_tarjeta,domicilio_envio,sucursal,aceptacion)' | /informix/bin/dbaccess sysmaster > /dev/null 2>&1";
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		--prod_destino
		--cProdDestino
		
		-- SE LLENA TABLA PRINCIPAL
		--AAME 20190624 Se quita el insert select a peticion de BD y se agrega un FOREACH para realizar el insert
		/*INSERT INTO bdicnweb:"informix".sw_cp_procesadetallearchivotdc(num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion,
		status_cred,tipo_tarjeta,status_tar,numcte,nombre,origen_reg,error_proceso,usuario,nombre_archivo,direccion_mac,fecha_insert)
		SELECT arch.num_credito,arch.num_tarjeta,cProdDestino,arch.domicilio_envio,arch.sucursal,arch.aceptacion,
		cred.status_cred, tar.tipo_tarjeta, tar.status_tar, tar.numcte, tar.nombre,
		'A', '', pUsuario, pNombreArchivo, pDireccionMac, CURRENT
		FROM bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp AS arch, 
			 bdicred:"informix".sd_maecred AS cred, 
			 bdicred:"informix".sd_tarjeta AS tar
		WHERE arch.num_credito = cred.num_credito
		AND cred.num_credito = tar.num_credito
		AND arch.num_tarjeta = tar.num_tarjeta;*/
		FOREACH
			SELECT arch.num_credito,arch.num_tarjeta,arch.domicilio_envio,arch.sucursal,arch.aceptacion,
			cred.status_cred, tar.tipo_tarjeta, tar.status_tar, tar.numcte, tar.nombre		
			INTO cNumCredito, cNumTarjeta, cDomicilioEnvio, cSucursal, cAceptacion, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp AS arch, 
				 bdicred:"informix".sd_maecred AS cred, 
				 bdicred:"informix".sd_tarjeta AS tar
			WHERE arch.num_credito = cred.num_credito
			AND cred.num_credito = tar.num_credito
			AND arch.num_tarjeta = tar.num_tarjeta
			
			INSERT INTO bdicnweb:"informix".sw_cp_procesadetallearchivotdc(num_credito,num_tarjeta,prod_destino,domicilio_envio,sucursal,aceptacion,
			status_cred,tipo_tarjeta,status_tar,numcte,nombre,origen_reg,error_proceso,usuario,nombre_archivo,direccion_mac,fecha_insert)
			VALUES (cNumCredito, cNumTarjeta, cProdDestino, cDomicilioEnvio, cSucursal, cAceptacion, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar, 'A', '', pUsuario, pNombreArchivo, pDireccionMac, CURRENT);
		
		END FOREACH;		
		LET cNumCredito=''; LET cNumTarjeta=''; LET cDomicilioEnvio = ''; LET cSucursal=''; LET cAceptacion=''; LET cStatus_Cred=''; LET cTipoTarjeta_Rep=''; LET cStatus_Tar=''; LET cNumCte_Tar=''; LET cNombre_Tar='';
		
		FOREACH
			
			SELECT num_credito,num_tarjeta,domicilio_envio,sucursal,aceptacion
			INTO cNumCredito,cNumTarjeta,cDomicilioEnvio,cSucursal,cAceptacion
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp
			
			-- SE AGREGAN VALIDACIONES PARA REGISTRO DE INFORMACIÃN A REPORTERÃA
			SELECT tipo_tarjeta,nombre
			INTO cTipoTarjeta_Rep,cNomCliente_Rep
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc
			WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
			AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
			
			/* AAME RQM 10 682-4 La variable cMarcaje_Rep no tiene relacion con cAceptacion, para esta validacion las dos variables de marcaje y Solplastico inician en NO
			IF NVL(cAceptacion,'') = '' THEN
				LET cMarcaje_Rep = 'NO';
			ELSE
				LET cMarcaje_Rep = 'SI';
			END IF;*/
			
			LET cMarcaje_Rep = 'NO';
			LET cSolPlastico_Rep = 'NO';
			
			LET iLinea = iLinea + 1;
			
			--** NÃMERO DE CRÃDITO **--
			IF NVL(cNumCredito,'') = '' THEN
				LET cCampo = 'NÃMERO DE CRÃDITO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE CRÃDITO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumCredito, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE CRÃDITO';
					LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
				
					IF LENGTH(cNumCredito) <> 12 THEN
						LET cCampo = 'NÃMERO DE CRÃDITO';
						LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO CUMPLE CON LA LONGITUD CORRECTA (12 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
					
						SELECT a.num_credito, a.num_producto, a.status_cred, nvl(b.monto_vencido + b.mto_venc_trasp,0)
						INTO cNum_Credito, cNum_Producto_Cred, cStatus_Cred, cMtoVen
						FROM bdicred:"informix".sd_maecred a,
						     bdicred:"informix".sd_maesdos b 
						WHERE a.num_credito = cNumCredito
						  AND a.num_credito = b.num_credito;
			
			
						IF NVL(cNum_Credito,'') = '' THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							SELECT num_credito
							INTO cNum_Credito
							FROM bdicred:"informix".sd_tarjeta
							WHERE num_tarjeta = cNumTarjeta;	
							
							IF NVL(cNum_Credito,'') <> '' THEN
								LET cDesMensajeError_Rep = 'INFORMACIÃN CARGADA DEL CREDITO Y TARJETA NO COINCIDE CON LA ACTUAL';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;		
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							ELSE
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO NO EXISTE';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							END IF;
						ELSE
							--AAME RQM 10 682-4 SE VALIDA SI YA EXISTE SOLICITUD DE PLASTICO ACTIVO
							SELECT limit 1 estatusproceso 
							INTO cStatusProceso 
							FROM intercard:"informix".solicitudtarjeta 
							WHERE numcuenta = cNum_Credito;
							
							IF NVL(cStatusProceso,'') = 'F' THEN
							
								LET cDesMensajeError_Rep = "YA EXISTE UNA SOLICITUD DE PLÃSTICO EN PROCESO PARA EL CLIENTE";
								
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;		
							END IF;
							
						END IF;
						
						IF NOT ( NVL(UPPER(cStatus_Cred),' ') IN ('AA','E1') AND cMtoVen = 0) THEN 
--						(NVL(UPPER(cStatus_Cred),'') <> 'AA' OR (cMtoVen > 0 AND NVL(UPPER(cStatus_Cred),'') <> 'E1')   THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							--AAME RQM 10 682-4 Se identifica el mensaje por el estatus si es vencido o Cancelado
							IF (cMtoVen > 0 ) THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							ELIF NVL(UPPER(cStatus_Cred),'') IN ('FF','FI') THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA CANCELADO';
							END IF;
							--LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			--** NÃMERO DE TARJETA **--
			IF NVL(cNumTarjeta,'') = '' THEN
				LET cCampo = 'NÃMERO DE TARJETA';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE TARJETA';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumTarjeta, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE TARJETA';
					LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
				
					IF LENGTH(cNumTarjeta) <> 16 THEN
						LET cCampo = 'NÃMERO DE TARJETA';
						LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO CUMPLE CON LA LONGITUD CORRECTA (16 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
				
						SELECT num_credito, num_tarjeta, tipo_tarjeta, status_tar, numcte, nombre
						INTO cNum_Credito_Tar, cNum_Tarjeta, cTipo_Tar, cStatus_Tar, cNumCte_Tar, cNombre_Tar
						FROM bdicred:"informix".sd_tarjeta
						WHERE num_tarjeta = cNumTarjeta;
			
						IF NVL(cNum_Tarjeta,'') = '' AND NVL(cNum_Credito,'') <> '' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO EXISTE';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
						
						IF NVL(UPPER(cStatus_Tar),'') <> 'A' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO SE ENCUENTRA ACTIVO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
							
						IF NVL(cNum_Credito_Tar,'') <> NVL(cNum_Credito,'') THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO CORRESPONDE AL NÃMERO DE CRÃDITO REPORTADO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
								
						IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_cargaarchivotdcrep_tmp WHERE num_tarjeta = cNum_Tarjeta) > 1 THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'SE ENCONTRARON NÃMEROS DE TARJETA DUPLICADOS';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							
							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;
								
								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
								SET  status = 'E', error_proceso = 'S', error = cCodRet 
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
								
								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';							
							CONTINUE FOREACH;
						END IF;
			
						IF NVL(UPPER(cTipo_Tar),'') = 'A' THEN
							IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
								WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac AND
								num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A') > 1 THEN
								--LET cCampo = 'NÃMERO DE TARJETA';
								LET cDesMensajeError_Rep = 'NO SE ENCONTRÃ EL NÃMERO DE TARJETA TITULAR';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								
								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
								
								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;
								
								IF cCodRetSp::INTEGER < 0 THEN 
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;
									
									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
									SET  status = 'E', error_proceso = 'S', error = cCodRet 
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
									
									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';								
								CONTINUE FOREACH;
							END IF;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			--** DOMICILIO DE ENVÃO **--
			IF NVL(cDomicilioEnvio,'') = '' THEN
				LET cCampo = 'DOMICILIO DE ENVÃO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UNA CLAVE DE DOMICILIO DE ENVÃO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
				--AAME RQM 10 682-4 Se quita IF NOT EXITS
				LET cDomicilioEnvio = TRIM(cDomicilioEnvio);
				SELECT tipo_dir 
				INTO ctipodir
				FROM bdinteg:"informix".si_tipo_dir_upg 
				WHERE empresa ='001' AND tipo_dir = cDomicilioEnvio;			
			
				IF NVL(ctipodir,'') = '' THEN
					--LET cCampo = 'DOMICILIO DE ENVÃO';
					LET cDesMensajeError_Rep = 'EL DOMICILIO DE ENVÃO NO ES CORRECTO';
					--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					
					UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
					WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
					AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
					
					EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
					cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
					INTO cCodRetSp,cDesCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
					ELIF cCodRetSp::INTEGER > 0 THEN
						IF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00003';
						ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
						END IF;
						
						UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
						SET  status = 'E', error_proceso = 'S', error = cCodRet 
						WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
						
						RETURN cCodRet,cBanDetError;
					END IF;
					LET iLineaError_Rep = iLineaError_Rep + 1;
					LET cDesMensajeError_Rep = '';					
					CONTINUE FOREACH;
				END IF;
					
				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cDomicilioEnvio, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;
				
				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'DOMICILIO DE ENVÃO';
					LET cDesMensajeError = 'EL DOMICILIO DE ENVÃO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE
					
					IF LENGTH(cDomicilioEnvio) <> 1 THEN
						LET cCampo = 'DOMICILIO DE ENVÃO';
						LET cDesMensajeError = 'EL DOMICILIO DE ENVÃO NO CUMPLE CON LA LONGITUD CORRECTA (1 DÃGITO)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
						
						IF NVL(cDomicilioEnvio,'') = '3' THEN
						
							--** SUCURSAL **--
							IF NVL(cSucursal,'') = '' THEN
								LET cCampo = 'SUCURSAL';
								LET cDesMensajeError = 'NO HA PROPORCIONADO EL NÃMERO DE SUCURSAL';
								INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
							ELSE
							
								LET cCaracterInvalido = 'f';
								EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cSucursal, 'N')
								INTO cIdCodRetSp, cCaracterInvalido;
								
								IF cCaracterInvalido = 't' THEN
									LET cCampo = 'SUCURSAL';
									LET cDesMensajeError = 'EL NÃMERO DE SUCURSAL NO ES UN DATO NUMÃRICO';
									INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
									VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
								ELSE
								
									IF LENGTH(cSucursal) <> 4 THEN
										LET cCampo = 'SUCURSAL';
										LET cDesMensajeError = 'EL NÃMERO DE SUCURSAL NO CUMPLE CON LA LONGITUD CORRECTA (4 DÃGITOS)';
										INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
										VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
									END IF;
									
									IF NOT EXISTS (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal) THEN
										--LET cCampo = 'SUCURSAL';
										LET cDesMensajeError_Rep = 'EL NÃMERO DE SUCURSAL NO EXISTE';
										--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
										--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
										
										UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdc SET error_proceso = 'N'
										WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta 
										AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
										
										EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cNumCredito,cNumTarjeta,cProdDestino,
										cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
										INTO cCodRetSp,cDesCodRetSp;
										
										IF cCodRetSp::INTEGER < 0 THEN 
											RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdc';
										ELIF cCodRetSp::INTEGER > 0 THEN
											IF cCodRetSp::INTEGER = 1 THEN
												LET cCodRet = '00003';
											ELIF cCodRetSp::INTEGER = 2 THEN
												LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
											END IF;
											
											UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
											SET  status = 'E', error_proceso = 'S', error = cCodRet 
											WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
											
											RETURN cCodRet,cBanDetError;
										END IF;
										LET iLineaError_Rep = iLineaError_Rep + 1;
										LET cDesMensajeError_Rep = '';
										CONTINUE FOREACH;
									END IF;
									
								END IF;
							END IF;							
						END IF;
					END IF;					
				END IF;
			END IF;
			
			--** MARCA DE ACEPTACIÃN **--
			IF NVL(cAceptacion,'') = '' THEN
				LET cCampo = 'MARCA DE ACEPTACIÃN';
				LET cDesMensajeError = 'NO HA PROPORCIONADO MARCA DE ACEPTACIÃN';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
			
				IF NVL(cAceptacion,'') NOT IN ('M','V') THEN
					LET cCampo = 'MARCA DE ACEPTACIÃN';
					LET cDesMensajeError = 'LA MARCA DE ACEPTACIÃN NO PERTENECE A MASTERCARD O VISA';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				END IF;
			END IF;
			
			-- SE INICIALIZAN VARIABLES
			LET cTipoTarjeta_Rep = '';
			LET cNomCliente_Rep = '';
			LET cMarcaje_Rep = '';
			LET cSolPlastico_Rep = '';
			
			-- Se contabilizan errores de negocio (REPORTERÃA)
			IF cDesMensajeError_Rep <> '' THEN
				LET iLineaError_Rep = iLineaError_Rep + 1;
				LET cDesMensajeError_Rep = '';
			END IF;
			
		END FOREACH;
		
		--Activa BotÃ³n Errores
		IF cDesMensajeError <> '' THEN
			LET cBanDetError = 't';
		END IF;
		
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;
		
		-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÃN
		IF iLinea = 0 THEN	
			LET cCodRet = '01122'; --EL ARCHIVO SELECCIONADO NO ES VÃLIDO, VERIFIQUE
			
			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
			SET  status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError;
		
		ELSE
			LET iProcesados = iLinea - iLineaError_Rep;
			LET cContieneInfo = 't'; --EL ARCHIVO CONTIENE TARJETAS QUE YA FUERON MARCADAS, Â¿DESEA REALIZAR LA SOLICITUD DEL PLÃSTICO NUEVAMENTE?
		END IF;
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		LET iLinea = NVL(iLinea,0);
		LET iProcesados = NVL(iProcesados,0);
		LET iLineaError_Rep = NVL(iLineaError_Rep,0);
		
		UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		SET  status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError,
		total_registros = iLinea, total_procesados = iProcesados, total_noprocesados = iLineaError_Rep 
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		LET cLecturaArchivoDatos = 't';
		
		--RETURN cCodRet,cBanDetError,cContieneInfo;
		RETURN cCodRet,cBanDetError;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/04/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÃN MASIVA',
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n de informaciÃ³n y la carga de datos a tablas temporales (ReposiciÃ³n de Tarjetas).',
'Se agregan nuevas reglas de negocio RQM 10 682-4.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para actualizar los regitros de la tabla sw_cp_procesadetallearchivotdc que tuvieron errores de negocio (error_proceso = N).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_lecturarchivodatostdctdcoro(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pRutaArchivo CHAR(100), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;

	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE sEnTransacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(500);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE iNroSecuencia INTEGER;
	DEFINE iNroLinea INTEGER;
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE cLecturaArchivoDatos CHAR(1);
	DEFINE iIdReg INTEGER;
	DEFINE cConcatMsn CHAR(30);
	DEFINE iNumCaracteres INTEGER;
	DEFINE iPosTrama INTEGER;
	DEFINE cBanDetError CHAR(1);

	DEFINE cSecuencia CHAR(11);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNum_Credito CHAR(20);
	DEFINE cNum_Producto_Cred CHAR(4);
	DEFINE cStatus_Cred CHAR(2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cNum_Credito_Tar CHAR(20);
	DEFINE cNum_Tarjeta CHAR(20);
	DEFINE cTipo_Tar CHAR(1);
	DEFINE cStatus_Tar CHAR(1);
	DEFINE cNumCte_Tar CHAR(20);
	DEFINE cNombre_Tar CHAR(30);
	DEFINE cProdDestino CHAR(20);
	DEFINE cSiglasProdAct CHAR(2);
	DEFINE cSiglasProdUpd CHAR(2);
	DEFINE cNomProdUpd CHAR(100);
	DEFINE cProdUpd CHAR(4);
	DEFINE cDomicilioEnvio CHAR(20);
	DEFINE cSucursal CHAR(20);
	DEFINE cAceptacion CHAR(20);
	DEFINE cMarca CHAR(1);
							  

	DEFINE cDesMensajeError_Rep CHAR(120);
	DEFINE cTipoTarjeta_Rep CHAR(1);
	DEFINE cNomCliente_Rep CHAR(107);
	DEFINE cMarcaje_Rep CHAR(3);
	DEFINE cSolPlastico_Rep CHAR(2);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE ctabname	CHAR(128); --AAME RQM 10 682 -4
	DEFINE ctipodir CHAR (1); --AAME RQM 10 682 -4

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;

	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET sEnTransacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET iNroSecuencia = 0;
	LET iNroLinea = 0;
	LET cCaracterInvalido = 'f';
	LET cLecturaArchivoDatos = 'f';
	LET iIdReg = 0;
	LET cConcatMsn = '';
	LET iNumCaracteres = 0;
	LET iPosTrama = 0;
	LET cBanDetError = 'f';

	LET cSecuencia = '';
	LET cNumCredito = '';
	LET cNum_Credito = '';
	LET cNum_Producto_Cred = '';
	LET cStatus_Cred = '';
	LET cNumTarjeta = '';
	LET cNum_Credito_Tar = '';
	LET cNum_Tarjeta = '';
	LET cTipo_Tar = '';
	LET cStatus_Tar = '';
	LET cNumCte_Tar = '';
	LET cNombre_Tar = '';
	LET cProdDestino = '';
	LET cSiglasProdAct = '';
	LET cSiglasProdUpd = '';
	LET cNomProdUpd = '';
	LET cProdUpd = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cAceptacion = '';
	LET cMarca='';
				  

	LET cDesMensajeError_Rep = '';
	LET cTipoTarjeta_Rep = '';
	LET cNomCliente_Rep = '';
	LET cMarcaje_Rep = '';
	LET cSolPlastico_Rep = '';
	LET iLineaError_Rep = 0;
	LET iProcesados = 0;
	 --AAME RQM 10 682 -4
	LET cCodRet = TRIM(cCodRet);
	LET pNombreArchivo = TRIM(pNombreArchivo);
	LET pUsuario = TRIM(pUsuario);
	LET pRutaArchivo = TRIM(pRutaArchivo);
	LET ctabname = '';
	LET ctipodir = '';

	BEGIN

		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;


				UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

				RETURN cCodRet,cBanDetError;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_lecturarchivodatostdcTDCOro.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pRutaArchivo = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';

			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro --VALIDAR SI SE REEMPLAZA CON sw_cp_statuslecturaarchivotdcTDCOro
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

			RETURN cCodRet,cBanDetError;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

			RETURN cCodRet,cBanDetError;
		END IF;

		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,pNombreArchivo,'I','','','LECTURA','');

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		--AAME RQM 10 682-4 Se quita if exits de consulta
		SELECT tabname
		INTO ctabname
		FROM systables
		WHERE tabname = 'sw_cp_cargaarchivotdctdcoro_tmp';

		IF NVL(ctabname,'') <> '' THEN
			DROP INDEX bdicnweb:"informix".idx_sw_carga_archivo_dtctdcro;
			DROP TABLE bdicnweb:"informix".sw_cp_cargaarchivotdctdcoro_tmp;
		END IF;


		CREATE TABLE bdicnweb:"informix".sw_cp_cargaarchivotdctdcoro_tmp(
																num_credito CHAR(20),
																num_tarjeta CHAR(20),
																prod_destino CHAR(20),
																domicilio_envio CHAR(20),
																marca CHAR (1),
																PRIMARY KEY (num_credito, num_tarjeta)
		);
		CREATE INDEX "informix".idx_sw_carga_archivo_dtctdcro ON "informix".sw_cp_cargaarchivotdctdcoro_tmp
		(num_credito) USING btree;

		-- LIMPIA TABLAS
		DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		DELETE FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;

		-- SE ELIMINAN CARACTERES DE RETORNO DE CARRO (DOS)
		LET cSQL = '';
		LET cSQL = '/usr/bin/tr "\r" " " < '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||' > '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;

		LET cSQL = '';
		LET cSQL = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'; /usr/bin/mv '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);

		-- GUARDA EL QUERY DEL LOAD
		LET cSQL = '';
		LET cSQL = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" INSERT INTO bdicnweb:sw_cp_cargaarchivotdcTDCOro_tmp(";
		LET cSQL = TRIM(cSQL)||"num_credito,num_tarjeta,prod_destino,domicilio_envio,marca)' | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1";
		--COMMIT WORK;
		SYSTEM TRIM(cSQL);
		--BEGIN WORK;

		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);

		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		FOREACH
			SELECT arch.num_credito,arch.num_tarjeta,arch.prod_destino,arch.domicilio_envio,arch.marca,
			cred.status_cred, tar.tipo_tarjeta, tar.status_tar, tar.numcte, tar.nombre
			INTO cNumCredito, cNumTarjeta, cProdDestino, cDomicilioEnvio, cMarca, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdctdcoro_tmp AS arch,
				 bdicred:"informix".sd_maecred AS cred,
				 bdicred:"informix".sd_tarjeta AS tar
			WHERE arch.num_credito = cred.num_credito
			AND cred.num_credito = tar.num_credito
			AND arch.num_tarjeta = tar.num_tarjeta

			
			INSERT INTO bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro(num_credito,num_tarjeta,prod_destino,domicilio_envio,marca,
			status_cred,tipo_tarjeta,status_tar,numcte,nombre,origen_reg,error_proceso,usuario,nombre_archivo,direccion_mac,fecha_insert)
			VALUES (cNumCredito, cNumTarjeta, cProdDestino, cDomicilioEnvio, cMarca, cStatus_Cred, cTipoTarjeta_Rep, cStatus_Tar, cNumCte_Tar, cNombre_Tar, 'A', '', pUsuario, pNombreArchivo, pDireccionMac, CURRENT);

		END FOREACH;
		LET cNumCredito=''; LET cNumTarjeta=''; LET cDomicilioEnvio = ''; LET cSucursal=''; LET cAceptacion=''; LET cMarca=''; LET cStatus_Cred=''; LET cTipoTarjeta_Rep=''; LET cStatus_Tar=''; LET cNumCte_Tar=''; LET cNombre_Tar='';

		FOREACH

			SELECT num_credito,num_tarjeta,prod_destino,domicilio_envio,marca
			INTO cNumCredito,cNumTarjeta,cProdDestino,cDomicilioEnvio,cMarca
			FROM bdicnweb:"informix".sw_cp_cargaarchivotdctdcoro_tmp

			-- SE AGREGAN VALIDACIONES PARA REGISTRO DE INFORMACIÃN A REPORTERIA
			SELECT tipo_tarjeta,nombre
			INTO cTipoTarjeta_Rep,cNomCliente_Rep
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro
			WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
			AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

			
			LET cMarcaje_Rep = 'NO';
			LET cSolPlastico_Rep = 'NO';

			LET iLinea = iLinea + 1;

		--** NÃMERO DE CRÃDITO **--
			IF NVL(cNumCredito,'') = '' THEN
				LET cCampo = 'NÃMERO DE CRÃDITO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE CRÃDITO';

				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE

				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumCredito, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;

				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE CRÃDITO';
					LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE

					IF LENGTH(cNumCredito) <> 12 THEN
						LET cCampo = 'NÃMERO DE CRÃDITO';
						LET cDesMensajeError = 'EL NÃMERO DE CRÃDITO NO CUMPLE CON LA LONGITUD CORRECTA (12 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE

						SELECT num_credito, num_producto, status_cred
						INTO cNum_Credito, cNum_Producto_Cred, cStatus_Cred
						FROM bdicred:"informix".sd_maecred
										   
						WHERE num_credito = cNumCredito;
										  

						IF NVL(cNum_Credito,'') = '' THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							SELECT num_credito
							INTO cNum_Credito
							FROM bdicred:"informix".sd_tarjeta
							WHERE num_tarjeta = cNumTarjeta;

							IF NVL(cNum_Credito,'') = '' THEN
								LET cDesMensajeError_Rep = 'INFORMACIÃN CARGADA DEL CREDITO Y TARJETA NO COINCIDE CON LA ACTUAL';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;

									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
									SET  status = 'E', error_proceso = 'S', error = cCodRet
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							ELSE
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO NO EXISTE';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;

									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
									SET  status = 'E', error_proceso = 'S', error = cCodRet
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							END IF;

						END IF;

																				 
						IF NVL(UPPER(cStatus_Cred),'') <> 'AA' THEN
							--LET cCampo = 'NÃMERO DE CRÃDITO';
							--AAME RQM 10 682-4 Se identifica el mensaje por el estatus si es vencido o Cancelado
							IF NVL(UPPER(cStatus_Cred),'') IN ('BA','BT') THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							ELIF NVL(UPPER(cStatus_Cred),'') IN ('FF','FI') THEN
								LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA CANCELADO';
							END IF;

							--LET cDesMensajeError_Rep = 'EL NÃMERO DE CRÃDITO SE ENCUENTRA EN ATRASO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;
			END IF;

			--** NÃMERO DE TARJETA **--
			IF NVL(cNumTarjeta,'') = '' THEN
				LET cCampo = 'NÃMERO DE TARJETA';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE TARJETA';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE
				--SOLICITAR sp_cp_validacaractertdc

				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cNumTarjeta, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;

				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'NÃMERO DE TARJETA';
					LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE

					IF LENGTH(cNumTarjeta) <> 16 THEN
						LET cCampo = 'NÃMERO DE TARJETA';
						LET cDesMensajeError = 'EL NÃMERO DE TARJETA NO CUMPLE CON LA LONGITUD CORRECTA (16 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE

						SELECT num_credito, num_tarjeta, tipo_tarjeta, status_tar, numcte, nombre
						INTO cNum_Credito_Tar, cNum_Tarjeta, cTipo_Tar, cStatus_Tar, cNumCte_Tar, cNombre_Tar
						FROM bdicred:"informix".sd_tarjeta
						WHERE num_tarjeta = cNumTarjeta;

						IF NVL(cNum_Tarjeta,'') = '' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO EXISTE';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						END IF;

						IF NVL(UPPER(cStatus_Tar),'') <> 'A' THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO SE ENCUENTRA ACTIVO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						END IF;

						IF NVL(cNum_Credito_Tar,'') <> NVL(cNum_Credito,'') THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE TARJETA NO CORRESPONDE AL NÃMERO DE CRÃDITO REPORTADO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						END IF;

						IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_cargaarchivotdcTDCOro_tmp WHERE num_tarjeta = cNum_Tarjeta) > 1 THEN
							--LET cCampo = 'NÃMERO DE TARJETA';
							LET cDesMensajeError_Rep = 'SE ENCONTRARON NÃMEROS DE TARJETA DUPLICADOS';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						END IF;

						IF NVL(UPPER(cTipo_Tar),'') = 'A' THEN
							IF (SELECT COUNT(num_tarjeta) FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro
								WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac AND
								num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A') > 1 THEN
								--LET cCampo = 'NÃMERO DE TARJETA';
								LET cDesMensajeError_Rep = 'NO SE ENCONTRÃ EL NÃMERO DE TARJETA TITULAR';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;

									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
									SET  status = 'E', error_proceso = 'S', error = cCodRet
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							END IF;

						END IF;
					END IF;
				END IF;
			END IF;

			--** PRODUCTO DESTINO **--
			IF NVL(cProdDestino,'') = '' THEN
				LET cCampo = 'PRODUCTO DESTINO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UN NÃMERO DE PRODUCTO DESTINO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE

				LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cProdDestino, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;

				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'PRODUCTO DESTINO';
					LET cDesMensajeError = 'EL NÃMERO DE PRODUCTO DESTINO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE

					IF LENGTH(cProdDestino) <> 4 THEN
						LET cCampo = 'PRODUCTO DESTINO';
						LET cDesMensajeError = 'EL NÃMERO DE PRODUCTO DESTINO NO CUMPLE CON LA LONGITUD CORRECTA (4 DÃGITOS)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE

						SELECT num_credito, num_producto, status_cred
						INTO cNum_Credito, cNum_Producto_Cred, cStatus_Cred
						FROM bdicred:"informix".sd_maecred
						WHERE num_credito = cNumCredito;

						IF cProdDestino = cNum_Producto_Cred THEN
							--LET cCampo = 'PRODUCTO DESTINO';
							LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO ES VÃLIDO';
							--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
							--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

							UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
							WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
							AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
							cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
							INTO cCodRetSp,cDesCodRetSp;

							IF cCodRetSp::INTEGER < 0 THEN
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
							ELIF cCodRetSp::INTEGER > 0 THEN
								IF cCodRetSp::INTEGER = 1 THEN
									LET cCodRet = '00003';
								ELIF cCodRetSp::INTEGER = 2 THEN
									LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
								END IF;

								UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
								SET  status = 'E', error_proceso = 'S', error = cCodRet
								WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

								RETURN cCodRet,cBanDetError;
							END IF;
							LET iLineaError_Rep = iLineaError_Rep + 1;
							LET cDesMensajeError_Rep = '';
							CONTINUE FOREACH;
						ELSE

							LET cSiglasProdAct = SUBSTR(cNum_Producto_Cred,1,2);
							LET cSiglasProdUpd = SUBSTR(cProdDestino,1,2);
							--SOLICITAR sp_consulta_prod_upgrade
							FOREACH
								EXECUTE PROCEDURE bdicred:"informix".sp_consulta_prod_upgrade('001', cSiglasProdAct, cSiglasProdUpd)
								INTO cCodRetSp,cDesCodRetSp,cNomProdUpd,cProdUpd

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_consulta_prod_upgrade';
								END IF;
							END FOREACH;

							IF cProdDestino <> NVL(cProdUpd,'') THEN
								--LET cCampo = 'PRODUCTO DESTINO';
								LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO ES VÃLIDO';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;

									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
									SET  status = 'E', error_proceso = 'S', error = cCodRet
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							END IF;

						END IF;

						IF NVL(UPPER(cTipo_Tar),'') = 'A' THEN
							IF cProdDestino <> NVL((SELECT prod_destino FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro
													WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac AND
													num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A'),'') THEN
								--LET cCampo = 'PRODUCTO DESTINO';
								LET cDesMensajeError_Rep = 'EL NÃMERO DE PRODUCTO DESTINO NO CORRESPONDE AL NÃMERO DE PRODUCTO DESTINO REPORTADO EN EL NÃMERO DE TARJETA TITULAR';
								--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
								--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

								UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
								WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

								EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
								cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
								INTO cCodRetSp,cDesCodRetSp;

								IF cCodRetSp::INTEGER < 0 THEN
									RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
								ELIF cCodRetSp::INTEGER > 0 THEN
									IF cCodRetSp::INTEGER = 1 THEN
										LET cCodRet = '00003';
									ELIF cCodRetSp::INTEGER = 2 THEN
										LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
									END IF;

									UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
									SET  status = 'E', error_proceso = 'S', error = cCodRet
									WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

									RETURN cCodRet,cBanDetError;
								END IF;
								LET iLineaError_Rep = iLineaError_Rep + 1;
								LET cDesMensajeError_Rep = '';
								CONTINUE FOREACH;
							END IF;
						END IF;

					END IF;
				END IF;
			END IF;
				--VALIDAR QUE FUNCIONE CON EL NUM 4 (NUEVO)
			--** DOMICILIO DE ENVÃO **--
			IF NVL(cDomicilioEnvio,'') = '' THEN
				LET cCampo = 'TIPO ENVÃO';
				LET cDesMensajeError = 'NO HA PROPORCIONADO UNA CLAVE DE ENVÃO';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE

                LET cCaracterInvalido = 'f';
				EXECUTE PROCEDURE bdicnweb:"informix".sp_cp_validacaractertdc(pUsuario, pIdFuncion, cDomicilioEnvio, 'N')
				INTO cIdCodRetSp, cCaracterInvalido;

				IF cCaracterInvalido = 't' THEN
					LET cCampo = 'TIPO ENVÃO';
					LET cDesMensajeError = 'EL TIPO DE ENVÃO NO ES UN DATO NUMÃRICO';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				ELSE

					IF LENGTH(cDomicilioEnvio) <> 1 THEN
						LET cCampo = 'TIPO ENVÃO';
						LET cDesMensajeError = 'EL TIPO DE ENVÃO NO CUMPLE CON LA LONGITUD CORRECTA (1 DÃGITO)';
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
						VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
					ELSE
						-- SI ES NUM 4 PASA EL REGISTRO SINO REGISTRA EN BITACORA Y SALE DEL PROCESO
						
					END IF;
				END IF;
				--AAME RQM 10 682-4 Se quita IF NOT EXITS
				LET cDomicilioEnvio = TRIM(cDomicilioEnvio);
				SELECT tipo_dir
				INTO ctipodir
				FROM bdinteg:"informix".si_tipo_dir_upg
				WHERE empresa ='001' AND tipo_dir ='4' AND tipo_dir = cDomicilioEnvio;

				IF NVL(ctipodir,'') = '' THEN
					--LET cCampo = 'DOMICILIO DE ENVÃO';
					LET cDesMensajeError_Rep = 'EL TIPO DE ENVÃO NO ES CORRECTO';
					--INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					--VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);

					UPDATE bdicnweb:"informix".sw_cp_procesadetallearchivotdcTDCOro SET error_proceso = 'N'
					WHERE num_credito = cNumCredito AND num_tarjeta = cNumTarjeta
					AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;

					EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdcoro(cNumCredito,cNumTarjeta,cProdDestino,
					cTipoTarjeta_Rep,cNomCliente_Rep,'1',cMarcaje_Rep,cSolPlastico_Rep,cDesMensajeError_Rep,pUsuario,pNombreArchivo,CURRENT)
					INTO cCodRetSp,cDesCodRetSp;

					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:sp_grabadetallearchivotdcoro';
					ELIF cCodRetSp::INTEGER > 0 THEN
						IF cCodRetSp::INTEGER = 1 THEN
							LET cCodRet = '00003';
						ELIF cCodRetSp::INTEGER = 2 THEN
							LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
						END IF;

						UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
						SET  status = 'E', error_proceso = 'S', error = cCodRet
						WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

						RETURN cCodRet,cBanDetError;
					END IF;
					LET iLineaError_Rep = iLineaError_Rep + 1;
					LET cDesMensajeError_Rep = '';
					CONTINUE FOREACH;
				END IF;

				
			END IF;
               -- LET cAceptacion =cAceptacion;
			--** MARCA DE ACEPTACIÃN **--
			IF NVL(TRIM(cMarca),'') = '' THEN
                LET cAceptacion =cAceptacion;
				LET cCampo = 'MARCA DE ACEPTACIÃN';
				LET cDesMensajeError = 'NO HA PROPORCIONADO MARCA DE ACEPTACIÃN';
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
				VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
			ELSE

				IF NVL(cMarca,'') NOT IN ('M','V') THEN
					LET cCampo = 'MARCA DE ACEPTACIÃN';
					LET cDesMensajeError = 'LA MARCA DE ACEPTACIÃN NO PERTENECE A MASTERCARD O VISA';
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrortdc(nombre_archivo,campo,mensaje_error,linea,usuario,direccion_mac)
					VALUES(pNombreArchivo,cCampo,cDesMensajeError,iLinea,pUsuario,pDireccionMac);
				END IF;
			END IF;

			-- SE INICIALIZAN VARIABLES
			LET cTipoTarjeta_Rep = '';
			LET cNomCliente_Rep = '';
			LET cMarcaje_Rep = '';
			LET cSolPlastico_Rep = '';

			-- Se contabilizan errores de negocio (REPORTERÃA)
			IF cDesMensajeError_Rep <> '' THEN
				LET iLineaError_Rep = iLineaError_Rep + 1;
				LET cDesMensajeError_Rep = '';
			END IF;

		END FOREACH;

		--Activa BotÃ³n Errores
		IF cDesMensajeError <> '' THEN
			LET cBanDetError = 't';
		END IF;

		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;

		-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÃN
		IF iLinea = 0 THEN
			LET cCodRet = '01122'; --EL ARCHIVO SELECCIONADO NO ES VÃLIDO, VERIFIQUE

			UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

			RETURN cCodRet,cBanDetError;

		ELSE
			LET iProcesados = iLinea - iLineaError_Rep;
		END IF;
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		LET iLinea = NVL(iLinea,0);
		LET iProcesados = NVL(iProcesados,0);
		LET iLineaError_Rep = NVL(iLineaError_Rep,0);
		
		UPDATE bdicnweb:"informix".sw_cp_statuslecturaarchivotdcTDCOro
		SET  status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError,
		total_registros = iLinea, total_procesados = iProcesados, total_noprocesados = iLineaError_Rep
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;

		LET cLecturaArchivoDatos = 't';
		RETURN cCodRet,cBanDetError;

		--ACTIVAR INSERCIONES A TABLA DE BITACORA
		--CREAR NUEVA TABLA PARA LOS HILOS
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 24/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÃ?N MASIVA',
'DESCRIPCION: SPL encargado de hacer la validaciÃÂ³n de informaciÃÂ³n y la carga de datos a tablas temporales (Cambio de Producto de TDC Masivo ).',
'AUTOR: Uriel CaamaÃÂ±o',
'FECHA: 08/03/2018',
'DESCRIPCION: Se le agregan llaves primarias e ÃÂ­ndices a la tabla sw_cp_cargaarchivotdcTDCOro_tmp.',
'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/04/2021',
'DESCRIPCION: Se modifica para aÃÂ±adir TDC ORO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pp_actualizacategoriapp(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pCategoria CHAR(1), pNumCredito CHAR(20), pNumTarjeta CHAR(20), pBandera CHAR(1))
	RETURNING CHAR(5)	AS codigo_retorno;

	---DECLARACIONES   
	DEFINE cCodRet				CHAR(5); 
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE cEmpresa				CHAR(3);
	DEFINE vNoTarjeta			VARCHAR(20);
	DEFINE cStatusTar   		CHAR(1);
	DEFINE cStatus   			CHAR(2);
	DEFINE iMaximo				INTEGER;
	DEFINE vTipoTarjeta			VARCHAR(20);
	DEFINE iAccesoGratis		INTEGER;
    DEFINE iAccesoGratisAdic	INTEGER;
	DEFINE cMtoVen              DECIMAL(14,2);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET vNoTarjeta			= '';
	LET cStatusTar			= '';
	LET cStatus				= '';
    LET iMaximo				= 0;
	LET cEmpresa			= '001';
    LET vTipoTarjeta		= '';
	LET iAccesoGratis		= 0;
	LET iAccesoGratisAdic	= 0;
	LET cMtoVen  			= 0;
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pp_actualizacategoriapp.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		-- Se validan los parametros de entrada.
		IF NVL(pUsuario,'') = '' OR NVL(pIdFuncion,'') = '' OR NVL(pCategoria,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' OR NVL(pBandera,'') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
			IF pBandera = '1' THEN
			
				SELECT acceso_gratis, acceso_gratis_ad 
				INTO iAccesoGratis, iAccesoGratisAdic
				FROM bdicred:"informix".catcategoriappass 
				WHERE id_categoria = pCategoria;
				
				UPDATE bdicred:"informix".sd_tarjeta_ppass 
				SET categoria = pCategoria,
				accesos = iAccesoGratis,
				accesos_adic = iAccesoGratisAdic
				WHERE num_credito = pNumCredito;			
				
			ELIF pBandera = '0' THEN
			
				SELECT a.status_cred, b.status_tar, nvl(dos.monto_vencido + dos.mto_venc_trasp,0) 
				INTO cStatus, cStatusTar, cMtoVen 
				FROM bdicred:"informix".sd_maecred AS a 
				INNER JOIN bdicred:"informix".sd_maesdos dos on  a.num_credito = dos.num_credito 
				INNER JOIN bdicred:"informix".sd_tarjeta AS b ON a.empresa = b.empresa AND a.num_credito = b.num_credito 
				INNER JOIN bdicred:"informix".sd_tarjeta_ppass AS d ON d.num_tarjeta = b.num_tarjeta AND d.num_credito = b.num_credito 
				WHERE a.empresa = cEmpresa AND a.num_producto = '7000' AND d.numtarjeta_ppass = pNumTarjeta;
				
				IF (cStatus = 'FF') THEN
					LET cCodRet = '01142'; -- EL CREDITO YA ESTA CANCELADO, NO ES POSIBLE REALIZAR LA SOLICITUD
				ELIF (cMtoVen > 0) THEN
					LET cCodRet = '01143'; -- EL CREDITO PRESENTA ATRASO, NO ES POSIBLE REALIZAR LA SOLICITUD
				END IF;
				
				IF cStatusTar <> 'A' THEN
					LET cCodRet = '01144'; -- LA TDC PLATINUM BANCOPPEL ESTA CANCELADA, NO ES POSIBLE REALIZAR LA SOLICITUD
				END IF;
				
			END IF;
			
			
		RETURN cCodRet; 	
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 13/01/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: Mantenimiento a Cuentas Priority Pass', 
'DESCRIPCION: SPL encargado de hacer el mantenimiento a la categoria de plastico Priority Pass',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pp_cambiostatusgeneralpp(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pOperacion CHAR(1), pStatus CHAR(1), pNumCredito CHAR(20), pNumTarjeta CHAR(20))
	RETURNING CHAR(5)	AS codigo_retorno, 
			  CHAR(1)	AS solicita_reposicion,
			  CHAR(20)  AS nuevo_numtarjeta;

	---DECLARACIONES   
	DEFINE cCodRet		CHAR(5); 
	DEFINE iSqlErr		INTEGER;
	DEFINE iIsamErr		INTEGER;
	DEFINE cErrorInfo	CHAR(80);
	DEFINE cEmpresa		CHAR(3);
	DEFINE cStatus		CHAR(2);
	DEFINE vNoTarjeta	VARCHAR(20);
	DEFINE iMaximo		INTEGER;
	DEFINE cReposicion	CHAR(1);
	DEFINE vTipoTarjeta	VARCHAR(20);
	
	DEFINE cNuevoNumTarjeta CHAR(20);

	---INICIALIZACIONES
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cErrorInfo		= '';
	LET cStatus			= '';
	LET cCodRet			= '00000';
	LET vNoTarjeta		= '';
    LET iMaximo			= 0;
	LET cEmpresa		= '001';
	LET cReposicion		= '0';
    LET vTipoTarjeta	= '';
	
	LET cNuevoNumTarjeta   = '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pp_cambiostatusgeneralpp.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		-- Se validan los parametros de entrada.
		IF NVL(pUsuario,'') = '' OR NVL(pIdFuncion,'') = '' OR NVL(pIdFuncion,'') = '' OR NVL(pStatus,'') = '' OR (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
		END IF;
		
		IF pOperacion = 'C' THEN --Activar o Suspender PP
			
			IF (SELECT COUNT (*)
				FROM bdicred:"informix".sd_tarjeta_ppass
				WHERE num_credito = pNumCredito AND status_progppass = pStatus) > 0 THEN 
					LET cCodRet = '01130'; 
			ELSE
				--VALIDAR TITULAR
				SELECT A.tipo_tarjeta 
				INTO vTipoTarjeta
				FROM bdicred:"informix".sd_tarjeta AS A
				INNER JOIN bdicred:"informix".sd_tarjeta_ppass AS B 
				ON B.num_tarjeta = A.num_tarjeta
				WHERE empresa = cEmpresa AND B.numtarjeta_ppass = pNumTarjeta;
		
				IF vTipoTarjeta = 'A' THEN
					LET cCodRet = '01131'; 
					RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
				END IF;	
				
				UPDATE bdicred:"informix".sd_tarjeta_ppass 
				SET status_progppass = pStatus 
				WHERE num_credito = pNumCredito;
						
				IF pStatus = '0' THEN
					IF (SELECT COUNT(*) FROM bdicred:"informix".sd_tarjeta_ppass 
						WHERE num_credito = pNumCredito AND numtarjeta_ppass IS NOT NULL AND TRIM(numtarjeta_ppass) <> '') > 0 THEN
											   
						UPDATE bdicred:"informix".sd_inven_tarppass
						SET status_tar = 'C',
							desc_status = 'Cancelada'
						WHERE numtarjeta_ppass IN (SELECT numtarjeta_ppass 
													FROM bdicred:"informix".sd_tarjeta_ppass 
													WHERE num_credito = pNumCredito);
					END IF;
				END IF;
		 
			END IF;
			
			RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
			
		ELIF pOperacion = '2' THEN -- ReposiciÃ³n PP
			IF ((SELECT  {+AVOID_FULL(bdicred:"informix".sd_info_layout_ppass)} COUNT(numcte) FROM bdicred:"informix".sd_info_layout_ppass WHERE estatus_layout <> 'P' AND pan = pNumTarjeta ) = 0 AND 
					(SELECT COUNT(numcte) FROM bdicred:"informix".sd_tarjeta_ppass WHERE (status_tar = 'R' OR status_tar = 'S') AND numtarjeta_ppass = pNumTarjeta) = 0 ) THEN
					
			IF (SELECT COUNT(*) FROM bdicred:"informix".sd_maecred AS a 
				INNER JOIN bdicred:"informix".sd_tarjeta AS b ON a.empresa = b.empresa AND a.num_credito = b.num_credito 
				INNER JOIN bdinteg:"informix".si_cliente AS c ON a.empresa = c.empresa AND b.numcte = c.numcte 
				INNER JOIN bdicred:"informix".sd_tarjeta_ppass AS d ON d.num_tarjeta = b.num_tarjeta AND d.num_credito = b.num_credito
				INNER JOIN bdicred:"informix".sd_maesdos AS e ON (a.num_credito =  e.num_credito) 
				WHERE a.empresa = cEmpresa 
				  AND a.num_producto = '7000' 
				  AND b.status_tar = 'A'
				  AND a.status_cred IN ('AA','E1')
				  AND (e.monto_vencido + e.mto_venc_trasp) = 0
				  AND d.numtarjeta_ppass = pNumTarjeta) > 0 THEN
				
					SELECT MAX(id_tar_ppass)
						INTO iMaximo 
					FROM bdicred:"informix".sd_inven_tarppass 
					WHERE status_tar <> 'A';
		
					IF (NVL(iMaximo,0) = 0) THEN
						LET cCodRet = '01132';
						RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
					END IF;
				
					UPDATE bdicred:"informix".sd_inven_tarppass SET
						status_tar = 'A',
						desc_status = 'ACTIVA'
					WHERE id_tar_ppass = iMaximo;
		
					SELECT numtarjeta_ppass
						INTO vNoTarjeta
					FROM bdicred:"informix".sd_inven_tarppass				
					WHERE id_tar_ppass = iMaximo;
			
					UPDATE bdicred:"informix".sd_tarjeta_ppass SET
						status_tar = 'S',
						numtarjeta_ppass = vNoTarjeta
					WHERE numtarjeta_ppass = pNumTarjeta AND num_credito = pNumCredito;
					
					IF DBINFO('sqlca.sqlerrd2') <> 0 THEN 
						SELECT numcte INTO cNuevoNumTarjeta
						FROM bdicred:"informix".sd_tarjeta_ppass
						WHERE numtarjeta_ppass = vNoTarjeta AND num_credito = pNumCredito;
						
						--LET cNuevoNumTarjeta = vNoTarjeta;
					ELSE 
						SELECT numcte INTO cNuevoNumTarjeta
						FROM bdicred:"informix".sd_tarjeta_ppass
						WHERE numtarjeta_ppass = pNumTarjeta AND num_credito = pNumCredito;
						
						--LET cNuevoNumTarjeta = pNumTarjeta;
					END IF;
				
			ELSE
				SELECT a.status_cred 
				INTO cStatus 
				FROM bdicred:"informix".sd_maecred AS a 
				INNER JOIN bdicred:"informix".sd_tarjeta AS b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
				INNER JOIN bdicred:"informix".sd_tarjeta_ppass AS d ON d.num_tarjeta = b.num_tarjeta AND d.num_credito = b.num_credito
				WHERE a.empresa = cEmpresa AND a.num_producto = '7000' AND b.status_tar = 'A' AND d.numtarjeta_ppass = pNumTarjeta;
				
				IF (cStatus='FF') THEN
					LET cCodRet = '01137'; -- Cuenta Saldada, no es posible realizar la Solicitud
				ELSE 
					LET cCodRet = '01138'; -- Cuenta con atraso, no es posible realizar la Solicitud
				END IF;
				
			END IF;
			
			ELSE
				LET cCodRet = '01141'; --Ya existe una Solicitud de ReposiciÃ³n Previa para esta tarjeta
			END IF;
			
			RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
			
		ELIF pOperacion = '1' THEN -- Cancelacion
			
			IF (SELECT COUNT(*) 
				FROM bdicred:"informix".sd_tarjeta_ppass 
				WHERE (status_tar = 'A' OR status_tar = 'T')
				AND num_credito = pNumCredito 
				AND numtarjeta_ppass = pNumTarjeta) > 0 THEN
				
				UPDATE bdicred:"informix".sd_tarjeta_ppass SET
					status_tar = 'C'
				WHERE numtarjeta_ppass = pNumTarjeta AND num_credito = pNumCredito;
				
				IF (SELECT COUNT(*) FROM bdicred:"informix".sd_maecred AS a 
					INNER JOIN bdicred:"informix".sd_tarjeta AS b ON a.empresa = b.empresa AND a.num_credito = b.num_credito 
					INNER JOIN bdinteg:"informix".si_cliente AS c ON a.empresa = c.empresa AND b.numcte = c.numcte 
					INNER JOIN bdicred:"informix".sd_tarjeta_ppass AS d ON d.num_tarjeta = b.num_tarjeta AND d.num_credito = b.num_credito
					INNER JOIN bdicred:"informix".sd_maesdos AS e ON (a.num_credito =  e.num_credito)
					WHERE a.empresa = cEmpresa 
					AND a.num_producto = '7000' 
					AND a.status_cred IN ('AA','E1')  
					AND (e.monto_vencido + e.mto_venc_trasp) = 0
					AND d.numtarjeta_ppass = pNumTarjeta) > 0 THEN
					
					LET cReposicion = '1'; 
				
				END IF;
				
			ELSE
				LET cCodRet = '01134';
			END IF;
			
			RETURN cCodRet, cReposicion, cNuevoNumTarjeta;
			
		END IF;	
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 22/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Mantenimiento a Cuentas Priority Pass', 
'DESCRIPCION: SPL encargado de hacer el mantenimiento a la solicitud de plastico Priority Pass',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 16/10/2019',
'DESCRIPCION: Se modifica spl para corregir nombre de campo id_tar_ppass.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/10/2019',
'DESCRIPCION: Se modifica spl para retornar el nÃºmero de cliente perteneciente a la tarjeta que se actualiza en la tabla sd_tarjeta_ppass.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 12/11/2019',
'DESCRIPCION: Se modifica spl para retornar mensajes especificos para la reposicion de tarjeta y se cambia para permitir cancelacion esn estatus T.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardactemoral(pUsuario CHAR(8), 
											  pIdFuncion 		 CHAR(10),
											  pfuncion           CHAR(1),
											  pnumcte            CHAR(20),
											  pstatuscte         CHAR(2),
											  psucursal          CHAR(4),
											  ptp_persona        CHAR(2),
											  ptp_cliente        CHAR(1),
											  prazon_social      CHAR(40),
											  prfc               CHAR(13),
											  pfechaalta         DATE,
											  pnacionalidad      CHAR(2),
											  pnombrecorto       CHAR(30),
											  pnombrecontacto    CHAR(48),
											  ptelefonocontacto  CHAR(13),
											  psufijo            CHAR(2),
											  pgiro              CHAR(20),
											  pactividad_princ   CHAR(3),
											  ppaginainternet    CHAR(30),
                                              pCURP              CHAR(20),
											  pRFCAlt            CHAR(13))
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cNumcte;
					
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumcte CHAR(20);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte;
		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_guardactemoral.out';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcte;
		END IF;
		
		
		
		IF pfuncion NOT IN('A','B','M') THEN
			LET cCodRet = '00292';
			RETURN cCodRet, cNumcte;
		END IF;	
		
		
		IF pfuncion IN ('B', 'M') THEN
			IF pnumcte = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumcte;
			END IF;
			IF LENGTH(pnumcte) <> 9 THEN
				LET cCodRet = '00295';
				RETURN cCodRet, cNumcte;
			END IF;
		END IF;
		
		
		IF pfuncion="A" THEN
			--- Verifica recepcion correcta de datos
			IF psucursal IS NULL  OR ptp_persona IS NULL OR ptp_cliente IS NULL OR prfc IS NULL OR pactividad_princ IS NULL OR pnombrecorto IS NULL OR pgiro IS NULL THEN
					LET cCodRet = "00003";
				   RETURN cCodRet, cNumcte;
			END IF;
		END IF;	
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcte;
		END IF;
		
		
		EXECUTE PROCEDURE bdinteg:"informix".ctemoral(cEmpresa, pfuncion, pnumcte, pstatuscte, psucursal, pUsuario, ptp_persona, ptp_cliente, prazon_social, prfc, pfechaalta,
													  pnacionalidad, pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, pgiro, pactividad_princ, ppaginainternet, pUsuario,
													  pfechaalta,pCURP,pRFCAlt) INTO cCodRetSp, cNumcte;
													  
		IF cCodRetSp = '12a0' THEN
			LET cCodRet = '00296';
			RETURN cCodRet, cNumcte;												
		END IF;
														
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ctemoral';
		ELIF iCodRetSp = 104 THEN
			LET cCodRet = '00022';
			RETURN cCodRet, cNumcte;	
		ELIF iCodRetSp = 105 THEN
			LET cCodRet = '00141';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 111 THEN
			LET cCodRet = '00161';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 112 THEN
			LET cCodRet = '00006';
			RETURN cCodRet, cNumcte;				
		ELIF iCodRetSp = 118 THEN
			LET cCodRet = '00293';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 120 THEN
			LET cCodRet = '00020';
			RETURN cCodRet, cNumcte;			
		END IF;
		RETURN cCodRet, cNumcte;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 27/05/2014',
'DESCRIPCION:  Se inhibe select a la tabla si_actecon ya que es la tabla del giro',
'			   e intentaba buscar la variable que contiene la actividad',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 25/06/2021',
'DESCRIPCION: Se agrega CURP',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardainfoctemoral(pUsuario CHAR(8),										
												  pIdFuncion 		 	CHAR(10),
												  pfuncion           	CHAR(1),
												  pnumcte            	CHAR(20),
												  pstatuscte         	CHAR(2),
												  psucursal          	CHAR(4),
												  ptp_persona        	CHAR(2),
												  ptp_cliente        	CHAR(1),
												  prazon_social      	CHAR(40),
												  prfc               	CHAR(13),
												  pfechaalta         	DATE,
												  pnacionalidad      	CHAR(2),
												  pnombrecorto       	CHAR(30),
												  pnombrecontacto    	CHAR(48),
												  ptelefonocontacto  	CHAR(13),
												  psufijo            	CHAR(2),
												  pgiro              	CHAR(20),
												  pactividad_princ   	CHAR(3),
												  ppaginainternet    	CHAR(30),
												  psecuenciadirecciones SMALLINT,
												  ptipodir 				CHAR(1),
												  pcalle				CHAR(40),
												  pcolonia 				CHAR(60),
												  pmunicipio 			CHAR(5),
												  pentre_calles 		CHAR(40),
												  ppais 				CHAR(3),
												  pentidad 				CHAR(2),
												  plocalidad 			CHAR(3),
												  pcodpostal			CHAR(5),
												  ptipotel1 			CHAR(1),
												  ptelefono1 			CHAR(13),
												  ptipotel2 			CHAR(1),
												  ptelefono2 			CHAR(13),
												  ptipotel3 			CHAR(1),
												  ptelefono3 			CHAR(13),
												  pextension 			CHAR(5),
												  pestado_inegi 		CHAR(2),
												  pmunicipio_inegi 		CHAR(3),
												  plocalidad_inegi 		CHAR(4),
												  pnociudad 			SMALLINT,
												  pnoext 				CHAR(10),
												  pnoint 				CHAR(10),
												  pdepto 				CHAR(6),
												  pnocalle 				INTEGER,
												  pnocolonia 			INTEGER,
												  ppuntocar 			CHAR(1),
												  punihabi 				CHAR(1),
												  pmanz 				SMALLINT,
												  ppotros 				SMALLINT,
												  pandador 				SMALLINT,
												  petapa 				SMALLINT,
												  plote 				SMALLINT,
												  pedif 				SMALLINT,
												  pentrada 				SMALLINT,
												  pobserva 				CHAR(80), 
												  psecuenciaapoderados  INTEGER, 
												  pNumCteApode 			CHAR(20), 
												  pNomApodera 			CHAR(60), 
												  pFecha 				DATE,
												  pEscConstitu   		CHAR(30),
												  pNombNotario   		CHAR(30),
												  pNumNotaria    		CHAR(5),
												  pCdNotaria     		CHAR(30),
												  pFecInscrip    		DATE,
												  pFecConstitu   		DATE,
												  pNumFolMerca   		CHAR(30),
												  pCdFolMerca    		CHAR(30),
												  pEscriPoder    		CHAR(30),
												  pNombNotpd     		CHAR(30),
												  pNumNotariopd  		CHAR(30),
												  pCdNotariopd   		CHAR(30),
												  pFecInscripd   		DATE,
												  pFecEscritupd  		DATE,
												  pFolMercapd    		CHAR(30),
												  pCdFolMercaPd  		CHAR(30),
												  pNomSociedad   		CHAR(30),
												  pEmail         		CHAR(100),
												  pSat_fea       		CHAR(25),
												  pDoc_legal     		CHAR(100),
												  pTpo_Poder     		CHAR(3),
												  pTpo_Admin     		CHAR(3),
												  pTpo_Org       		CHAR(3),
                                                  pCURP                 CHAR(20),
												  pRFCAlt               CHAR(13))
	RETURNING CHAR(5) AS codret,
			  CHAR(20) AS cNumcte;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumcte CHAR(20);
	DEFINE bInTrasaction BOOLEAN;
	
	DEFINE cCodRetLN	   CHAR(6);
	DEFINE sFolio          CHAR(12);
	DEFINE sNumcte         CHAR(20);
	DEFINE sFechaLN        CHAR(10);	
	DEFINE sApellPaterno   CHAR(20);
	DEFINE sApellMaterno   CHAR(20);
	DEFINE sNombre1        CHAR(20);
	DEFINE sNombre2        CHAR(20);	
	DEFINE sFechaNac	   CHAR(10);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	LET bInTrasaction = 'f';
	
	LET cCodRetLN           ='';
	LET sFolio              ='';
	LET sNumcte             ='';       
	LET sFechaLN            ='';
	LET sApellPaterno       ='';
	LET sApellMaterno       ='';
	LET sNombre1            ='';
	LET sNombre2            ='';	
	LET sFechaNac           ='';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
				COMMIT WORK;
				LET bInTrasaction = 't';
		END EXCEPTION WITH RESUME;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_guardainfoctemoralZ.txt';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcte;
		END IF;
		
		-----VALIDA EN LISTA NEGRA-------------------------------------------
        SELECT apell_paterno, apell_materno, nombre1, nombre2 INTO sApellPaterno, sApellMaterno, sNombre1, sNombre2 FROM bdinteg:"informix".si_cliente where numcte = pNumCteApode;
		SELECT fecha_nac INTO sFechaNac FROM bdinteg:"informix".si_ctepf where numcte = pNumCteApode;				
        
        EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra(sNombre1, sNombre2, sApellPaterno, sApellMaterno, sFechaNac) INTO cCodRetLN;

        IF(cCodRetLN = '000002') THEN
            LET cNumcte = 'En lista negra';
			LET cCodRet = '00995';
            
            INSERT INTO bdinteg:"informix".si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
            VALUES('',pNumCteApode,sApellPaterno,sApellMaterno,sNombre1,sNombre2,sFechaNac,TODAY);           
			
			RETURN cCodRet,cNumcte;	
        END IF;        
				
        ----------------------------------------------------------
		
		LET pnombrecontacto = TRIM(pNumCteApode);
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardactemoral(pUsuario, pIdFuncion, pfuncion, pnumcte, pstatuscte, psucursal, ptp_persona, ptp_cliente, prazon_social, prfc,               
											  pfechaalta, pnacionalidad, pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, pgiro, pactividad_princ, ppaginainternet,pCURP,pRFCAlt)    
		INTO cCodRetSp, cNumcte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardactemoral';
		END IF;
		
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
		
		LET pnumcte = cNumcte;
		LET cCodRetSp = '';
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardadireccionesctemoral(pUsuario, pIdFuncion, pfuncion, pnumcte,	psecuenciadirecciones, ptipodir, pcalle, pcolonia, pmunicipio, pentre_calles, 		
																		   ppais, pentidad, plocalidad, pcodpostal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, 		
																		   pextension, pestado_inegi, pmunicipio_inegi, plocalidad_inegi, pnociudad, pnoext, pnoint, pdepto, pnocalle, 			
																		   pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, petapa, plote, pedif, pentrada, pobserva, pSucursal)			
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardadireccionesctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
		
		
		IF pfuncion = 'A' THEN
			LET psecuenciaapoderados = '1';
		END IF;
		
		LET cCodRetSp = '';
		
		SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy
		INTO pfecha
		FROM bdinteg:si_fechas
		WHERE empresa = '001';
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardaapoderadosctemoral(pUsuario, pIdFuncion, pNumCte, psecuenciaapoderados, pNumCteApode, pNomApodera, pFecha) 		
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardaapoderadosctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;
			
		LET cCodRetSp = '';
		LET  pEmail = LOWER(pEmail);
		
		BEGIN;
		EXECUTE PROCEDURE bdicnweb:"informix".sp_guardadatoslegalesctemoral(pUsuario, pIdFuncion, pNumCte, pEscConstitu, pNombNotario, pNumNotaria, pCdNotaria, pFecInscrip, pFecConstitu,   
																			pNumFolMerca, pCdFolMerca, pEscriPoder, pNombNotpd, pNumNotariopd, pCdNotariopd, pFecInscripd, pFecEscritupd,  
																			pFolMercapd, pCdFolMercaPd, pNomSociedad, pEmail, pSat_fea, pDoc_legal, pTpo_Poder, pTpo_Admin, pTpo_Org)														  		
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_guardaapoderadosctemoral';
		END IF;
			
		IF cCodRetSp > 0 THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cNumcte;
		END IF;

		IF bInTrasaction = 't' THEN
			begin;
		END IF;


		LET cCodRet = cCodRetSp;
		RETURN cCodRet, cNumcte;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 28/05/2014',
'DESCRIPCION: Guarda datos,direccion, apoderado y datos legales  de cliente moral',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 03/10/2016',
'DESCRIPCION: Se actualiza para ampliar campo correo a CHAR(100)',
'ID REQUERIMIENTO TASF: CLI-01-10-03-B-0450',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 25/06/2021',
'DESCRIPCION: Se añade CURP',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validafrcctemoral2(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(14), pTipoCte CHAR(1))
                RETURNING CHAR(5) AS codret;            
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;       
        DEFINE iTotal INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;  
        LET iTotal = 0;

        BEGIN   
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_validafrcctemoral2.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' OR pTipoCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                IF pTipoCte NOT IN('M','F') THEN
                        LET cCodRet = '00313';
                        RETURN cCodRet;
                END IF;                      
                
                --SE COMPRUEBA QUE EL RFC NO ESTE ASIGNADO YA A OTRO CLIENTE
                SELECT FIRST 1 1 INTO iTotal  FROM  bdinteg:si_cliente WHERE rfc= pRfc and tpo_persona='02';
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					SELECT FIRST 1 1 INTO iTotal FROM  bdinteg:si_cliente WHERE rfc_alterno= pRfc and tpo_persona='02';
				END IF;
	
                
                IF iTotal > 0 THEN
                        LET cCodRet = '00291';
                        RETURN cCodRet;
                END IF;
        
                RETURN cCodRet; 
        END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 27/05/2014',
'DESCRIPCION: Valida la formato y armado del rfc de un cliente persona moral',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/10/2021',
'DESCRIPCION: Se clona sp y se deja solo la parte de validar si existe en la tabla si_cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consfoliooperacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS folio_oper;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolioOper CHAR(8);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFolioOper = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFolioOper;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consfoliooperacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFolioOper;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cFolioOper;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFolioOper;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT {+INDEX (bdisuc:ss_mae_entradasalida idx01ss_mae_entradasalida)} SKIP pRegistros FIRST pRecuperacion folio_oper 
			INTO cFolioOper
			FROM bdisuc:"informix".ss_mae_entradasalida 
			WHERE sucursal = pSucursal AND fecha_solicitud = pFecha
			ORDER BY folio_oper ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cFolioOper WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01275';
			RETURN cCodRet,cFolioOper;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cFolioOper;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo Folio Operación.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacentrocostos(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipo CHAR(1), pPlaza CHAR(3),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(4)	AS clave,
				  CHAR(45)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(45);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacentrocostos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo ='' OR pPlaza ='' OR pRecuperacion ='' OR pRegistros=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} SKIP pRegistros FIRST pRecuperacion 
			sucursal, sucursal||' ' ||UPPER(nombre)
			INTO cClave, cDescripcion FROM bdinteg:"informix".si_sucursales
			WHERE tpo_sucursal = pTipo AND plaza_cajagen = pPlaza
            ORDER BY sucursal
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cClave, cDescripcion WITH RESUME;
        END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cClave,cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave,cDescripcion;
		END IF;	

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar las sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacentrocostos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipo CHAR(1), pPlaza CHAR(3))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS total;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal  INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacentrocostos_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pPlaza = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotal;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} COUNT(*)
		INTO iTotal FROM bdinteg:"informix".si_sucursales
		WHERE tpo_sucursal = pTipo AND plaza_cajagen = pPlaza;        
	
		RETURN cCodRet, iTotal;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar el total de las sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaplaza(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(3)	AS clave,
				  CHAR(40)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaplaza.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;

		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion 
			plaza, plaza||' ' ||UPPER(descripcion)
			INTO cClave, cDescripcion FROM bdisuc:"informix".ss_proveedores
            ORDER BY plaza
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cClave, cDescripcion WITH RESUME;
        END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cClave,cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave,cDescripcion;
		END IF;	

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar las plazas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaplaza_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS total;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaplaza_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotal;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
         
        SELECT COUNT(*)
		INTO iTotal FROM bdisuc:"informix".ss_proveedores;
		
		RETURN cCodRet, iTotal;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar el total de las plazas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultatipocc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS tipo,
		CHAR(40) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cDescrip CHAR(40);
	DEFINE cTipo CHAR(2);
	DEFINE iTotal INTEGER; 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cDescrip = '';
	LEt cTipo = '';
	LET iTotal= 0;
 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipo,cDescrip;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultatipocc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipo,cDescrip;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipo,cDescrip;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
		SELECT tipo,descripcion
		INTO cTipo,cDescrip
		FROM "informix".sw_cg_catalogotipocc
		ORDER BY tipo ASC

		LET iTotal = iTotal+1;
		
		RETURN cCodRet,cTipo,cDescrip WITH RESUME;	
		END FOREACH;
					
		IF iTotal=0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipo,cDescrip;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: OPERACIONES',
'DESCRIPCION: SPL encargado de recuperar el catalogo de los centros de costos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacora(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaDel DATE, pFechaAl DATE, pNumUsuario CHAR(8), pOperacion CHAR(20),
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_modificacion,
			CHAR(4) AS sucursal,
			CHAR(8) AS folio_operacion,
			CHAR(25) AS tipo_operacion,
			MONEY(16,2) AS monto,
			CHAR(8) AS usuario,
			CHAR(20) AS reverso_cambio;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha_modificacion DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_operacion CHAR(8);
	DEFINE cTipo_operacion CHAR(25);
	DEFINE mMonto MONEY(16,2);
	DEFINE cUsuario CHAR(8);
	DEFINE cReverso_cambio CHAR(20);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha_modificacion = '';
	LET cSucursal = '';
	LET cFolio_operacion = '';
	LET cTipo_operacion = '';
	LET mMonto = 0.00;
	LET cUsuario = '';
	LET cReverso_cambio = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		IF pOperacion='TODAS' THEN 
			LET pOperacion ='';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pNumUsuario = '' AND pOperacion = '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = usuario
				AND reverso_cambio = reverso_cambio
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario <> '' AND pOperacion = '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = pNumUsuario
				AND reverso_cambio = reverso_cambio
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario = '' AND pOperacion <> '' THEN	
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = usuario
				AND reverso_cambio = pOperacion
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario <> '' AND pOperacion <> '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = pNumUsuario
				AND reverso_cambio = pOperacion
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
		END IF;
			
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 14/02/2021',
'DESCRIPCION: Se realiza tratamiento para el parametro pOperacion TODAS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacora_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaDel DATE, pFechaAl DATE, pNumUsuario CHAR(8), pOperacion CHAR(20))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacora_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		IF pOperacion='TODAS' THEN 
			LET pOperacion ='';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pNumUsuario = '' AND pOperacion = '' THEN
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = usuario
			AND reverso_cambio = reverso_cambio;
		ELIF pNumUsuario <> '' AND pOperacion = '' THEN
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = pNumUsuario
			AND reverso_cambio = reverso_cambio;
		ELIF pNumUsuario = '' AND pOperacion <> '' THEN	
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = usuario
			AND reverso_cambio = pOperacion;
		ELIF pNumUsuario <> '' AND pOperacion <> '' THEN	
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = pNumUsuario
			AND reverso_cambio = pOperacion;
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 14/02/2021',
'DESCRIPCION: Se realiza tratamiento para el parametro pOperacion TODAS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportehistoricomovcapcre(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2), pFechaInicial DATE, pFechaFinal DATE, pCancelado CHAR(1), pNumCliente CHAR(20), 
		pCccMayor CHAR(10), pCccSub CHAR(10), pCccSubsub CHAR(10), pCccSssub CHAR(10), pCccSsssub CHAR(10),
		pAccMayor CHAR(10), pAccSub CHAR(10), pAccSubsub CHAR(10), pAccSssub CHAR(10), pAccSsssub CHAR(10),
		pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		CHAR(4) AS sucursal,
		CHAR(20) AS num_cliente,
		CHAR(4) AS producto,
		MONEY(18,2) AS monto_total,
		CHAR(4) AS transaccion,
		CHAR(50) AS descripcion,
		CHAR(1) AS se_contabiliza,
		CHAR(10) AS c_cc_mayor,
		CHAR(10) AS c_cc_sub,
		CHAR(10) AS c_cc_subsub,
		CHAR(10) AS c_cc_sssub,
		CHAR(10) AS c_cc_ssssub,
		CHAR(10) AS a_cc_mayor,
		CHAR(10) AS a_cc_sub,
		CHAR(10) AS a_cc_subsub,
		CHAR(10) AS a_cc_sssub,
		CHAR(10) AS a_cc_ssssub,
		DATE AS fecha_alta,
		CHAR(3) AS codigo_fun, 
		INTEGER AS codigo_ref;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cNumCliente CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE mMontoTotal MONEY(14,2);
	DEFINE cTransaccion CHAR(4);
	DEFINE cDescripcion CHAR(50);
	DEFINE cSeContabiliza CHAR(1);
	DEFINE cCccMayor CHAR(10);
	DEFINE cCccSub CHAR(10);
	DEFINE cCccSubsub CHAR(10);
	DEFINE cCccSssub CHAR(10);
	DEFINE cCccSsssub CHAR(10);
	DEFINE cAccMayor CHAR(10);
	DEFINE cAccSub CHAR(10);
	DEFINE cAccSubsub CHAR(10);
	DEFINE cAccSssub CHAR(10);
	DEFINE cAccSsssub CHAR(10);
	DEFINE cAttrQry CHAR(500);
	DEFINE cAttrAliasQry CHAR(500);
	DEFINE cFromQry CHAR(500);
	DEFINE cWhereQry CHAR(500);
	DEFINE cAndQry CHAR(500);
	DEFINE cQry CHAR(1500);
	DEFINE cQryHist CHAR(1500);
	DEFINE dFechaAlt DATE;
	DEFINE cCodigoFun CHAR(3); 
	DEFINE iCodigoRef INTEGER;
	DEFINE cATR        CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCuenta = '';
	LET cSucursal = '';
	LET cNumCliente = '';
	LET cProducto = '';
	LET mMontoTotal = NULL;
	LET cTransaccion = '';
	LET cDescripcion = '';
	LET cSeContabiliza = '';
	LET cCccMayor = '';
	LET cCccSub = '';
	LET cCccSubsub = '';
	LET cCccSssub = '';
	LET cCccSsssub = '';
	LET cAccMayor = '';
	LET cAccSub = '';
	LET cAccSubsub = '';
	LET cAccSssub = '';
	LET cAccSsssub = '';
	LET cAttrQry = '';
	LET cAttrAliasQry = '';
	LET cFromQry = '';
	LET cWhereQry = '';
	LET cAndQry  = '';
	LET cQry = '';
	LET cQryHist = '';
	LET dFechaAlt = NULL;
	LET cCodigoFun = ''; 
	LET iCodigoRef = 0;
	LET cATR = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportehistoricomovcapcre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL 
			OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validacción de acceso a la funcionalidad, dependiendo si trae numero de cliente o no
		IF pNumCliente = '' or pNumCliente = 'null' THEN
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		ELSE
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCliente, pSistemaCuenta, '2') INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		END IF;
		
		
		-- Validación de los parametros de paginado
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validación del sistema cuenta
		IF pSistemaCuenta NOT IN ('01', '06') THEN
			LET cCodRet = '00109';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validación del parametro de reversado
		IF pSistemaCuenta = '01' AND TRIM(pCancelado) <> '' AND pCancelado <> 'S' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		ENd IF;
		
		-- Armado de los atributos
		IF pSistemaCuenta = '01' THEN
			LET cAttrAliasQry = 'cuenta, sucursal, num_cte, producto, monto_tot, transacc, descripcion, se_contabiliza, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, fech_alt, codfun, codref';
			LET cAttrQry = 'a.cuenta, a.sucursal, b.num_cte, a.producto, a.monto_tot, a.transacc, upper(c.descripcion) as descripcion, c.se_contabiliza, d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub, d.c_ccssssub, d.a_ccmayor, d.a_ccsub, d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, a.fech_alt, "" as codfun, 0 as codref';
			LET cFromQry = ', bdicheq:sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d';
			LET cWhereQry = 'b.cuenta = a.cuenta and c.numero = a.transacc and d.transaccion = a.transacc and d.producto = a.producto and a.fech_alt between "'||pFechaInicial||'" and "'||pFechaFinal||'"';
			LET cAndQry = 'a.transacc in ("0283", "0282", "0887", "0881")';
			
			-- Movimientos reversados
			IF pCancelado = 'S' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and a.cancelad = 'S'";
			ELSE
				LET cWhereQry = TRIM(cWhereQry)||" and a.cancelad <> 'S'";
			END IF;
			
			IF pNumCliente <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and b.num_cte = '"||TRIM(pNumCliente)||"'";
			END IF;
			
			-- Cargos
			IF pCccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccmayor = '"||TRIM(pCccMayor)||"'";
			END IF;
			
			IF pCccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsub = '"||TRIM(pCccSub)||"'";
			END IF;
			
			IF pCccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsubsub = '"||TRIM(pCccSubsub)||"'";
			END IF;
			
			IF pCccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsssub = '"||TRIM(pCccSssub)||"'";
			END IF;
			
			IF pCccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccssssub = '"||TRIM(pCccSsssub)||"'";
			END IF;
			
			-- Abonos
			IF pAccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccmayor = '"||TRIM(pAccMayor)||"'";
			END IF;
			
			IF pAccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsub = '"||TRIM(pAccSub)||"'";
			END IF;
			
			IF pAccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsubsub = '"||TRIM(pAccSubsub)||"'";
			END IF;
			
			IF pAccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsssub = '"||TRIM(pAccSssub)||"'";
			END IF;
			
			IF pAccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccssssub = '"||TRIM(pAccSsssub)||"'";
			END IF;
			
			LET cQry = 'select '||TRIM(cAttrQry)||' from bdicheq:sc_movdia a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			LET cQryHist = 'select '||TRIM(cAttrQry)||' from bdicheq:sc_movhis a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			
		ELIF pSistemaCuenta = '06' THEN
			
			LET cAttrAliasQry = 'num_credito, sucursal, numcte, num_producto, monto, transacc, descripcion, se_contabiliza, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, fech_alt, codfun, codref';
			LET cAttrQry = 'a.num_credito, a.sucursal, b.numcte, a.num_producto, a.monto, c.transacc, upper(d.descripcion) as descripcion, d.se_contabiliza, e.c_ccmayor, e.c_ccsub, e.c_ccsubsub, e.c_ccsssub, e.c_ccssssub, e.a_ccmayor, e.a_ccsub, e.a_ccsubsub, e.a_ccsssub, e.a_ccssssub, a.fecha_mov as fech_alt, c.codigo_fun as codfun, c.codigo_ref as codref';
			LET cFromQry = ', bdicred:sd_maecred b, bdicred:sd_transfun c, bdinteg:si_transacc d, bdinteg:si_prodtran e';
			
			--Valida si esta activo el IFRS	
			select NVL(valor,'I') 
			  into cATR 
			  from bdicred:"informix".sd_param 
			 where cod_param = '700';
			
			IF (cATR = 'I') THEN 
				LET cWhereQry = 'b.num_credito = a.num_credito and c.codigo_fun = a.codigo_fun and c.transacc = a.transacc_suc and d.numero = c.transacc and e.transaccion = a.transacc_suc and e.sistema = "'||TRIM(pSistemaCuenta)||'" and a.fecha_mov between "'||pFechaInicial||'" and "'||pFechaFinal||'"';
			ELSE
				LET cWhereQry = 'b.num_credito = a.num_credito and c.codigo_fun = a.codigo_fun and c.transacc = a.transacc_suc and d.numero = c.transacc_ifrs and e.transaccion = c.transacc_ifrs and e.sistema = "'||TRIM(pSistemaCuenta)||'" and a.fecha_mov between "'||pFechaInicial||'" and "'||pFechaFinal||'"';			
			END IF;
			
			LET cAndQry = 'a.transacc_suc in ("7730", "6887", "6881", "6282")';
			
			-- Cargos
			IF pCccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccmayor = '"||TRIM(pCccMayor)||"'";
			END IF;
			
			IF pCccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsub = '"||TRIM(pCccSub)||"'";
			END IF;
			
			IF pCccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsubsub = '"||TRIM(pCccSubsub)||"'";
			END IF;
			
			IF pCccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsssub = '"||TRIM(pCccSssub)||"'";
			END IF;
			
			IF pCccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccssssub = '"||TRIM(pCccSsssub)||"'";
			END IF;
			
			-- Abonos
			IF pAccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccmayor = '"||TRIM(pAccMayor)||"'";
			END IF;
			
			IF pAccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsub = '"||TRIM(pAccSub)||"'";
			END IF;
			
			IF pAccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsubsub = '"||TRIM(pAccSubsub)||"'";
			END IF;
			
			IF pAccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsssub = '"||TRIM(pAccSssub)||"'";
			END IF;
			
			IF pAccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccssssub = '"||TRIM(pAccSsssub)||"'";
			END IF;
			
			LET cQry = 'select '||TRIM(cAttrQry)||' from bdicred:sd_movdia a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			LET cQryHist = 'select '||TRIM(cAttrQry)||' from bdicred:sd_movhis a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
		END IF;
		
		-- Ejecución de la consulta
		PREPARE sqlQry FROM 'select skip '||pRegistros||' first '||pRecuperacion||' '||TRIM(cAttrAliasQry)||' from ('||TRIM(cQry)||' union '||TRIM(cQryHist)||') order by fech_alt';
		DECLARE sqlCur CURSOR FOR sqlQry;
		OPEN sqlCur;
			
		FETCH sqlCur INTO cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
				cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
				dFechaAlt, cCodigoFun, iCodigoRef;		
		
		IF SQLCODE == 100 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
			
			IF pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		END IF;
		
		WHILE(SQLCODE == 0)
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef WITH RESUME;
			FETCH sqlCur INTO cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
		END WHILE;
		
		CLOSE sqlCur;
		FREE sqlCur;
		FREE sqlQry;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 20/11/2013",
"DESCRIPCION: Consulta los movimientos hitoricos de captación y credito";

CREATE PROCEDURE "informix".sp_cb_genrepcuentasatraspasar(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumDiasSMVDF SMALLINT,pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE dValorSM DECIMAL(14,2);
	DEFINE iNoAnios SMALLINT;
	DEFINE cnum_cte CHAR(20);
	DEFINE ccuenta CHAR(20);
	DEFINE ccliente CHAR(104);
	DEFINE dsdocon  DECIMAL(18,2);
	DEFINE dsdofin  DECIMAL(14,2);
	DEFINE dfechapago DATE;
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);
	DEFINE dTotal DECIMAL(16,2);
	DEFINE pIdMensaje CHAR(10);
	
	DEFINE vAcum_sdo_int DECIMAL(14,2);
	DEFINE vInts_prov_acum DECIMAL(14,2);
	DEFINE vFechaHoy DATE;
	DEFINE iAnio SMALLINT;
	DEFINE dResiduo DECIMAL(6,2); 
	DEFINE iAniobase SMALLINT;
	DEFINE dPorRetencionSuj	DECIMAL(9,6);
	DEFINE cPfisica	CHAR(1);
	DEFINE cExento_isr	CHAR(1);
	DEFINE cTipoPersona	CHAR(1);
	DEFINE cSujRet CHAR(1);
	DEFINE dPorRetSuj DECIMAL(9,6);
	DEFINE vbase_exenta DECIMAL(14,2);
	DEFINE iDias SMALLINT;
	DEFINE vBase_gravable	DECIMAL(14,2);
	DEFINE vIsrCalc         DECIMAL(14,2);
	DEFINE vValSaldo DECIMAL(14,2);
	
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
	LET cCodRetSp='00000';

	LET dValorSM = 0.0;
	LET iNoAnios = 3;
	LET cnum_cte ='';
	LET ccuenta ='';
	LET ccliente ='';
	LET dsdocon  =0.0;
	LET dsdofin  =0.0;
	LET dfechapago = DATE(1);
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET dTotal =0;
	LET pIdMensaje='WEB_ART61';
	
	LET vInts_prov_acum = 0.00;
	LET vAcum_sdo_int = 0.00;
	LET vFechaHoy  = '';
	LET iAnio	 = 0;
	LET dResiduo = 0.00;
	LET iAniobase = 0;
	LET dPorRetencionSuj = 0.000000;
	LET cPfisica = '';
	LET cExento_isr  = '';
	LET cTipoPersona  = '';
	LET cSujRet  = '';
	LET dPorRetSuj  = 0.000000;
	LET vbase_exenta = 0.00;
	LET iDias  = 0;
	LET vBase_gravable = 0.00;
	LET vIsrCalc    = 0.00;
	LET vValSaldo = 0.00;
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cb_genrepcuentasatraspasar.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR  NVL(pNumDiasSMVDF,0) = 0 THEN
			LET cCodRet = '00003';		
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';	
		     EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT nombre INTO cNombre FROM bdinteg:"informix".si_ejecut where ejecutivo = pUsuario;
		
		 -- SE LIMPIA TABLA POR USUARIO
 
        DELETE FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;

		DELETE FROM "informix".sw_verificastatusrepcuentasatraspasar
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusrepcuentasatraspasar(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error) 
		VALUES(pUsuario,'','I','','LECTURA','');
		
		--CONSULTA VALOR SMDF
		SELECT valor * pNumDiasSMVDF
		INTO   dValorSM
		FROM   bdicheq:sc_param
		WHERE  codparam = 'smdf';
		
		--BASE EXENTA PARA COBRO DE ISR
	    SELECT valor 
        INTO   vbase_exenta
        FROM   bdicheq:sc_param
        WHERE  empresa = "001"
        AND    codparam = "baseexenta";
		
		-- // OBTINENE LA FECHA DE HOY
        SELECT fecha_hoy
        INTO   vFechaHoy
        FROM   bdicheq:sc_fechas
        WHERE  empresa = "001";
		
		
	    -- CONSULTA DE CUENTAS		
        FOREACH WITH HOLD			   
		        SELECT con.num_cte,con.cuenta,con.cliente,con.sdo_concentrado,con.sdo_concentrado,con.fecha_concentra,
		               noc.acum_sdo_int,con.ints_prov_acum
				INTO   cnum_cte,ccuenta,ccliente,dsdocon,dsdofin,dfechapago,
				       vAcum_sdo_int,vInts_prov_acum
		        FROM   bdicheq:sc_cuentas_concentradas con, 
                       bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc,
                       bdicheq:sc_fechas fec
                WHERE  DATE(con.fecha_concentra) <= DATE((fec.pri_dia_mes - 1 UNITS DAY)) - (365 * iNoAnios)
                AND    mae.cuenta = con.cuenta
                AND    mae.status_cta = '6'
                AND    (con.sdo_concentrado >= 0 AND con.sdo_concentrado <= dValorSM )
                AND    noc.empresa = mae.empresa
                AND    noc.cuenta  = mae.cuenta
                AND    fec.empresa = mae.empresa
			    AND    con.fecha_concentra = (SELECT MAX(a.fecha_concentra)
                                              FROM   bdicheq:sc_cuentas_concentradas as a
                                              WHERE  a.cuenta = con.cuenta)
											  
											  
											  
			    -- // DETERMINA COBRO DE ISR
                LET iAnio = year(vFechaHoy);
                LET dResiduo = mod(iAnio, 4);

                IF  dResiduo = 0 THEN
                    LET iAniobase = 366;
                ELSE
                    LET iAniobase = 365;
                END IF;
        
                SELECT valor
                INTO   dPorRetencionSuj
                FROM   bdinteg:si_fechavalor
                WHERE  tasa = 'I.S.R.'
                AND    fecha = ( SELECT MAX(fecha) FROM bdinteg:si_fechavalor WHERE tasa = 'I.S.R.' );
           
		        SELECT tip.es_fisica, tip.exento_isr 
			    INTO   cPfisica,      cExento_isr
			    FROM   bdicheq:sc_maechq  mae,
		               bdinteg:si_cliente cte,
		               bdinteg:si_tipper  tip
                WHERE  mae.cuenta = ccuenta
	            AND    cte.numcte = mae.num_cte
	            AND    tip.tpo_persona = cte.tpo_persona;

                IF cPfisica = 'S' THEN
                    LET cTipoPersona = 'F';
                ELSE
                    LET cTipoPersona = 'M';
                END IF;
                 
                IF cExento_isr = 'N' THEN
                    LET cSujRet = 'S';
                ELSE
                    LET cSujRet = 'N';
                END IF;
                
                IF cSujRet <> 'S' THEN
                    LET dPorRetSuj = 0;
                ELSE
                    LET dPorRetSuj = dPorRetencionSuj;
                END IF;
                
                IF vbase_exenta is null THEN
                    LET vbase_exenta = 0;
                END IF;
        
                LET iDias = vFechaHoy - dfechapago;
		        LET vBase_gravable = dsdocon - vbase_exenta;
        
                IF  dPorRetSuj <> 0 THEN
                    IF cTipoPersona = 'F' THEN
                        IF vBase_gravable > 0 THEN
                            LET vIsrCalc = (vBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase;
                        ELSE
                            LET vIsrCalc = 0;
                        END IF;
                    ELSE
                        LET vIsrCalc = (dsdocon * (dPorRetSuj/100)) * iDias / iAniobase;
                    END IF;
                ELSE
                    LET vIsrCalc = 0;
                END IF;
			
			    --DE MOMENTO ESTA EN CODIGO DURO YA QUE NO SE REQUIERE COBRAR UN INTERES, SI EN ALGUN MOMENTO SE REQUIERE SOLO SE LIBERA LA LINEA. 
			    LET vIsrCalc = 0.00;
                
		        --- VALIDA SI LA CUENTA SUPERA LOS SALARIOS MINIMOS  AL SUMAR EL SALDO CONCENTRADO + INTERESES - ISR.  
		        LET vValSaldo = NVL(dsdocon,0.00) + NVL(vAcum_sdo_int,0.00) + NVL(vInts_prov_acum,0.00) - NVL(vIsrCalc,0.00);
		   
		        IF  vValSaldo <=  dValorSM  THEN 
		            INSERT INTO "informix".sw_cb_reportecuentasatraspasartmp(usuario, num_cte, num_cta, nom_cte, saldo_con, saldo_fin, fecha_con) 
		            VALUES(pUsuario,cnum_cte,ccuenta,ccliente,dsdocon,vValSaldo,dfechapago);
				END IF;

		END FOREACH; 
		
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';	
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
		
		SELECT SUM(saldo_con) INTO dTotal FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'NÃMERO DE CLIENTE','NÃMERO DE CUENTA','NOMBRE DEL CLIENTE','SALDO CONCENTRADO','SALDO FINAL','FECHA DE CONCENTRACIÃN' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT num_cte::CHAR(20), num_cta::CHAR(20),nom_cte::CHAR(104),saldo_con::CHAR(20),saldo_fin::CHAR(18),LPAD(DAY(fecha_con),2,0)||'/'||LPAD(MONTH(fecha_con),2,0)||'/'||YEAR(fecha_con) FROM ""informix"".sw_cb_reportecuentasatraspasartmp WHERE usuario ='"||pUsuario||"'"; 
       			
		LET cFechaHoraArchivo = LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||YEAR(dFechaHoy);
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'Cuentas_a_enviar_beneficencia_'||TRIM(cFechaHoraArchivo)||'.txt';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        
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

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   DELETE FROM "informix".sw_ctrlgenreportesart WHERE nombre_reporte = TRIM(cNombreArchivo);
			     INSERT INTO "informix".sw_ctrlgenreportesart(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			    VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,'1');
			   
	    UPDATE "informix".sw_verificastatusrepcuentasatraspasar
		SET  status = 'T', error_proceso = 'N', nombre_archivo=cNombreArchivo
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
                
                -- SE ENVIA LA NOTIFICACIÃN DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),iTotal,'EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',dTotal,0,0,0,0,'', '') INTO cCodRetSp;
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/07/2021',
'DESCRIPCION: SPL que genera el Reporte de las cuentas a traspasar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cb_genrepcuentastraspasadas(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATE,pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE dValorSM DECIMAL(14,2);
	DEFINE iNoAnios SMALLINT;
	DEFINE cnum_cte CHAR(20);
	DEFINE ccuenta CHAR(20);
	DEFINE ccliente CHAR(104);
	DEFINE dsdocon  DECIMAL(18,2);
	DEFINE dsdofin  DECIMAL(14,2);
	DEFINE dfechapago DATE;
	DEFINE dfechatran DATE;
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);
	DEFINE dTotal DECIMAL(16,2);
	DEFINE pIdMensaje CHAR(10);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
    LET cCodRetSp ='00000';
	
	LET dValorSM = 0.0;
	LET iNoAnios = 3;
	LET cnum_cte ='';
	LET ccuenta ='';
	LET ccliente ='';
	LET dsdocon  =0.0;
	LET dsdofin  =0.0;
	LET dfechapago = DATE(1);
	LET dfechatran = DATE(1);
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET dTotal =0;
	LET pIdMensaje='WEB_ART61';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/informix/rsv/bene/sp_cb_genrepcuentastraspasadas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR  pFecha = '' THEN
			LET cCodRet = '00003';		
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;
		
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			 EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT nombre INTO cNombre FROM bdinteg:"informix".si_ejecut where ejecutivo = pUsuario;
		
		 -- SE LIMPIA TABLA POR USUARIO
 
        DELETE FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;

		DELETE FROM "informix".sw_verificastatusrepcuentastraspasadas
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusrepcuentastraspasadas(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error) 
		VALUES(pUsuario,'','I','','LECTURA','');
	
		-- CONSULTA DE CUENTAS		
		FOREACH WITH HOLD			   
		SELECT cb.num_cte, cb.cuenta, cb.cliente, cb.sdo_concentrado, cb.sdo_trasp_beneficiencia, cb.fecha_concentra, cb.fecha_trasp_benefic
		INTO   cnum_cte  , ccuenta  , ccliente  , dsdocon           , dsdofin,                    dfechapago,         dfechatran
		FROM   bdicheq:sc_cuentas_concentradas cb, 
               bdicheq:sc_maechq mae   
        WHERE  cb.cuenta = mae.cuenta
        AND    cb.fecha_trasp_benefic= pFecha
        AND    mae.status_cta        = '2'
        AND    mae.motivo            ='14'

		INSERT INTO "informix".sw_cb_reportecuentastraspasadastmp(usuario, num_cte, num_cta, nom_cte, saldo_con, saldo_fin, fecha_con,fecha_tra) 
		VALUES(pUsuario,cnum_cte,ccuenta,ccliente,dsdocon,dsdofin,dfechapago,dfechatran);

		END FOREACH; 
		
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';	
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
           
		SELECT SUM(saldo_con) INTO dTotal FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;		   
		   
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'NÃMERO DE CLIENTE','NÃMERO DE CUENTA','NOMBRE DEL CLIENTE','SALDO CONCENTRADO','SALDO FINAL','FECHA DE CONCENTRACIÃN','FECHA DE TRANSFERENCIA' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT num_cte::CHAR(20), num_cta::CHAR(20),nom_cte::CHAR(104),saldo_con::CHAR(20),saldo_fin::CHAR(18),LPAD(DAY(fecha_con),2,0)||'/'||LPAD(MONTH(fecha_con),2,0)||'/'||YEAR(fecha_con),LPAD(DAY(fecha_tra),2,0)||'/'||LPAD(MONTH(fecha_tra),2,0)||'/'||YEAR(fecha_tra) FROM ""informix"".sw_cb_reportecuentastraspasadastmp WHERE usuario ='"||pUsuario||"'";        
       				
		LET cFechaHoraArchivo = LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||YEAR(dFechaHoy);
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'Cuentas_enviadas_beneficencia_'||TRIM(cFechaHoraArchivo)||'.txt';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        
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

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   DELETE FROM "informix".sw_ctrlgenreportesart WHERE nombre_reporte = TRIM(cNombreArchivo);
			   INSERT INTO "informix".sw_ctrlgenreportesart(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			   VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,'2');
		
			   
	    UPDATE "informix".sw_verificastatusrepcuentastraspasadas
		SET  status = 'T', error_proceso = 'N', nombre_archivo=cNombreArchivo
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';

       
        -- SE ENVIA LA NOTIFICACIÃN DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),iTotal,'EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',dTotal,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
					
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/07/2021',
'DESCRIPCION: SPL que genera el Reporte de las cuentas traspasadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sac_verificastatusctaside(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '00000';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sac_verificastatusctaside.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,error_proceso,error_code
		INTO cStatus,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificactaside 
		WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','';
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA 16/12/2021',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar la ejecucion del proceso en la tabla sw_verificasacmontototal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasoctaside(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
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
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasoctaside.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".sw_verificactaside WHERE usuario = TRIM(pUsuario);
	
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_verificactaside(usuario,status,error_proceso,error_code)
		VALUES(pUsuario,'I','',TRIM(cCodRet));  
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_ide_soc(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_traspasocuentas_ide_soc';
		END IF;
		
		UPDATE bdicnweb:"informix".sw_verificactaside
		SET status = 'T', error_proceso = 'N', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de cuentas ide.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 16/12/2021',
'MODIFICACION: Se realiza tratamiento de volumen',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tc_consultalotepend(pUsuario CHAR(8), pIdFuncion CHAR(10),pSucursal CHAR(4))
	RETURNING CHAR(5) AS codret,
			  CHAR(4) AS sucursal, 
			  CHAR(1) AS tipo_tar, 
			  INTEGER AS num_env, 
			  INTEGER AS ran_ini, 
			  INTEGER AS ran_fin, 
			  CHAR(1) AS status, 
			  CHAR(10) AS fecha;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cSucursal CHAR(4);
	DEFINE cTipoTarjeta CHAR(1);
    DEFINE iNumEnvio INTEGER;
	DEFINE iRangoIni INTEGER;
	DEFINE iRangoFin INTEGER;
    DEFINE cStatus CHAR(1);
	DEFINE dFechaSurtido DATE;
	DEFINE cFecha CHAR(10);
	
	LET cCodRet = '00000';
    LET cSucursal = '';
	LET cCodRetSp = '00000';
	LET iSqlErr = 0;
	LET cTipoTarjeta = '';
    LET iNumEnvio = 0;
	LET iRangoIni = 0;
	LET iRangoFin = 0;
    LET cStatus	= '';
	LET dFechaSurtido = '';	
	LET cFecha = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tc_consultalotepend.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		FOREACH 
		
		EXECUTE PROCEDURE bditarjcop:"informix".sp_conslotepend(pSucursal, '001')
		INTO cCodRetSp, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido

		IF cCodRetSp::INTEGER = 1 THEN
		LET cCodRet = '01276';
		RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		ELSE
		LET cFecha = LPAD(DAY(dFechaSurtido),2,0)||'/'||LPAD(MONTH(dFechaSurtido),2,0)||'/'||YEAR(dFechaSurtido);
		RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha WITH RESUME;
		END IF
		END FOREACH;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA 21/01/2022',
'FUNCIONALIDAD: TARJETAS COPPEL',
'DESCRIPCION: SPL que ejecuta el sp productivo sp_conslotepend',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_obtienegrupo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSol CHAR(12))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS tipogrupo, 
				  CHAR(6) AS hit;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSP CHAR(6);
	DEFINE cTipo CHAR(2);
	DEFINE cHit CHAR(6);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP = '000000';
	LET cTipo ='';
	LET cHit ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipo,cHit;  
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_obtienegrupo.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumSol ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipo,cHit; 
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipo,cHit; 
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo(pNumSol) INTO cCodRetSP,cTipo,cHit; 
		
		IF cCodRetSP ='000000' THEN
			LET cCodRet ='00000';
		END IF;
        
		RETURN cCodRet,cTipo,cHit;   
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio Estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_obtienegrupo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_obtienecompingresos_mc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(60) as comprobante;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cComprobante CHAR(60);
	DEFINE iNoRegistros INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cComprobante ='';
	LET iNoRegistros =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cComprobante;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_obtienecompingresos_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cComprobante;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cComprobante;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
		FOREACH
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienecompingresos_mc()
		INTO cComprobante   
		LET iNoRegistros = iNoRegistros+1;
		RETURN cCodRet,cComprobante WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
		RETURN cCodRet,cComprobante;		
		END IF;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio de estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_obtienecompingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_nombreemp_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,					
				 CHAR(60) AS nombre
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	DEFINE cNombreC CHAR(60);
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iEspacios INTEGER;
	DEFINE cNombre CHAR(25);
	DEFINE cApat CHAR(15);
	DEFINE cAmat CHAR(15);
	DEFINE iContador  INTEGER;
	DEFINE cPalabra LVARCHAR;
	DEFINE iAux1 INTEGER;
	DEFINE iAux2 INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;
	LET cNombreC = '';
	LET i =0 ;
	LET iTamCad = 0;
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres =0;
	LET cCaracter ='';
	LET iEspacios = 0;
	LET cNombre ='';
	LET cApat ='';
	LET cAmat ='';
	LET iContador = 0;
	LET iAux1 = 0;
	LET iAux2=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_nombreemp_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,cNombreC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreC;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
				
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNombreC;
		END IF;		
		
		SELECT nombre INTO cNombreC FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
		
		RETURN cCodRet,cNombreC;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de recuperar el nombre del empleado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_lista_empleados_mc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,					
				 INTEGER AS total
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_lista_empleados_mc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotal;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		 
		SELECT COUNT(*)
		INTO iTotal
		FROM bdisolic:ss_emp_revingresos_mc;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iTotal;
		END IF;		
		
		RETURN cCodRet,iTotal;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de recuperar el total de filas de la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_lista_empleados_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(60) AS nom_emp,
				  CHAR(8) AS num_emp;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomEmp CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumEmp CHAR(8);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomEmp = '';
    LET iNoRegistros = 0;
	LET cNumEmp ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmp,cNumEmp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_lista_empleados_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

        IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNomEmp,cNumEmp;
        END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF(pRegistros == 0) THEN
            DELETE FROM bdicnweb:"informix".sw_ss_emp_revingresos_mc WHERE usuario = pUsuario;

            FOREACH
                
                SELECT TRIM(nombre_empleado) ||' '|| TRIM(apellidop_empleado) ||' '|| TRIM(apellidom_empleado),num_empleado INTO cNomEmp,cNumEmp
                FROM bdisolic:ss_emp_revingresos_mc 
 
                INSERT INTO bdicnweb:"informix".sw_ss_emp_revingresos_mc (usuario,nombre_empleado,num_emp) VALUES(pUsuario,cNomEmp,cNumEmp);
            END FOREACH;
        END IF;

        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion
			nombre_empleado,num_emp
            INTO cNomEmp,cNumEmp FROM bdicnweb:"informix".sw_ss_emp_revingresos_mc
            WHERE usuario = pUsuario
            ORDER BY nombre_empleado
            LET iNoRegistros = iNoRegistros + 1;

           RETURN cCodRet,cNomEmp,cNumEmp WITH RESUME;

        END FOREACH;

        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cNomEmp,cNumEmp;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_lista_empleados_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_insert_empleados_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	DEFINE cNombreC CHAR(60);
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iEspacios INTEGER;
	DEFINE cNombre CHAR(25);
	DEFINE cApat CHAR(15);
	DEFINE cAmat CHAR(15);
	DEFINE iContador  INTEGER;
	DEFINE cPalabra LVARCHAR;
	DEFINE iAux1 INTEGER;
	DEFINE iAux2 INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;
	LET cNombreC = '';
	LET i =0 ;
	LET iTamCad = 0;
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres =0;
	LET cCaracter ='';
	LET iEspacios = 0;
	LET cNombre ='';
	LET cApat ='';
	LET cAmat ='';
	LET iContador = 0;
	LET iAux1 = 0;
	LET iAux2=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_insert_empleados_mc.out';
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
				
				
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
		
		SELECT nombre INTO cNombreC FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
		
		LET iTamCad = LENGTH(TRIM(cNombreC));
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			
			IF cCaracter = ' ' THEN
				LET iEspacios = iEspacios+1;
			END IF;
			
		END LOOP;
		
        LET iAux1 = iEspacios - 1;
		
		IF iEspacios = 0 THEN
			
		LET cNombre = cNombreC;
		LET cApat = ' ';		
		
		END IF;
		
		IF iEspacios = 1 THEN
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF iContador =1  THEN
					LET cNombre = cPalabra;
				ELSE
					LET cApat = cPalabra;
				END IF;
				
			END IF;
			
		END LOOP;
		
		END IF;
		
		IF iEspacios = 2 THEN
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF iContador =1  THEN
					LET cNombre = cPalabra;
				ELIF iContador = 2 THEN
					LET cApat = cPalabra;
				END IF;
				
				
			END IF;
			
				IF i = iTamCad THEN 
					LET cAmat = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				END IF;
		END LOOP;
	 
		END IF;
		
		IF iEspacios > 2 THEN

		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				
				IF (iContador <=iAux1)  THEN
					LET cNombre = TRIM(cNombre)||' '||TRIM(cPalabra);
				ELIF (iContador = iEspacios) THEN					 
					LET cApat = TRIM(cPalabra);
				END IF;
				
				
			END IF;
			
				IF i = iTamCad THEN 
					LET cAmat = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				END IF;
		END LOOP;	 
		
		END IF;
		
		INSERT INTO bdisolic:ss_emp_revingresos_mc(num_empleado, nombre_empleado, apellidop_empleado, apellidom_empleado) 
		VALUES(pNumEmpleado, cNombre, cApat, cAmat);
		
		RETURN cCodRet;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de insertar empleados a la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_elim_empleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
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

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_elim_empleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
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
     
		EXECUTE PROCEDURE bdisolic:"informix".sp_elimina_emp_mc(pNumEmpleado);
	   
		RETURN cCodRet;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_elimina_emp_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_determina_lincred_tc_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20), pCteNvo CHAR(1))
		RETURNING CHAR(5) AS codret,
				  MONEY(14,2) AS linea_cred,
				  MONEY(14,2) AS capacidad_de_pago,
				  INTEGER AS plazo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE mLinCred MONEY(14,2);
	DEFINE mCapPago MONEY(14,2);
	DEFINE iPlazo INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET mLinCred = 0.0;
	LET mCapPago = 0.0;
	LET iPlazo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_determina_lincred_tc_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pEmpresa, pNumSol, pCteNvo) 
		INTO cCodRet,mLinCred,mCapPago,iPlazo;
        
        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet,mLinCred,mCapPago,iPlazo;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio de estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo determina_lincred_tc_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consultaempleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS existe;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cExiste CHAR(1);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cExiste = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cExiste;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consultaempleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cExiste;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cExiste;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        SELECT COUNT(*) INTO iExiste FROM bdisolic:ss_emp_revingresos_mc WHERE num_empleado = pUsuario;
		
		IF iExiste = 0 THEN 
			LET cExiste='0';
		END IF;
		
		IF iExiste >= 1 THEN 
			LET cExiste='1';
		END IF;
		
		RETURN cCodRet,cExiste;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de consultar si el empleado existe en la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consulparam_cambioestatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(50) as valor,
				  CHAR(1) as estatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(50);
	DEFINE cEstatus CHAR(1);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor ='';
	LET cEstatus ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cValor,cEstatus;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consulparam_cambioestatus.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   		
		SELECT valor,estatus INTO cValor,cEstatus FROM bdisolic:"informix".ss_paramcambioestatus WHERE descrip_param  = 'Tiempo_Limite' AND tipo_param ='P';
       
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cValor,cEstatus;
		END IF;		
	   
		RETURN cCodRet,cValor,cEstatus;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Monitor solicitudes',
'DESCRIPCION: SPL encargado de recuperar datos de la tabla ss_paramcambioestatus',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_cons_empleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(60)	AS nom_emp;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomEmp CHAR(60);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomEmp = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_cons_empleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmp;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        FOREACH
        EXECUTE PROCEDURE bdisolic:"informix".sp_cons_empleado_mc(pNumEmpleado) INTO cNomEmp 
        RETURN cCodRet,cNomEmp WITH RESUME;
        END FOREACH;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_cons_empleado_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_califica_scoring2_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20))
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

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_califica_scoring2_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pNumSol ='' THEN
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
   
  
        EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa, pNumSol) INTO cCodRet; 

        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet;  
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo califica_scoring2_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitorconsultatotsolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT)
	RETURNING CHAR(5) AS codret,
		INTEGER AS total_regs;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- InicializaciÃ³n de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN (-239)
			LET cCodRet = '00017';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultatotsolicitudxmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		-- ValidaciÃ³n del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			END IF;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;	

		-- Conteo del numero de registros
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0 , 'ERROR EN LA EJECUCION DEL SP PRODUCTIVO bdisolic:sp_consultaactualizasolicmc';
				ELIF cCodRetSp::INTEGER = 0 THEN
					LET iTotalRegs = iTotalRegs + 1;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp IN ('00003', '00004', '00005') THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, iTotalRegs;
				END IF;
				
		END FOREACH;
		
		IF iTotalRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		RETURN cCodRet, iTotalRegs;

	END;
END PROCEDURE
DOCUMENT "AUTOR: Johnattan Esquivel Sanchez",
"FECHA: 12/03/2020",
"MODIFICACION: Se se modifica procedimiento por control de excepcion",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_monitorconsultasolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		CHAR(100) AS nombre_cliente,
		CHAR(13) AS rfc,
		CHAR(4) AS sucursal,
		DATE AS fecha_insert,
		DATE AS fecha_modificacion,
		DECIMAL(18,2) AS monto_solicitado,
		DECIMAL(18,2) AS eficiencia,
		SMALLINT AS historial,
		CHAR(2) AS status_inicial,
		DECIMAL(18,2) AS seccion1,
		DECIMAL(18,2) AS seccion2,
		CHAR(3) AS causa_solic,
		CHAR(300) AS observaciones,
		CHAR(4) AS num_producto,
		CHAR(2) AS status_fin,
		CHAR(8) AS ejecutivo_atiende,
		CHAR(8) AS ejecutivo_autoriza,
		DATETIME HOUR TO SECOND AS hora_insert,
		DATE AS fecha_determinacion,
		CHAR(1) AS revisado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- Inicialización de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultasolicitudxmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		-- Validación del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			END IF;
		END IF;
		
		-- Validacción de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtención de datos
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmcsoc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo, pRegistros, pRecuperacion,pUsuario)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER = 0 THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado WITH RESUME;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp IN ('00003', '00004', '00005') AND pRegistros = 0 THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				END IF;
				
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
	END;
END PROCEDURE;