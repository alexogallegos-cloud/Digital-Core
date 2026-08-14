CREATE PROCEDURE "informix".sp_cnsif_genarchmovimientos(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pRutaDescarga CHAR(100), pSistemaCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, 
pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2),
pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60), pClaveMov CHAR(50))
    RETURNING CHAR(5) AS codret,
		CHAR(45) AS reporte_generado;
	
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
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_genarchmovimientos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pSistemaCuenta = '' OR 
		pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET dFechaInicial=LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
	    LET dFechaFinal  =LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
	
		IF pSistemaCuenta = 'CAPTACION' THEN
			
			LET cStr8 = 'CAPTACIÓN';
			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;
			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'MOVIMIENTOS_CAPTACION_'||TRIM(cFechaHoraArchivo)||'.txt';
			
			LET cCmd1 ="";
			LET cCmd1 ="SELECT 'FECHA','HORA','TRANSACCIÓN','DESCRIPCIÓN DE TRANSACCIÓN','MONTO','NATURALEZA','SALDO',";
			LET cCmd1 =""||TRIM(cCmd1)||"'REFERENCIA','REVERSOS','SUCURSAL','FOLIO','PROCEDENCIA','USUARIO','REFERENCIA A 23 POSICIONES' FROM systables WHERE tabid = 1 UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''),NVL(TO_CHAR(hora,'%H:%M:%S'), ''),cve_transacc,desc_transacc,TRIM(NVL(TO_CHAR(monto), '')),naturaleza,TRIM(NVL(TO_CHAR(saldo), '')),UPPER(referencia),reversos,sucursal,folio,cve_proc,UPPER(usuario),referencia23";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_movimientos";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE ";
			LET cCmd1 =""||TRIM(cCmd1)||" clave_mov = '"||TRIM(pClaveMov)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sis_cuenta = '"||TRIM(pSistemaCuenta)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_inicial = '"||dFechaInicial||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_final = '"||dFechaFinal||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			
		ELIF pSistemaCuenta = 'CREDITO' THEN
			
			LET cStr8 = 'CRÉDITO';
			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;
			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'MOVIMIENTOS_CREDITO_'||TRIM(cFechaHoraArchivo)||'.txt';
				
			LET cCmd1 ="";
			LET cCmd1 ="SELECT 'FECHA','HORA','NO. TARJETA','FOLIO','PROCEDENCIA','TRANSACCIÓN','DESCRIPCIÓN DE TRANSACCIÓN',";
			LET cCmd1 =""||TRIM(cCmd1)||"'REFERENCIA','MONTO','NATURALEZA','REVERSOS','SUCURSAL','USUARIO','REFERENCIA A 23 POSICIONES' FROM systables WHERE tabid = 1 UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''),NVL(TO_CHAR(hora,'%H:%M:%S'), ''),num_tarjeta,folio,cve_proc,cve_transacc,desc_transacc,UPPER(referencia),TRIM(NVL(TO_CHAR(monto), '')),naturaleza,reversos,sucursal,UPPER(usuario),referencia23";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_movimientos";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE ";
			LET cCmd1 =""||TRIM(cCmd1)||" clave_mov = '"||TRIM(pClaveMov)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sis_cuenta = '"||TRIM(pSistemaCuenta)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_inicial = '"||dFechaInicial||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_final = '"||dFechaFinal||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			
		ELIF pSistemaCuenta = 'INVERSIONES' THEN
			
			LET cStr8 = 'INVERSIÓN';
			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;
			LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
			LET cNombreArchivo = 'MOVIMIENTOS_INVERSIONES_'||TRIM(cFechaHoraArchivo)||'.txt';
			
			LET cCmd1 ="";
			LET cCmd1 ="SELECT 'FECHA','HORA','FOLIO','TRANSACCIÓN','IMPORTE','REVERSADO','SUCURSAL','USUARIO' FROM systables WHERE tabid = 1 UNION ALL";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''),NVL(TO_CHAR(hora,'%H:%M:%S'), ''),folio,cve_transacc||' '||desc_transacc,TRIM(NVL(TO_CHAR(monto), '')),reversados,sucursal,UPPER(usuario)";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_movimientos";
			LET cCmd1 =""||TRIM(cCmd1)||" WHERE ";
			LET cCmd1 =""||TRIM(cCmd1)||" clave_mov = '"||TRIM(pClaveMov)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND sis_cuenta = '"||TRIM(pSistemaCuenta)||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_inicial = '"||dFechaInicial||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_final = '"||dFechaFinal||"'";
			LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
			
		END IF;
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
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
			
			-- Se manipula el archivo para agregar el salto de línea
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
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
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
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT nombre_archivo
				INTO cNombreArchivoHist
				FROM bdicnweb:"informix".sw_cons_archivosgenerados 
				WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta 
				AND fecha < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreArchivoHist);
				SYSTEM TRIM(cSql);
				
				DELETE FROM bdicnweb:"informix".sw_cons_archivosgenerados 
				WHERE nombre_archivo = TRIM(cNombreArchivoHist);
			
			END FOREACH;
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE ACTUALIZA TABLA HISTÓRICA
		INSERT INTO bdicnweb:"informix".sw_cons_archivosgenerados(usuario,nombre_archivo,sis_cuenta,fecha,hora) 
		VALUES(pUsuario,TRIM(cNombreArchivo),pSistemaCuenta,dFechaHoy,dHoraHoy);
		
		
		-- NOTIFICACIÓN VÍA CORREO ELECTRÓNICO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','WEB_ARMOV','WEB_ARMOV',pUsuario,'','','1','','','','','','NOTIFICACION GENERACION ARCHIVO TXT',
       'GENERACION DEL ARCHIVO TXT','',pSistemaCuenta,'','','',1,0,0,0,0,current,current) INTO cCodRetSp;

		/*
		LET cStr7 = 'GENERACIÓN DEL ARCHIVO TXT';
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
		dHoy) INTO cCodRetSp; */
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÓN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		
		RETURN cCodRet, cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 14/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado generar los reportes en formato txt.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 04/10/2017',
'DESCRIPCION: Se agrega diagonal al final de la ruta de descarga del archivo.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 24/10/2017',
'DESCRIPCION: Se agrega la notificación vía correo electrónico al momento de terminar la generación del reporte.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION: Se agregan variables cFechaInicial y cFechaFinal, para tratar la fecha en formato MM/DD/YYYY',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION: Se cambian variables cFechaInicial y cFechaFinal a Date',
'MODIFICACION: L. Montserrat León Amador',
'FECHA MODIFICACION: 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa nuevo filtro de consulta pClaveMov.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina filtro usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Lic. Uriel Caamaño Mejia',
'FECHA MODIFICACION: 23/02/2018',
'DESCRIPCION MODIFICACION: Se realiza ordenamiento de informacion en generacion de los archivos txt.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizacalificaestatus(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pNumCte CHAR(20), pCalificacion SMALLINT, pStatus SMALLINT)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizacalificaestatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNumCte IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEjecucion = '1' THEN
			UPDATE bdinteg:"informix".si_calificacion_cliente
			SET calificacion_cliente = pCalificacion,
			estatus_cliente = pStatus
			WHERE numcte = pNumCte;		
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';		
				RETURN cCodRet; 
			ELSE 			
				RETURN cCodRet;
			END IF;		
			
		ELIF pEjecucion = '2' THEN
			UPDATE bdinteg:"informix".si_calificacion_cliente
			SET calificacion_cliente = pCalificacion
			WHERE numcte = pNumCte;	
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';		
				RETURN cCodRet; 
			ELSE 			
				RETURN cCodRet;
		END IF;		
		 
		ELIF pEjecucion = '3' THEN
			UPDATE bdinteg:"informix".si_calificacion_cliente
			SET estatus_cliente = pStatus
			WHERE numcte = pNumCte;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';		
				RETURN cCodRet; 
			ELSE 			
				RETURN cCodRet;
			END IF;		
			
		ELIF pEjecucion = '4' THEN
			INSERT INTO bdinteg:"informix".si_calificacion_cliente (empleado, numcte, calificacion_cliente, estatus_cliente)
			VALUES (pUsuario, pNumCte,NVL(pCalificacion, NULL), NVL(pStatus,NULL));			 
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';		
				RETURN cCodRet; 
			ELSE 			
				RETURN cCodRet;
			END IF;		
			
		END IF;								
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 26/12/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MANTENIMIENTO TIPO DE CLIENTE',
'DESCRIPCION: SPL QUE ACTUALIZA LOS CAMPOS calificacion_cliente y estatus_cliente',
'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 31/01/2018',
'DESCRIPCION: SE MODIFICA EL COMPORTAMIENTO Y SE HACE CAMBIO POR LA TABLA si_calificacion_cliente, INSERTA Y ACTUALIZA REGISTROS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_catstatuscliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS status,
		CHAR(50) AS desStatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE sStatus SMALLINT;
	DEFINE cDescripcion CHAR(50);        
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sStatus = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sStatus, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_catstatuscliente.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sStatus, cDescripcion;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,  sStatus, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sStatus, cDescripcion;
		END IF;				

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion status_cte, descripcion
			INTO sStatus, cDescripcion
			FROM bdicnweb:"informix".statuscliente
			WHERE activo = 1

			LET iNoRegistros = iNoRegistros +1;
			RETURN cCodRet, sStatus, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sStatus, cDescripcion;               
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 26/12/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MANTENIMIENTO TIPO DE CLIENTE',
'DESCRIPCION: SPL que obtiene los datos de la tabla statuscliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_cattipocliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS calificacionCliente,
		CHAR(50) AS desCalificacion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE sCalificacion SMALLINT;
	DEFINE cDescripcion CHAR(50);        
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sCalificacion = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sCalificacion, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_cattipocliente.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sCalificacion, cDescripcion;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
			RETURN cCodRet,  sCalificacion, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sCalificacion, cDescripcion;
		END IF;				

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion calificacion_cliente, descripcion
			INTO sCalificacion, cDescripcion
			FROM bdicnweb:"informix".tipocliente
			WHERE activo = 1

			LET iNoRegistros = iNoRegistros +1;
			RETURN cCodRet, sCalificacion, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sCalificacion, cDescripcion;                
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 26/12/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MANTENIMIENTO TIPO DE CLIENTE',
'DESCRIPCION: SPL que obtiene los datos de la tabla tipocliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtienecalificacionestatus(pUsuario CHAR(8), pIdFuncion CHAR(10),  pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret,
		SMALLINT AS idCalificacion,
		CHAR(50) AS DesCalificacion,
		SMALLINT AS idStatus,
		CHAR(50) AS DesSatus;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE sCalificacion SMALLINT;
	DEFINE vDesCalificacion CHAR(50);
	DEFINE sStatus SMALLINT;
	DEFINE vDesSatus CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET sCalificacion = 0;
	LET vDesCalificacion = '';
	LET sStatus = 0;
	LET vDesSatus = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sCalificacion, vDesCalificacion, sStatus, vDesSatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtienecalificacionestatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = 0 OR pNumCte IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sCalificacion, vDesCalificacion, sStatus, vDesSatus;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sCalificacion, vDesCalificacion, sStatus, vDesSatus;
		END IF;
		
		SELECT si.calificacion_cliente, NVL(ti.descripcion,'') AS desc_calificacion, NVL(si.estatus_cliente,0), NVL(st.descripcion,'') AS desc_status
		INTO sCalificacion, vDesCalificacion, sStatus, vDesSatus
		FROM  bdinteg:"informix".si_calificacion_cliente si
		LEFT JOIN bdicnweb:"informix".tipoCliente ti
		ON si.calificacion_cliente = ti.calificacion_cliente AND ti.activo = 1
		LEFT JOIN bdicnweb:"informix".statusCliente st
		ON si.estatus_cliente = st.status_cte AND st.activo = 1
		WHERE si.numcte = pNumCte;	
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';		
			RETURN cCodRet, sCalificacion, vDesCalificacion, sStatus, vDesSatus;
		ELSE 			
			RETURN cCodRet, sCalificacion, UPPER(TRIM(vDesCalificacion)), sStatus, UPPER(TRIM(vDesSatus));
		END IF;				
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 26/12/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MANTENIMIENTO TIPO DE CLIENTE',
'DESCRIPCION: SPL QUE ACTUALIZA LOS CAMPOS calificacion_cliente y estatus_cliente',
'AUTOR: LIC. URIEL CAAMAÑO  MEJIA',
'FECHA: 31/01/2018',
'DESCRIPCION: SE MODIFICA EL COMPORTAMIENTO Y SE OBTIENEN LOS DATOS DE TABLA si_calificacion_cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validafrcctemoral(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(14), pTipoCte CHAR(1))
                RETURNING CHAR(5) AS codret;            
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cLetra CHAR(3);
        DEFINE cFecha CHAR(6);
        DEFINE cAnio CHAR(4);
        DEFINE cAnioActual CHAR(4);
        DEFINE iAscii SMALLINT;
        DEFINE dFechaInicio DATE;
        DEFINE iAnio INTEGER;
        DEFINE iAnioActual INTEGER;
        DEFINE iTotal INTEGER;
        DEFINE t_count INTEGER;
        DEFINE u_count INTEGER;
        DEFINE cDia  CHAR(2);
        DEFINE cMes CHAR(2);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cLetra = '';
        LET iAnio = 0;
        LET iAnioActual = 0;
        LET iAscii = 0;
        LET dFechaInicio = NULL;
        LET cFecha = '';
        LET cAnio = '';
        LET cAnioActual = '';
        LET iTotal = 0;
        LET t_count = 0;
        LET u_count = 0;
        LET cDia = '';
        LET cMes = '';
        
        
        BEGIN   
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_validafrcctemoral.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' OR pTipoCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                IF pTipoCte NOT IN('M','F') THEN
                        LET cCodRet = '00313';
                        RETURN cCodRet;
                END IF;
                
                IF(pTipoCte = 'M') THEN
                        -- SE VALIDA QUE LA LONGITUD SEA DE 12 CARACTERES
                        IF LENGTH(pRfc) <> 12 THEN
                                LET cCodRet = '00286';
                                RETURN cCodRet;
                        END IF;
                        
                        -- 97-122 minusculas
                        -- 65-90  mayusculas
                        -- 48-57  0-9
                        --
                        --VALIDA QUE SEAN LETRAS LAS 3 PRIMERAS POSICIONES DE LA CADENA
                        FOR t_count = 1 TO 3
                                LET cLetra = SUBSTRING(pRfc FROM t_count FOR 1);
                                LET iAscii = ASCII(cLetra);
                                                
                                IF NOT ((iAscii >= 97 AND iAscii <= 122)  OR (iAscii >= 65 AND iAscii <= 90) OR iAscii = 38 OR iAscii = 209) THEN
                                        LET cCodRet = '00287';
                                        RETURN cCodRet;
                                END IF;
                        
                        END FOR;
                                        
                        LET cLetra = '';
                        LET iAscii = '';
                        -- VALIDA QUE SEAN NUMEROS DE LA POSICION 4  A LA 9 DE LA CADENA
                        FOR u_count = 4 TO 9
                                LET cLetra = SUBSTRING(pRfc FROM u_count FOR 1);
                                LET iAscii = ASCII(cLetra);
                                                
                                IF NOT ((iAscii >= 48 AND iAscii <= 57) OR iAscii = 209) THEN
                                        LET cCodRet = '00288';
                                        RETURN cCodRet;
                                END IF;
                        END FOR;
                END IF;
                
                IF(pTipoCte = 'F') THEN
                        -- SE VALIDA QUE LA LONGITUD SEA DE  13 CARACTERES
                        IF LENGTH(pRfc) <> 13 THEN
                                LET cCodRet = '00314';
                                RETURN cCodRet;
                        END IF;
                        
                        -- 97-122 minusculas
                        -- 65-90  mayusculas
                        -- 48-57  0-9
                        --
                        --VALIDA QUE SEAN LETRAS LAS 4 PRIMERAS POSICIONES DE LA CADENA                         
                        FOR t_count = 1 TO 4
                                LET cLetra = SUBSTRING(pRfc FROM t_count FOR 1);
                                LET iAscii = ASCII(cLetra);
                                                
                                IF NOT ((iAscii >= 97 AND iAscii <= 122)  OR (iAscii >= 65 AND iAscii <= 90) OR iAscii = 38 OR iAscii = 209) THEN
                                        LET cCodRet = '00315';
                                        RETURN cCodRet;
                                END IF;
                        
                        END FOR;
                        
                        LET cLetra = '';
                        LET iAscii = '';
                        -- VALIDA QUE SEAN NUMEROS DE LA POSICION 5  A LA 10 DE LA CADENA                       
                        FOR u_count = 5 TO 10
                                LET cLetra = SUBSTRING(pRfc FROM u_count FOR 1);
                                LET iAscii = ASCII(cLetra);
                                                
                                IF NOT ((iAscii >= 48 AND iAscii <= 57) OR iAscii = 209) THEN
                                        LET cCodRet = '00316';
                                        RETURN cCodRet;
                                END IF;
                        END FOR;                        
                END IF;
                
                
                
                -- SE COMPRUEBA QUE EL MES Y EL DIA SEAS VALIDOS
                BEGIN
                        ON EXCEPTION IN (-1205)
                                LET cCodRet = '00289';
                                RETURN cCodRet;
                        END EXCEPTION;
                        ON EXCEPTION IN (-1206)
                                LET cCodRet = '00290';
                                RETURN cCodRet;
                        END EXCEPTION;
                        
                        IF(pTipoCte = 'M') THEN
                                LET cFecha = SUBSTRING(pRfc FROM 4 FOR 9);      
                                LET cAnio =     SUBSTRING(cFecha FROM 1 FOR 2); 
                                LET iAnio = cAnio::INTEGER;     
                                LET cAnioActual = YEAR(CURRENT);
                                LET cAnioActual = SUBSTRING(cAnioActual FROM 3 FOR 2);  
                                LET iAnioActual = cAnioActual::INTEGER; 
                        END IF;
                        IF(pTipoCte = 'F') THEN
                                LET cFecha = SUBSTRING(pRfc FROM 5 FOR 10);     
                                LET cAnio =     SUBSTRING(cFecha FROM 1 FOR 2); 
                                LET iAnio = cAnio::INTEGER;     
                                LET cAnioActual = YEAR(CURRENT);
                                LET cAnioActual = SUBSTRING(cAnioActual FROM 3 FOR 2);  
                                LET iAnioActual = cAnioActual::INTEGER;
                        
                        END IF;
                        
                        IF iAnio <= iAnioActual THEN
                                LET cAnio =     '20'|| iAnio;
                        ELSE
                                LET cAnio =     '19'|| iAnio;
                        END IF;
                        LET cMes = SUBSTRING(cFecha FROM 3 FOR 2);
                        LET cDia = SUBSTRING(cFecha FROM 5 FOR 2);
                        
                        LET dFechaInicio = MDY(cMes, cDia, cAnio);      
                        
                END;
                
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
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actbancont(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pBandera INTEGER)
        RETURNING CHAR(5) AS codret;
    
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
    DEFINE iCodRetSp INTEGER;
    DEFINE iRecuperacion INTEGER;
	    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
    LET iCodRetSp = 0;
    LET iRecuperacion = 0;
	
	
	 BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/informix/vamilan/sp_cg_actbancont.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdispei:"informix".sp_actbancont(pFecha,pUsuario,pBandera)  
        INTO cCodRetSp;
			
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdispei:sp_actbancont';
		ELIF iCodRetSp = 22221 OR iCodRetSp = 22222 OR iCodRetSp = 22223 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 1110 THEN
			LET cCodRet = '00283';				
		END IF;
            
		RETURN cCodRet;
	
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 13/04/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ALERTA CONTINGENCIA SPEI',
'DESCRIPCION: SPL encargado de activar o desactivar el mensaje de contingencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consbancont(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
			CHAR(1) AS bandera;
    
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
    DEFINE iCodRetSp INTEGER;
	DEFINE cActivar CHAR(1);
	    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
    LET iCodRetSp = 0;
	LET cActivar = '0';
	
	 BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cActivar;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/informix/vamilan/sp_cg_consbancont.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cActivar;
		END IF;
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet,cActivar;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdispei:"informix".sp_consbancont()  
        INTO cCodRetSp;
			
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdispei:sp_consbancont';
		ELIF iCodRetSp = 1110 THEN
			LET cActivar = '1';
		END IF;
            
		RETURN cCodRet, cActivar;
	
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 13/04/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ALERTA CONTINGENCIA SPEI',
'DESCRIPCION: SPL encargado de determinar si spei tiene contingencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallealertasspei(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		DATE AS fecha_act,
		CHAR(12) AS hr_act,
		CHAR(8) AS us_act,
		CHAR(45) AS nombre_us_act,
		DATE AS fecha_des,
		CHAR(12) AS hr_des,
		CHAR(8) AS us_des,
		CHAR(45) AS nombre_us_des;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaAct DATE;
	DEFINE cHrAct CHAR(12);
	DEFINE cUsAct CHAR(8);
	DEFINE cNombreUsAct CHAR(45);
	DEFINE dFechaDes DATE;
	DEFINE cHrDes CHAR(12);
	DEFINE cUsDes CHAR(8);
	DEFINE cNombreUsDes CHAR(45);
	DEFINE iNumserial INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFechaAct = '';
	LET cHrAct = '';
	LET cUsAct = '';
	LET cNombreUsAct = '';
	LET dFechaDes = '';
	LET cHrDes = '';
	LET cUsDes = '';
	LET cNombreUsDes = '';
	LET iNumserial = 0;
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_cg_detallealertasspei.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion DATE(a.fech_alert) AS fecha, TO_CHAR(a.fech_alert, '%I:%M:%S %p') AS hora, a.usr_alert, a.numserial
			INTO dFechaAct, cHrAct, cUsAct, iNumserial
			FROM bdispei:"informix".tblbitalertaspei AS a
			WHERE DATE(a.fech_alert) BETWEEN pFechaInicio AND pFechaFin
			AND a.bandera = 1 ORDER BY a.fech_alert ASC
		
			SELECT b.nombre	INTO cNombreUsAct FROM bdinteg:"informix".si_ejecut AS b WHERE b.ejecutivo = cUsAct;
			
			SELECT FIRST 1 DATE(a.fech_alert) AS fecha, TO_CHAR(a.fech_alert, '%I:%M:%S %p') AS hora, a.usr_alert
			INTO dFechaDes, cHrDes, cUsDes
			FROM bdispei:"informix".tblbitalertaspei AS a
			WHERE DATE(a.fech_alert) BETWEEN pFechaInicio AND pFechaFin
			AND a.bandera = 0 AND a.numserial > iNumserial 
			AND a.fech_alert = (SELECT MIN(fech_alert) 
								FROM bdispei:"informix".tblbitalertaspei 
								WHERE DATE(fech_alert) BETWEEN pFechaInicio AND pFechaFin 
								AND bandera = 0 AND numserial > iNumserial);
		
			SELECT b.nombre	INTO cNombreUsDes FROM bdinteg:"informix".si_ejecut AS b WHERE b.ejecutivo = cUsDes;
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, UPPER(cNombreUsAct), dFechaDes, cHrDes, cUsDes, UPPER(cNombreUsDes) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaAct, cHrAct, cUsAct, cNombreUsAct, dFechaDes, cHrDes, cUsDes, cNombreUsDes;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 13/04/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE DE CONTINGENCIA SPEI',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitácora de alertas de contingencia SPEI.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_generarepordpago(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pSucursal CHAR(4), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(50) AS nombre_archivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanDetError CHAR(1);
	DEFINE cDesCodRet CHAR(250);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicio DATE;
	DEFINE dFechaFin DATE;
	DEFINE dFecha DATE;
	DEFINE cHora CHAR(8);
	DEFINE cMes CHAR(10);
	DEFINE cAnio CHAR(4);
	DEFINE cRutaGral CHAR(150);
	
	DEFINE cDias CHAR(5);
	DEFINE dFechaHoy DATE;
	DEFINE cHoraHoy CHAR(6);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cNombreArchivo CHAR(50);
	DEFINE cNombreArchivoHist CHAR(50);
	DEFINE iTotalReg INTEGER;
	DEFINE iContCheque INTEGER;
	DEFINE iBloque INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCmd1 CHAR(10000);
	DEFINE cSql CHAR(12000);
	DEFINE cTablaHist CHAR(1);
	DEFINE iIdBitEjec INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';	
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cBanDetError = 'f';
	LET cDesCodRet = 'EJECUCIÓN EXITOSA DEL PROCEDIMIENTO';
	LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	LET dFechaHoraFin = '';
	LET dFechaInicio = '';
	LET dFechaFin = '';
	LET dFecha = '';
	LET cHora = '';
	LET cMes = '';
	LET cAnio = '';
	LET cRutaGral = '';
	
	LET cDias = '';
	LET dFechaHoy = '';
	LET cHoraHoy = '';
	LET cFechaHoraArchivo = '';
	LET cNombreArchivo = '';
	LET cNombreArchivoHist = '';
	LET iTotalReg = 0;
	LET iContCheque = 0;
	LET iBloque = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cCmd1 = '';
	LET cSql = '';
	LET cTablaHist = '';
	LET iIdBitEjec = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
				LET cCodRet = iSqlErr;
				LET cDesCodRet = 'OCURRIÓ UN ERROR NO CONTROLADO EN LA EJECUCIÓN DEL SPL: sp_ope_generarepordpago. CÓDIGO DE ERROR '|| cCodRet||' '||cDescErr;
				
				UPDATE bdicnweb:"informix".sw_ope_statusrepordpago
				SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
				WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_ope_generarepordpago'
				AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
				
				RETURN cCodRet, cNombreArchivo;
				
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (688,-535,255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_generarepordpago.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRutaDescarga = '' THEN
		
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
			LET cCodRet = '00003';
			LET cDesCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA. CÓDIGO DE ERROR'|| cCodRet;
			
			UPDATE bdicnweb:"informix".sw_ope_statusrepordpago
			SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_ope_generarepordpago'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			
			RETURN cCodRet, cNombreArchivo;
			
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
			LET cDesCodRet = 'EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR LA CONSULTA. CÓDIGO DE ERROR'|| cCodRet;
			
			UPDATE bdicnweb:"informix".sw_ope_statusrepordpago
			SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_ope_generarepordpago'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
			
			RETURN cCodRet, cNombreArchivo;
			
		END IF;
		
		-- SE OBTIENE EL NÚMERO DE DIAS PARAMETRIZADOS		
		SELECT valor INTO cDias FROM bdisac:"informix".sac_param WHERE empresa = '001' AND cod_param = '73';
		
		LET dFechaHoy = DATE(CURRENT);
		LET cHoraHoy = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%H%M%S');
		LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||cHoraHoy;
		LET cNombreArchivo = 'REP_ORDENES_PAGO_'||TRIM(pUsuario)||'_'||TRIM(cFechaHoraArchivo)||'.txt';
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_ope_statusrepordpago WHERE usuario_insert = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_ope_statusrepordpago(nombre_archivo,status,procedimiento,error_spl,descripcion_error_spl,usuario_insert,fecha_hora_inicio,fecha_hora_fin)
		VALUES(TRIM(cNombreArchivo),'I','sp_ope_generarepordpago','','',pUsuario,dFechaHoraInicio,null);
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
		BEGIN WORK;
			LET ven_transacc = 1;
			
			FOREACH
			
				SELECT nombre_archivo
				INTO cNombreArchivoHist
				FROM bdicnweb:"informix".sw_ope_repgenerados
				WHERE fecha < dFechaHoy
				
				LET cSql = '';
				LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreArchivoHist);
				SYSTEM TRIM(cSql);
				
				DELETE FROM bdicnweb:"informix".sw_ope_repgenerados 
				WHERE nombre_archivo = TRIM(cNombreArchivoHist);
			
			END FOREACH;
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
			
		SELECT COUNT(*)
		INTO iTotalReg
		FROM bdisac:"informix".sac_enviosdineroya AS a INNER JOIN bdisac:sac_movimientoshistorial_old AS b ON a.no_control = b.referencia1
		INNER JOIN bdisac:"informix".sac_estatus AS c ON a.estatus = c.estatus AND a.estatus = '03'
		AND a.fecha_envio BETWEEN pFechaInicio AND pFechaFin
		AND b.id_sucursal = (CASE WHEN TRIM(pSucursal) = '' THEN b.id_sucursal ELSE TRIM(pSucursal) END);
			
		IF NVL(iTotalReg,0) = 0 THEN
		
			SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
			LET cCodRet = '01053';
			LET cDesCodRet = 'NO EXISTE INFORMACIÓN PARA GENERAR EL ARCHIVO. CÓDIGO DE ERROR'|| cCodRet;
			
			UPDATE bdicnweb:"informix".sw_ope_statusrepordpago
			SET status = 'E', error_spl = cCodRet, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
			WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_ope_generarepordpago'
			AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
		
			RETURN cCodRet, cNombreArchivo;
		
		END IF;
		
		LET cCmd1 ="";
		LET cCmd1 ="SELECT 'DÍA', 'NÚMERO DE CONFIRMACIÓN', 'IMPORTE', 'FORMA DE PAGO', 'FOLIO DE OPERACIÓN', 'NÚMERO DE SUCURSAL', 'NÚMERO DE EMPLEADO DEL CAJERO', 'NOMBRE DEL BENEFICIARIO', 'ESTATUS', 'FECHA DEL BLOQUEO' FROM systables WHERE tabid = 1 UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (SELECT TO_CHAR(a.fecha_envio, '%d/%m/%Y') AS dia, b.referencia1 AS numero_conf, TO_CHAR(b.importe_pago::MONEY(16,2)) AS importe,";
		LET cCmd1 =""||TRIM(cCmd1)||" (DECODE(b.forma_pago, '1', 'EFECTIVO', DECODE(b.forma_pago, '2', 'CARGO EN CUENTA', DECODE(b.forma_pago, '3', 'MIXTO', DECODE(b.forma_pago, '4', 'ABONO EN CUENTA', b.forma_pago))))) AS forma_pago,";
		LET cCmd1 =""||TRIM(cCmd1)||" b.folio_suc AS folio_ope, b.id_sucursal AS numero_suc, b.usuario AS empleado_caj,";
		LET cCmd1 =""||TRIM(cCmd1)||" TRIM(TRIM(UPPER(a.pri_nom_ben))||' '||TRIM(UPPER(a.seg_nom_ben)))||' '||TRIM(TRIM(UPPER(a.apell_pat_ben))||' '||TRIM(UPPER(a.apell_mat_ben))) AS nombre_ben,";
		LET cCmd1 =""||TRIM(cCmd1)||" TRIM(c.descripcion) AS desc_estatus, TO_CHAR(a.fecha_envio + "||TRIM(cDias)::INTEGER||", '%d/%m/%Y') AS fecha_bloqueo";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_enviosdineroya AS a INNER JOIN bdisac:sac_movimientoshistorial_old AS b ON a.no_control = b.referencia1";
		LET cCmd1 =""||TRIM(cCmd1)||" INNER JOIN bdisac:""informix"".sac_estatus AS c ON a.estatus = c.estatus AND a.estatus = '03'";
		LET cCmd1 =""||TRIM(cCmd1)||" AND a.fecha_envio BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		LET cCmd1 =""||TRIM(cCmd1)||" AND b.id_sucursal = (CASE WHEN '"||TRIM(pSucursal)||"' = '' THEN b.id_sucursal ELSE '"||TRIM(pSucursal)||"' END)";
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY a.fecha_envio ASC)";		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			--COMMIT WORK;
			SYSTEM TRIM(cSql);
			--BEGIN WORK;
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE ACTUALIZA TABLA HISTÓRICA
		INSERT INTO bdicnweb:"informix".sw_ope_repgenerados(usuario,nombre_archivo,fecha) 
		VALUES(pUsuario,TRIM(cNombreArchivo),dFechaHoy);
		
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;
		LET cCodRetSp = '00000';
		LET cDesCodRet = 'EL ARCHIVO SE GENERÓ EXITOSAMENTE';
		
		UPDATE bdicnweb:"informix".sw_ope_statusrepordpago
		SET status = 'T', error_spl = cCodRetSp, descripcion_error_spl = cDesCodRet, fecha_hora_fin = dFechaHoraFin
		WHERE nombre_archivo = TRIM(cNombreArchivo) AND procedimiento = 'sp_ope_generarepordpago'
		AND usuario_insert = pUsuario AND fecha_hora_inicio = dFechaHoraInicio;
		
		RETURN cCodRet, cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 14/03/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: GENERACIÓN DEL REPORTE DE ÓRDENES DE PAGO BLOQUEADAS',
'DESCRIPCION: SPL encargado de la generación de los reportes correspondientes a las órdenes de pago bloqueadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_verificastatusrepordpago(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(50) AS nombre_archivo,
		CHAR(6) AS error_spl,
		CHAR(250) AS descripcion_error_spl;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cNombre_archivo CHAR(50);
	DEFINE cError_spl CHAR(6);
	DEFINE cDescripcion_error_spl CHAR(250);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cNombre_archivo = '';
	LET cError_spl = '';
	LET cDescripcion_error_spl = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_verificastatusrepordpago.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,nombre_archivo,error_spl,descripcion_error_spl
		INTO cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl
		FROM bdicnweb:"informix".sw_ope_statusrepordpago 
		WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 14/03/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: GENERACIÓN DEL REPORTE DE ÓRDENES DE PAGO BLOQUEADAS',
'DESCRIPCION: SPL encargado de verificar el status de la generación de los reportes correspondientes a las órdenes de pago bloqueadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfmonitorefectivocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodProveedor CHAR(4),
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
			CHAR(4) AS cCodProveedor,
			CHAR(30) AS cDescProveedor,
			CHAR(3) AS cPlaza,
			CHAR(40) AS cDescPlaza,
			MONEY(14,2) AS mSaldoAnterior, 	
			MONEY(14,2) AS mSaldoTotal,		
			MONEY(14,2) AS mSaldoAsignado,  
			MONEY(14,2) AS mTotalBillDet,   
			MONEY(14,2) AS mSaldoDisponible,
			CHAR(2) AS cDivisa,
			CHAR(30) AS cDescDivisa,
			MONEY(14,2) AS dCantMorralla,
			MONEY(14,2) AS mMontoTotal1,
			MONEY(14,2) AS mMontoTotal2,
			MONEY(14,2) AS mMontoTotal3,
			MONEY(14,2) AS mMontoTotal4,
			MONEY(14,2) AS mMontoTotal5,
			MONEY(14,2) AS mMontoTotal6,
			MONEY(14,2) AS mTotal,
			CHAR(18) AS cDenominacion_1,
			CHAR(18) AS cDenominacion_2,
			CHAR(18) AS cDenominacion_3,
			CHAR(18) AS cDenominacion_4, 
			CHAR(18) AS cDenominacion_5,
			CHAR(18) AS cDenominacion_6,
			CHAR(8) AS cDenMorralla,
			MONEY(19,2) AS mSaldoAutorizado,
			MONEY(21,2) AS mRangoMaximo,
			MONEY(19,2) AS mRangoMinimo,
			INTEGER AS iIndicador;
			
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE cCodProveedor CHAR(4);
		DEFINE cDescProveedor CHAR(30);
		DEFINE cPlaza CHAR(3);
		DEFINE cDescPlaza CHAR(40);
		DEFINE mSaldoAnterior MONEY(14,2);
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE mSaldoAsignado MONEY(14,2);
		DEFINE mTotalBillDet MONEY(14,2);
		DEFINE mSaldoDisponible MONEY(14,2);
		DEFINE cDivisa CHAR(2);
		DEFINE cDescDivisa CHAR(30);
		DEFINE cDenominacion_1 CHAR(18);
		DEFINE cDenominacion_2 CHAR(18);
		DEFINE cDenominacion_3 CHAR(18);
		DEFINE cDenominacion_4 CHAR(18); 
		DEFINE cDenominacion_5 CHAR(18);
		DEFINE cDenominacion_6 CHAR(18);
		DEFINE cDenominacion_7 CHAR(18);
		DEFINE cDenominacion_8 CHAR(18);
		DEFINE cDenominacion_9 CHAR(18);
		DEFINE cDenominacion_10 CHAR(18);
		DEFINE cDenominacion_11 CHAR(18);
		DEFINE cDenominacion_12 CHAR(18);
		DEFINE cDenominacion_13 CHAR(18);
		DEFINE cDenominacion_14 CHAR(18);
		DEFINE cDenominacion_15 CHAR(18);
		DEFINE dCantidad_1 FLOAT(8);
		DEFINE dCantidad_2 FLOAT(8);
		DEFINE dCantidad_3 FLOAT(8);
		DEFINE dCantidad_4 FLOAT(8);
		DEFINE dCantidad_5 FLOAT(8);
		DEFINE dCantidad_6 FLOAT(8);
		DEFINE dCantidad_7 FLOAT(8);
		DEFINE dCantidad_8 FLOAT(8);
		DEFINE dCantidad_9 FLOAT(8);
		DEFINE dCantidad_10 FLOAT(8);
		DEFINE dCantidad_11 FLOAT(8);
		DEFINE dCantidad_12 FLOAT(8);
		DEFINE dCantidad_13 FLOAT(8);
		DEFINE dCantidad_14 FLOAT(8);
		DEFINE dCantidad_15 FLOAT(8);
		DEFINE iRecuperacion INTEGER;
		DEFINE dCantMorralla MONEY(14,2);
		DEFINE mMontoTotal1 MONEY(14,2);
		DEFINE mMontoTotal2 MONEY(14,2);
		DEFINE mMontoTotal3 MONEY(14,2);
		DEFINE mMontoTotal4 MONEY(14,2);
		DEFINE mMontoTotal5 MONEY(14,2);
		DEFINE mMontoTotal6 MONEY(14,2);
		DEFINE mTotal MONEY(14,2);
		DEFINE cDenMorralla CHAR(8);
		DEFINE mSaldoAut MONEY(19,2);
		DEFINE mRangoMax MONEY(21,2);
		DEFINE mRangoMin MONEY(19,2);
		DEFINE iPorcentaje INTEGER;
		DEFINE mCalc MONEY(19,2);
		DEFINE iIndi INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET cCodProveedor = '';
		LET cDescProveedor = '';
		LET cPlaza = '';
		LET cDescPlaza = '';
		LET mSaldoAnterior = NULL;
		LET mSaldoTotal = NULL;
		LET mSaldoAsignado = NULL;
		LET mTotalBillDet = NULL;
		LET mSaldoDisponible = NULL;
		LET cDivisa = '';
		LET cDescDivisa = '';
		LET cDenominacion_1 = '';
		LET cDenominacion_2 = '';
		LET cDenominacion_3 = '';
		LET cDenominacion_4 = '';
		LET cDenominacion_5 = '';
		LET cDenominacion_6 = '';
		LET cDenominacion_7 = '';
		LET cDenominacion_8 = '';
		LET cDenominacion_9 = '';
		LET cDenominacion_10 = '';
		LET cDenominacion_11 = '';
		LET cDenominacion_12 = '';
		LET cDenominacion_13 = '';
		LET cDenominacion_14 = '';
		LET cDenominacion_15 = '';
		LET dCantidad_1 = 0;
		LET dCantidad_2 = 0;
		LET dCantidad_3 = 0;
		LET dCantidad_4 = 0;
		LET dCantidad_5 = 0;
		LET dCantidad_6 = 0;
		LET dCantidad_7 = 0;
		LET dCantidad_8 = 0;
		LET dCantidad_9 = 0;
		LET dCantidad_10 = 0;
		LET dCantidad_11 = 0;
		LET dCantidad_12 = 0;
		LET dCantidad_13 = 0;
		LET dCantidad_14 = 0;
		LET dCantidad_15 = 0; 
		LET iRecuperacion = 0;
		LET dCantMorralla = 0.00;
		LET mMontoTotal1 = 0.00;
		LET mMontoTotal2 = 0.00;
		LET mMontoTotal3 = 0.00;
		LET mMontoTotal4 = 0.00;
		LET mMontoTotal5 = 0.00;
		LET mMontoTotal6 = 0.00; 
		LET mTotal = 0.00;
		LET cDenMorralla = 'Morralla';
		LET mSaldoAut = 0.00;
		LET mRangoMax = 0.00;
		LET mRangoMin = 0.00;
		LET iPorcentaje = 0;
		LET mCalc = 0.00;
		LET iIndi = 0;

		BEGIN
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'),
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal, 
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfmonitorefectivocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodProveedor = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;						
            END IF;
            
			-- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			-- DETALLE CONSULTA 
			FOREACH
				EXECUTE PROCEDURE bdisuc:"informix".consultacajageneral2('001', pCodProveedor, pRegistros, pRecuperacion)
				INTO cCodRetSp, cEmpresa, cCodProveedor, cDivisa, mSaldoAnterior, mSaldoAsignado, mSaldoTotal, 
					cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, 
					cDenominacion_6, cDenominacion_7, cDenominacion_8, cDenominacion_9, cDenominacion_10, 
					cDenominacion_11, cDenominacion_12, cDenominacion_13, cDenominacion_14, cDenominacion_15, 
					dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, 
					dCantidad_6, dCantidad_7, dCantidad_8, dCantidad_9, dCantidad_10, 
					dCantidad_11, dCantidad_12, dCantidad_13, dCantidad_14, dCantidad_15, 
					cDescProveedor, cDescDivisa, cPlaza, cDescPlaza, mSaldoDisponible, mTotalBillDet, mSaldoAut, iPorcentaje				 

					LET mMontoTotal1 = NVL(dCantidad_1,0);
					LET mMontoTotal2 = NVL(dCantidad_2,0);
					LET mMontoTotal3 = NVL(dCantidad_3,0);				
					LET mMontoTotal4 = NVL(dCantidad_4,0);
					LET mMontoTotal5 = NVL(dCantidad_5,0);				
					LET mMontoTotal6 = NVL(dCantidad_6,0);
					LET dCantMorralla = NVL(dCantidad_7,0);
					LET mTotal = mSaldoTotal;
					
					LET mCalc = NVL(mSaldoAut,0) * (NVL(iPorcentaje,0) / 100);
					LET mRangoMax = NVL(mSaldoAut,0) + mCalc;
					LET mRangoMin = NVL(mSaldoAut,0) - mCalc;
					
					IF mSaldoAut IS NULL AND iPorcentaje IS NULL THEN
						LET iIndi = 0;
					ELIF NVL(mSaldoDisponible,0) > mRangoMin AND NVL(mSaldoDisponible,0) < mRangoMax THEN
						LET iIndi = 0;
					ELIF NVL(mSaldoDisponible,0) < mRangoMin THEN	
						LET iIndi = 1;
					ELIF NVL(mSaldoDisponible,0) > mRangoMax THEN	
						LET iIndi = 2;
					END IF;
					
				IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:consultacajageneral2';
				ELIF cCodRetSp::INTEGER = 101 THEN
					LET cCodRet = '00017'; --'00151'
					RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
							mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
							cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
							dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
							cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, 
							cDenMorralla,mSaldoAut,mRangoMax,mRangoMin, iIndi;					   
				ELSE
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cCodProveedor, NVL(UPPER(cDescProveedor),'NO EXISTE'), cPlaza, NVL(UPPER(cDescPlaza),'NO EXISTE'), 
							mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
							cDivisa, NVL(UPPER(cDescDivisa),'NO EXISTE'), 
							dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
							cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, 
							cDenMorralla,NVL(mSaldoAut,0),mRangoMax,mRangoMin, iIndi WITH RESUME; 
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;						
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCodProveedor, NVL(cDescProveedor,'NO EXISTE'), cPlaza, NVL(cDescPlaza,'NO EXISTE'), 
						mSaldoAnterior, mSaldoTotal, mSaldoAsignado, mTotalBillDet, mSaldoDisponible, 
						cDivisa, NVL(cDescDivisa,'NO EXISTE'), 
						dCantMorralla, mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal,
						cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4,  cDenominacion_5, cDenominacion_6, cDenMorralla,
						mSaldoAut,mRangoMax,mRangoMin, iIndi;
			END IF;	
		END;
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/03/2015',
'DESCRIPCION: SPL que obtiene el detalle de las cajas generales consultadas.',
'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 22/09/2015',
'DESCRIPCION: Se modifico el SPL para que regrese los registros de las cajas Consultadas y sus detalles.',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 08/03/2017',
'DESCRIPCION: Se modifico el SPL para agregar los campos saldo autorizado, rango minimo, rango maximo y el indicador.',
'FUNCIONALIDAD: Monitor de Efectivo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caja_actualizasaldoporcentaje(pUsuario CHAR(8), pIdFuncion CHAR(10), pcodproveedor CHAR(4), pSaldoAutorizado MONEY(19,2), pPorcentaje INTEGER)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE vsqlerr INTEGER;
	DEFINE vempresa CHAR (3);
	DEFINE vcod_proveedor CHAR (4);
	DEFINE vdivisa CHAR (2);
	DEFINE vsaldo_anterior MONEY (14);
	DEFINE vsaldo_asignado MONEY (14);
	DEFINE vsaldo_total MONEY (14);
	DEFINE vdenominacion_1 CHAR (18);
	DEFINE vdenominacion_2 CHAR (18);
	DEFINE vdenominacion_3 CHAR (18);
	DEFINE vdenominacion_4 CHAR (18);
	DEFINE vdenominacion_5 CHAR (18);
	DEFINE vdenominacion_6 CHAR (18);
	DEFINE vdenominacion_7 CHAR (18);
	DEFINE vdenominacion_8 CHAR (18);
	DEFINE vdenominacion_9 CHAR (18);
	DEFINE vdenominacion_10 CHAR (18);
	DEFINE vdenominacion_11 CHAR (18);
	DEFINE vdenominacion_12 CHAR (18);
	DEFINE vdenominacion_13 CHAR (18);
	DEFINE vdenominacion_14 CHAR (18);
	DEFINE vdenominacion_15 CHAR (18);
	DEFINE vcantidad_1 FLOAT (8);
	DEFINE vcantidad_2 FLOAT (8);
	DEFINE vcantidad_3 FLOAT (8);
	DEFINE vcantidad_4 FLOAT (8);
	DEFINE vcantidad_5 FLOAT (8);
	DEFINE vcantidad_6 FLOAT (8);
	DEFINE vcantidad_7 FLOAT (8);
	DEFINE vcantidad_8 FLOAT (8);
	DEFINE vcantidad_9 FLOAT (8);
	DEFINE vcantidad_10 FLOAT (8);
	DEFINE vcantidad_11 FLOAT (8);
	DEFINE vcantidad_12 FLOAT (8);
	DEFINE vcantidad_13 FLOAT (8);
	DEFINE vcantidad_14 FLOAT (8);
	DEFINE vcantidad_15 FLOAT (8);
	DEFINE vdescripcion CHAR (30);
	DEFINE vdescdivisa CHAR(30);
	DEFINE vplaza CHAR(3);
	DEFINE vnomplaza CHAR(40);
	DEFINE vsaldo_disponible FLOAT(8);
	DEFINE vbill_det FLOAT(8);
	DEFINE vtotal_det FLOAT(8);
	DEFINE vcant_1d FLOAT(8);
	DEFINE vcant_2d FLOAT(8);
	DEFINE vcant_3d FLOAT(8);
	DEFINE vcant_4d FLOAT(8);
	DEFINE vcant_5d FLOAT(8);
	DEFINE vcant_6d FLOAT(8);
	DEFINE msaldo_autorizado MONEY(19,2);
	DEFINE iporcentaje_variacion INTEGER;
	DEFINE vNombre CHAR(45);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vcod_proveedor = "";
	LET vdivisa = "";
	LET vsaldo_anterior = 0;
	LET vsaldo_asignado = 0;
	LET vsaldo_total = 0;
	LET vdenominacion_1 = "";
	LET vdenominacion_2  = "";
	LET vdenominacion_3  = "";
	LET vdenominacion_4  = "";
	LET vdenominacion_5  = "";
	LET vdenominacion_6  = "";
	LET vdenominacion_7  = "";
	LET vdenominacion_8  = "";
	LET vdenominacion_9  = "";
	LET vdenominacion_10 = "";
	LET vdenominacion_11 = "";
	LET vdenominacion_12 = "";
	LET vdenominacion_13 = "";
	LET vdenominacion_14 = "";
	LET vdenominacion_15 = "";
	LET vcantidad_1 = 0;
	LET vcantidad_2 = 0;
	LET vcantidad_3 = 0;
	LET vcantidad_4 = 0;
	LET vcantidad_5 = 0;
	LET vcantidad_6 = 0;
	LET vcantidad_7 = 0;
	LET vcantidad_8 = 0;
	LET vcantidad_9 = 0;
	LET vcantidad_10 = 0;
	LET vcantidad_11 = 0;
	LET vcantidad_12 = 0;
	LET vcantidad_13 = 0;
	LET vcantidad_14 = 0;
	LET vcantidad_15 = 0;
	LET vdescripcion  = "";
	LET vdescdivisa = "";
	LET vplaza = "";
	LET vnomplaza= "";
	LET vsaldo_disponible = 0;
	LET vbill_det = 0;
	LET vtotal_det = 0;
	LET vcant_1d = 0;
	LET vcant_2d = 0;
	LET vcant_3d = 0;
	LET vcant_4d =0;
	LET vcant_5d = 0;
	LET vcant_6d = 0;
	LET msaldo_autorizado = 0.0;
	LET iporcentaje_variacion = 0;
	LET vNombre = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_caja_actualizasaldoporcentaje.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' or pcodproveedor = '' OR pSaldoAutorizado IS NULL OR pPorcentaje IS NULL THEN
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
		
		IF EXISTS (SELECT cod_proveedor FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = pcodproveedor) THEN
			FOREACH
				SELECT cg.empresa, cg.cod_proveedor, cg.divisa, cg.saldo_anterior, cg.saldo_asignado, cg.saldo_total, cg.denominacion_1, cg.denominacion_2,
					cg.denominacion_3, cg.denominacion_4, cg.denominacion_5, cg.denominacion_6, cg.denominacion_7, cg.denominacion_8, cg.denominacion_9,
					cg.denominacion_10, cg.denominacion_11, cg.denominacion_12, cg.denominacion_13, cg.denominacion_14, cg.denominacion_15, cg.cantidad_1,
					cg.cantidad_2, cg.cantidad_3, cg.cantidad_4, cg.cantidad_5, cg.cantidad_6, cg.cantidad_7, cg.cantidad_8, cg.cantidad_9, cg.cantidad_10,
					cg.cantidad_11, cg.cantidad_12, cg.cantidad_13, cg.cantidad_14, cg.cantidad_15,cg.cantidad_1d,
					cg.cantidad_2d, cg.cantidad_3d, cg.cantidad_4d, cg.cantidad_5d, cg.cantidad_6d, pro.descripcion, div.descripcion, pro.plaza, plz.descripcion,
					cg.saldo_autorizado, cg.pcjte_variacion
				INTO vempresa, vcod_proveedor, vdivisa, vsaldo_anterior, vsaldo_asignado, vsaldo_total, vdenominacion_1, vdenominacion_2, vdenominacion_3, vdenominacion_4,
					vdenominacion_5, vdenominacion_6, vdenominacion_7, vdenominacion_8, vdenominacion_9, vdenominacion_10, vdenominacion_11, vdenominacion_12,
					vdenominacion_13, vdenominacion_14, vdenominacion_15, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6, vcantidad_7,
					vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15,
					vcant_1d,vcant_2d,vcant_3d,vcant_4d,vcant_5d,vcant_6d, vdescripcion, vdescdivisa,
					vplaza, vnomplaza,msaldo_autorizado,iporcentaje_variacion
				FROM bdisuc:"informix".ss_cajageneral cg LEFT JOIN bdisuc:"informix".ss_proveedores pro ON (pro.cod_proveedor = cg.cod_proveedor) LEFT JOIN bdinteg:"informix".si_divisas div ON
						  (div.divisa =  cg.divisa) LEFT JOIN bdinteg:"informix".si_plazas_cajagen plz ON (plz.codigo_plaza = pro.plaza)
				WHERE cg.cod_proveedor = pcodproveedor
				ORDER BY cod_proveedor
				LET vbill_det = ((vdenominacion_1 * vcant_1d) + (vdenominacion_2 * vcant_2d) + (vdenominacion_3 * vcant_3d) + (vdenominacion_4 * vcant_4d) +
							  (vdenominacion_5 * vcant_5d) + (vdenominacion_6 * vcant_6d));
				LET vsaldo_total =vsaldo_total + vsaldo_asignado;
				LET vsaldo_asignado = vsaldo_asignado - vbill_det;
				LET vsaldo_disponible = vsaldo_total - (vsaldo_asignado + vbill_det);
				
				SELECT nombre INTO vNombre FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pUsuario;
			   
				INSERT INTO bdisuc:"informix".ss_bitacora_monitor_saldosautorizados(cod_proveedor, plaza, saldo_disponible, saldo_autorizado_new, saldo_autorizado_old, porcentaje_new, porcentaje_old, fecha_mod, empleado, nombre) 
				VALUES(vcod_proveedor, vplaza, vsaldo_disponible, pSaldoAutorizado, NVL(msaldo_autorizado,0), pPorcentaje, NVL(iporcentaje_variacion,0), CURRENT, pUsuario, vNombre);
			   
				UPDATE bdisuc:"informix".ss_cajageneral
				SET
				saldo_autorizado = pSaldoAutorizado,
				pcjte_variacion = pPorcentaje
				WHERE cod_proveedor = pcodproveedor;

			END FOREACH;
		ELSE
			LET cCodRet='00017';
		END IF;
			
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 08/03/2017',
'MODULO: Caja General',
'FUNCIONALIDAD: Monitor Caja General',
'DESCRIPCION: Actualiza el saldo autorizado y el porcentaje, ademas de guardar en bitacora el movimiento',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caja_consultasaldosporcentaje(pUsuario CHAR(8), pIdFuncion CHAR(10), pcodproveedor CHAR(10))
		RETURNING CHAR(5) AS codret,
			MONEY(19,2) AS mSaldoAutorizado,
			INTEGER AS iporcentaje;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE msaldo_autorizado MONEY(19,2);
	DEFINE iporcentaje_variacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET msaldo_autorizado = 0.0;
	LET iporcentaje_variacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, msaldo_autorizado, iporcentaje_variacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_caja_consultasaldosporcentaje.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pcodproveedor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, msaldo_autorizado, iporcentaje_variacion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, msaldo_autorizado, iporcentaje_variacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS (SELECT cod_proveedor FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = pcodproveedor) THEN
			FOREACH
				SELECT saldo_autorizado, pcjte_variacion
				INTO msaldo_autorizado,iporcentaje_variacion
				FROM bdisuc:"informix".ss_cajageneral 
				WHERE cod_proveedor = pcodproveedor
			END FOREACH;
		ELSE
			LET cCodRet='00017';
        END IF;
	
		RETURN cCodRet, NVL(msaldo_autorizado,0), NVL(iporcentaje_variacion,0);
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 08/03/2017',
'MODULO: Caja General',
'FUNCIONALIDAD: Monitor Caja General',
'DESCRIPCION: Consulta el saldo autorizado y el porcentaje de la caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_caja_consultabitacorasaldosporcentaje(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodproveedor CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(5) AS cajageneral,
				CHAR(40) AS plaza,
				MONEY(19,2)	AS saldoDisponible,
				MONEY(19,2)	AS saldoAutorizado,
				MONEY(19,2)	AS saldoAutorizado_ant,
				INTEGER AS porcentaje,
				INTEGER AS porcentaje_ant,
				CHAR(25) AS fecha,
				CHAR(8) AS empleado,
				CHAR(50) AS nombre;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCaja CHAR(5);
	DEFINE cPlaza CHAR(40);
	DEFINE mSaldo_disp MONEY(19,2);
	DEFINE mSaldoAut MONEY(19,2);
	DEFINE mSaldoAut_old MONEY(19,2);
	DEFINE iPorcentaje INTEGER;
	DEFINE iPorcentaje_old INTEGER;
	DEFINE dFecha DATETIME YEAR TO FRACTION;
	DEFINE cEmpleado CHAR(8);
	DEFINE cNombre CHAR(50);
	DEFINE cFecha CHAR(25);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCaja = '';
	LET cPlaza = '';
	LET mSaldo_disp = 0.0;
	LET mSaldoAut = 0.0;
	LET mSaldoAut_old = 0.0;
	LET iPorcentaje = 0;
	LET iPorcentaje_old = 0;
	LET dFecha = DATE(1);
	LET cEmpleado = '';
	LET cNombre = '';
	LET cFecha = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
			cFecha, cEmpleado, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_caja_consultabitacorasaldosporcentaje.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodproveedor = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
			cFecha, cEmpleado, cNombre;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
			cFecha, cEmpleado, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
			cFecha, cEmpleado, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pCodproveedor = "0000" THEN
			FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion a.cod_proveedor, (TO_CHAR(plz.codigo_plaza) || ' ' || TRIM(plz.descripcion)), a.saldo_disponible, a.saldo_autorizado_new, 
				a.saldo_autorizado_old, a.porcentaje_new, a.porcentaje_old, a.fecha_mod, a.empleado, a.nombre
				INTO cCaja,cPlaza,mSaldo_disp,mSaldoAut,mSaldoAut_old,iPorcentaje,iPorcentaje_old,dFecha,cEmpleado,cNombre
				FROM bdisuc:"informix".ss_bitacora_monitor_saldosautorizados AS a
				LEFT JOIN bdisuc:"informix".ss_proveedores pro ON (pro.cod_proveedor =  a.cod_proveedor) 
				LEFT JOIN bdinteg:"informix".si_plazas_cajagen plz ON (plz.codigo_plaza = pro.plaza) 
				ORDER BY cod_proveedor
				LET iRecuperacion = iRecuperacion + 1;
				LET cFecha = TO_CHAR(dFecha, '%d/%m/%Y %I:%M %p');
				RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
				cFecha, cEmpleado, cNombre WITH RESUME;
			END FOREACH;
		ELSE
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion a.cod_proveedor, (TO_CHAR(plz.codigo_plaza) || ' ' || TRIM(plz.descripcion)), a.saldo_disponible, a.saldo_autorizado_new, 
				a.saldo_autorizado_old, a.porcentaje_new, a.porcentaje_old, a.fecha_mod, a.empleado, a.nombre
				INTO cCaja,cPlaza,mSaldo_disp,mSaldoAut,mSaldoAut_old,iPorcentaje,iPorcentaje_old,dFecha,cEmpleado,cNombre
				FROM bdisuc:"informix".ss_bitacora_monitor_saldosautorizados AS a
				LEFT JOIN bdisuc:"informix".ss_proveedores pro ON (pro.cod_proveedor =  a.cod_proveedor) 
				LEFT JOIN bdinteg:"informix".si_plazas_cajagen plz ON (plz.codigo_plaza = pro.plaza) 
				WHERE a.cod_proveedor = pCodproveedor
				ORDER BY cod_proveedor
				LET iRecuperacion = iRecuperacion + 1;
				LET cFecha = TO_CHAR(dFecha, '%d/%m/%Y %I:%M %p');
				RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
				cFecha, cEmpleado, cNombre WITH RESUME;
			END FOREACH;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';	
				RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
				cFecha, cEmpleado, cNombre;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCaja, cPlaza, mSaldo_disp, mSaldoAut, mSaldoAut_old, iPorcentaje, iPorcentaje_old,
				cFecha, cEmpleado, cNombre;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 09/03/2017',
'MODULO: Caja General',
'FUNCIONALIDAD: Monitor Efectivo Caja General',
'DESCRIPCION: Consulta la informacion de la bitacora de cambios en los saldos autorizados y porcentajes de variacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocajagen(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS clave,
			CHAR(40) AS descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocajagen.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_cajagen()
			INTO cCodRetSp, cDescCodRetSp, cClave, cDescripcion

			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisuc:sp_consulta_cajagen';
			END IF;
		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que se encarga de consultar el detalle del catálogo caja general.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoconsultarpor(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS clave,
			CHAR(40) AS descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoconsultarpor.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		
		FOREACH
			SELECT clave, descripcion  INTO cClave, cDescripcion
			FROM bdicnweb:"informix".sw_cat_busqueda ORDER BY clave ASC

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que se encarga de consultar el detalle del catálogo consultar por.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogosucxcg(pUsuario CHAR(8), pIdFuncion CHAR(10), pCaja CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS clave,
			CHAR(40) AS descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogosucxcg.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCaja = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_sucxcg2(pCaja,pRegistros,pRecuperacion)
			INTO cCodRetSp, cDescCodRetSp, cClave, cDescripcion

			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisuc:sp_consulta_sucxcg2';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que se encarga de consultar el detalle del catálogo mostrar por.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallesaldoscierrediario(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pClaveCg CHAR(4), pClaveSuc CHAR(4),
pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR(4) AS clave,
			MONEY(18,2) AS b_1000,
			MONEY(18,2) AS b_500,
			MONEY(18,2) AS b_200,
			MONEY(18,2) AS b_100,
			MONEY(18,2) AS b_50,
			MONEY(18,2) AS b_20,
			MONEY(18,2) AS m_100,
			MONEY(18,2) AS m_50,
			MONEY(18,2) AS m_20,
			MONEY(18,2) AS m_10,
			MONEY(18,2) AS m_5,
			MONEY(18,2) AS m_2,
			MONEY(18,2) AS m_1,
			MONEY(18,2) AS cm_50,
			MONEY(18,2) AS cm_20,
			MONEY(18,2) AS cm_10,
			MONEY(18,2) AS cm_5,
			MONEY(18,2) AS total_b,
			MONEY(18,2) AS total_m,
			MONEY(18,2) AS total;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cClave CHAR(4);
	DEFINE mCantidad_1 MONEY(18,2);
	DEFINE mCantidad_2 MONEY(18,2);
	DEFINE mCantidad_3 MONEY(18,2);
	DEFINE mCantidad_4 MONEY(18,2);
	DEFINE mCantidad_5 MONEY(18,2);
	DEFINE mCantidad_6 MONEY(18,2);
	DEFINE mCantidad_8 MONEY(18,2);
	DEFINE mCantidad_9 MONEY(18,2);
	DEFINE mCantidad_10 MONEY(18,2);
	DEFINE mCantidad_11 MONEY(18,2);
	DEFINE mCantidad_12 MONEY(18,2);
	DEFINE mCantidad_13 MONEY(18,2);
	DEFINE mCantidad_14 MONEY(18,2);
	DEFINE mCantidad_15 MONEY(18,2);
	DEFINE mCantidad_16 MONEY(18,2);
	DEFINE mCantidad_17 MONEY(18,2);
	DEFINE mCantidad_18 MONEY(18,2);
	DEFINE mSaldo_total_b MONEY(18,2);
	DEFINE mSaldo_total_m MONEY(18,2);
	DEFINE mSaldo_total MONEY(18,2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cClave = '';
	LET mCantidad_1 = 0.00;
	LET mCantidad_2 = 0.00;
	LET mCantidad_3 = 0.00;
	LET mCantidad_4 = 0.00;
	LET mCantidad_5 = 0.00;
	LET mCantidad_6 = 0.00;
	LET mCantidad_8 = 0.00;
	LET mCantidad_9 = 0.00;
	LET mCantidad_10 = 0.00;
	LET mCantidad_11 = 0.00;
	LET mCantidad_12 = 0.00;
	LET mCantidad_13 = 0.00;
	LET mCantidad_14 = 0.00;
	LET mCantidad_15 = 0.00;
	LET mCantidad_16 = 0.00;
	LET mCantidad_17 = 0.00;
	LET mCantidad_18 = 0.00;
	LET mSaldo_total_b = 0.00;
	LET mSaldo_total_m = 0.00;
	LET mSaldo_total = 0.00;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_detallesaldoscierrediario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR 
		pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, clave, cantidad_1, cantidad_2, cantidad_3,
			cantidad_4, cantidad_5, cantidad_6, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14,
			cantidad_15, cantidad_16, cantidad_17, cantidad_18, saldo_total_b, saldo_total_m, saldo_total
			INTO dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total
			FROM bdicnweb:"informix".sw_saldoscierre_sucg WHERE usuario_insert = TRIM(pUsuario) ORDER BY id_registro ASC
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
			mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
			mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que se encarga de consultar el detalle de saldos de cierre diario por denominaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallesaldoscierrediario_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pClaveCg CHAR(4), pClaveSuc CHAR(4),
pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cClave CHAR(4);
	DEFINE mCantidad_1 MONEY(18,2);
	DEFINE mCantidad_2 MONEY(18,2);
	DEFINE mCantidad_3 MONEY(18,2);
	DEFINE mCantidad_4 MONEY(18,2);
	DEFINE mCantidad_5 MONEY(18,2);
	DEFINE mCantidad_6 MONEY(18,2);
	DEFINE mCantidad_8 MONEY(18,2);
	DEFINE mCantidad_9 MONEY(18,2);
	DEFINE mCantidad_10 MONEY(18,2);
	DEFINE mCantidad_11 MONEY(18,2);
	DEFINE mCantidad_12 MONEY(18,2);
	DEFINE mCantidad_13 MONEY(18,2);
	DEFINE mCantidad_14 MONEY(18,2);
	DEFINE mCantidad_15 MONEY(18,2);
	DEFINE mCantidad_16 MONEY(18,2);
	DEFINE mCantidad_17 MONEY(18,2);
	DEFINE mCantidad_18 MONEY(18,2);
	DEFINE mSaldo_total_b MONEY(18,2);
	DEFINE mSaldo_total_m MONEY(18,2);
	DEFINE mSaldo_total MONEY(18,2);
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cClave = '';
	LET mCantidad_1 = 0.00;
	LET mCantidad_2 = 0.00;
	LET mCantidad_3 = 0.00;
	LET mCantidad_4 = 0.00;
	LET mCantidad_5 = 0.00;
	LET mCantidad_6 = 0.00;
	LET mCantidad_8 = 0.00;
	LET mCantidad_9 = 0.00;
	LET mCantidad_10 = 0.00;
	LET mCantidad_11 = 0.00;
	LET mCantidad_12 = 0.00;
	LET mCantidad_13 = 0.00;
	LET mCantidad_14 = 0.00;
	LET mCantidad_15 = 0.00;
	LET mCantidad_16 = 0.00;
	LET mCantidad_17 = 0.00;
	LET mCantidad_18 = 0.00;
	LET mSaldo_total_b = 0.00;
	LET mSaldo_total_m = 0.00;
	LET mSaldo_total = 0.00;
	LET iRecuperacion = 0;
	LET iNumRegistros = 0;

	BEGIN
	
    ON EXCEPTION SET iSqlErr
        LET cCodRet = iSqlErr;
        
        UPDATE {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
               bdicnweb:"informix".sw_verificaprocesosaldos_sucg
           SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
         WHERE usuario_insert = TRIM(pUsuario);
        
        RETURN cCodRet, iNumRegistros;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/tmp/mfinis/sp_detallesaldoscierrediario_totales.out';
    --TRACE ON;
    
    -- SE LIMPIA TABLA POR USUARIO
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    DELETE FROM {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
           bdicnweb:"informix".sw_verificaprocesosaldos_sucg 
     WHERE usuario_insert = TRIM(pUsuario);
    
    -- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
    INSERT INTO bdicnweb:"informix".sw_verificaprocesosaldos_sucg(usuario_insert,status,error_proceso,error,total_registros)
    VALUES(pUsuario,'I','',TRIM(cCodRet),iNumRegistros);  
    
    IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
        LET cCodRet = '00003';
        
        UPDATE {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
               bdicnweb:"informix".sw_verificaprocesosaldos_sucg
           SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
         WHERE usuario_insert = TRIM(pUsuario);
        
        RETURN cCodRet, iNumRegistros;
    END IF;
    
    -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
    EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        UPDATE {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
               bdicnweb:"informix".sw_verificaprocesosaldos_sucg
           SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
         WHERE usuario_insert = TRIM(pUsuario);
        
        RETURN cCodRet, iNumRegistros;
    END IF;
    
    -- SE LIMPIA TABLA POR USUARIO
    DELETE FROM bdicnweb:"informix".sw_saldoscierre_sucg 
     WHERE usuario_insert = TRIM(pUsuario);
    
    FOREACH
        EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_saldoscierre_sucg(pIdConsulta,pClaveCg,pClaveSuc,pFechaInicio,pFechaFin)
        INTO cCodRetSp, cDescCodRetSp, dFecha, cClave, mCantidad_1, mCantidad_2, mCantidad_3, mCantidad_4, mCantidad_5, 
             mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, mCantidad_15, 
             mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total
        
        IF cCodRetSp::INTEGER < 0 THEN 
            RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisuc:sp_consulta_saldoscierre_sucg';
        END IF;
    
        LET iRecuperacion = iRecuperacion + 1;
        
        INSERT INTO bdicnweb:"informix".sw_saldoscierre_sucg (id_registro, fecha, clave, cantidad_1, cantidad_2, cantidad_3,
        cantidad_4, cantidad_5, cantidad_6, cantidad_8, cantidad_9, cantidad_10, cantidad_11, cantidad_12, cantidad_13, cantidad_14,
        cantidad_15, cantidad_16, cantidad_17, cantidad_18, saldo_total_b, saldo_total_m, saldo_total, usuario_insert)
        VALUES(iRecuperacion, dFecha,cClave,  mCantidad_1, mCantidad_2, mCantidad_3, 
        mCantidad_4, mCantidad_5, mCantidad_6, mCantidad_8, mCantidad_9, mCantidad_10, mCantidad_11, mCantidad_12, mCantidad_13, mCantidad_14, 
        mCantidad_15, mCantidad_16, mCantidad_17, mCantidad_18, mSaldo_total_b, mSaldo_total_m, mSaldo_total, TRIM(pUsuario));
    END FOREACH;
    
    SELECT COUNT(*)
      INTO iNumRegistros
      FROM bdicnweb:"informix".sw_saldoscierre_sucg
     WHERE usuario_insert = TRIM(pUsuario);
    
    IF NVL(iNumRegistros,0) = 0 THEN
        LET cCodRet = '00017';
    END IF;
    
    UPDATE {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
           bdicnweb:"informix".sw_verificaprocesosaldos_sucg
       SET status = 'T', error_proceso = '', error = TRIM(cCodRet), total_registros = NVL(iNumRegistros,0) 
     WHERE usuario_insert = TRIM(pUsuario);
    
    RETURN cCodRet, iNumRegistros;
		
	END;	
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que se encarga de consultar el número total de registros de saldos de cierre diario por denominaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatussaldos_sucg(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error,
			  INTEGER AS num_registros;
			  
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
        RETURN cCodRet,cStatus,cErrorProceso,cError,iNumRegistros;	
    END EXCEPTION;
 
    --SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatussaldos_sucg.out';
    --TRACE ON;
    
    ---VALIDACION DE CAMPOS REQUERIDOS
    IF pUsuario = '' OR pIdFuncion = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet,cStatus,cErrorProceso,cError,iNumRegistros;	
    END IF;		
    
    -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
    EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet,cStatus,cErrorProceso,cError,iNumRegistros;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT {+index(bdicnweb:"informix".sw_verificaprocesosaldos_sucg idx_verificaprocesosaldos_usuario)}
           status,error_proceso,error,total_registros
      INTO cStatus,cErrorProceso,cError,iNumRegistros
      FROM bdicnweb:"informix".sw_verificaprocesosaldos_sucg 
     WHERE usuario_insert = TRIM(pUsuario);
    
    IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
        RETURN cCodRet,'I',cErrorProceso,cError,iNumRegistros; 
    ELSE 			
        RETURN cCodRet,cStatus,cErrorProceso,cError,iNumRegistros;		
    END IF;	
		
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 15/03/2017',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: SALDOS DE CIERRE DIARIO', 
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar el detalle de saldos de cierre diario por denominaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardamodificacionsaldosctascap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20),
pImpchqsbcAntes MONEY(14,2), pImpchqsbgAntes MONEY(14,2), pSdoretenidoAntes MONEY(14,2), pSdocongAntes MONEY(14,2), pCompendienteAntes MONEY(14,2), pFechaprocesoAntes DATE,
pImpchqsbcDesp MONEY(14,2), pImpchqsbgDesp MONEY(14,2), pSdoretenidoDesp MONEY(14,2), pSdocongDesp MONEY(14,2), pCompendienteDesp MONEY(14,2), pFechaprocesoDesp DATE)
	RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardamodificacionsaldosctascap.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;

		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pFechaprocesoAntes IS NULL OR pFechaprocesoDesp IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		UPDATE bdicheq:"informix".sc_maechq 
		SET imp_chq_sbc = pImpchqsbcDesp, imp_chq_sbg = pImpchqsbgDesp, sdo_retenido = pSdoretenidoDesp, 
		sdo_cong = pSdocongDesp, com_pendiente = pCompendienteDesp, fecha_proceso = pFechaprocesoDesp
		WHERE cuenta = pCuenta;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
		ELSE
		    IF pImpchqsbcAntes <> pImpchqsbcDesp THEN
		       IF pImpchqsbcDesp = 0 THEN
		          UPDATE bdicheq:sc_docret_sbc SET cancelado = 'S'
			       WHERE cuenta = pCuenta
				     AND cancelado = 'T';
		       END IF;
            END IF;		   
		
			INSERT INTO bdicnweb:"informix".sw_bitacora_maech(usuario,fecha,hora,cuenta,
			imp_chq_sbc_antes,imp_chq_sbg_antes,sdo_retenido_antes,sdo_cong_antes,com_pendiente_antes,fecha_proceso_antes,
			imp_chq_sbc_desp,imp_chq_sbg_desp,sdo_retenido_desp,sdo_cong_desp,com_pendiente_desp,fecha_proceso_desp)
			VALUES(pUsuario,DATE(CURRENT),TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S %p'),pCuenta,
			pImpchqsbcAntes,pImpchqsbgAntes,pSdoretenidoAntes,pSdocongAntes,pCompendienteAntes,pFechaprocesoAntes,
			pImpchqsbcDesp,pImpchqsbgDesp,pSdoretenidoDesp,pSdocongDesp,pCompendienteDesp,pFechaprocesoDesp);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
		END IF;
		
		RETURN cCodRet;		
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 18/05/2017',
'MODULO: DEBITO',
'FUNCIONALIDAD: MANTENIMIENTO SALDOS CUENTAS CAPTACIÓN', 
'DESCRIPCION: SPL encargado de guardar el mantenimiento de los saldos aplicados a las cuentas de captación.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultacontroloperativo(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(15),pTipoRemesa CHAR(1))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_operaciones_rec_por_mes,
		DECIMAL(16,2) AS importe_total_rec_por_mes,
		INTEGER AS num_operaciones_permitidas_mes,
		DECIMAL(16,2) AS importe_total_por_mes,
		DECIMAL(16,2) AS importe_total_por_dia;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNumOpeRecMes INTEGER;
	DEFINE dImporteTotRecMes DECIMAL(16,2);
	DEFINE iNumOpePermMes INTEGER;
	DEFINE dImporteTotPerMes DECIMAL(16,2);
	DEFINE dImporteTotPorDia DECIMAL(16,2);
	DEFINE dFechaPrimerDia DATE;
	DEFINE cNumConvenio CHAR(3);
	DEFINE cAbreviaturaMes CHAR(8);
	DEFINE cAbreviaturaDia CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNumOpeRecMes = 0;
	LET dImporteTotRecMes = 0;
	LET iNumOpePermMes = 0;
	LET dImporteTotPerMes = 0;
	LET dImporteTotPorDia = 0;
	LET dFechaPrimerDia = NULL;
	LET cNumConvenio = '';
	LET cAbreviaturaMes = '';
	LET cAbreviaturaDia = '';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumOpeRecMes, dImporteTotRecMes, iNumOpePermMes, dImporteTotPerMes, dImporteTotPorDia;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultacontroloperativo.out';
		--TRACE ON;

		-- VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoRemesa = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumOpeRecMes, dImporteTotRecMes, iNumOpePermMes, dImporteTotPerMes, dImporteTotPorDia;
		END IF;

		-- VALIDACION TIPO DE REMESA
		IF pTipoRemesa NOT IN ('1','2') THEN
			LET cCodRet = '00148'; --LA OPERACIÓN A REALIZAR ES INCORRECTA
			RETURN cCodRet, iNumOpeRecMes, dImporteTotRecMes, iNumOpePermMes, dImporteTotPerMes, dImporteTotPorDia;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumOpeRecMes, dImporteTotRecMes, iNumOpePermMes, dImporteTotPerMes, dImporteTotPorDia;
		END IF;
		
		LET dFechaPrimerDia = MDY(MONTH(TODAY), 1, YEAR(TODAY));
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- REMESA BTS
		IF pTipoRemesa = '1' THEN
			
			LET cNumConvenio = '004';
			LET cAbreviaturaMes = 'BTS_MES_';
			LET cAbreviaturaDia = 'BTS_DIA_';
			
		END IF;
		
		-- REMESA APPRIZA
		IF pTipoRemesa = '2' THEN
			
			LET cNumConvenio = '009';
			LET cAbreviaturaMes = 'APP_MES_';
			LET cAbreviaturaDia = 'APP_DIA_';
			
		END IF;	
		
		IF pRfc <> '' THEN
		
			SELECT COUNT(*) AS numOperacionesRecMes, NVL(SUM(importe_pago),0) AS importeTotRecMes
			INTO iNumOpeRecMes, dImporteTotRecMes
			FROM bdisac:"informix".sac_remesas_estadistica
			WHERE numcategoria = '07' 
			AND numconvenio = cNumConvenio
			AND rfc = TRIM(pRfc) 
			AND fecha_pago BETWEEN dFechaPrimerDia AND TODAY;
		
		END IF;
		
		SELECT operaciones, pesos
		INTO iNumOpePermMes, dImporteTotPerMes
		FROM bdisac:"informix".sac_limite_monto
		WHERE abreviatura = cAbreviaturaMes;			
		
		SELECT pesos
		INTO dImporteTotPorDia
		FROM bdisac:"informix".sac_limite_monto
		WHERE abreviatura = cAbreviaturaDia;
		
		RETURN cCodRet, iNumOpeRecMes, dImporteTotRecMes, iNumOpePermMes, dImporteTotPerMes, dImporteTotPorDia;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/05/2018',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: Consulta totales para control operativo de remesas BTS y APRIZA',
'pTipoRemesa: 1 = BTS, 2 = APPRIZA',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultasacappqryi2_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumRem CHAR(12), pRCode CHAR(4), pIdRegistro INTEGER) 
    RETURNING CHAR(5) AS codRet,		
		CHAR(20) AS cCustomerNumber_b,
		CHAR(40) AS cFirstName_b,
		CHAR(40) AS cMiddleName_b,
		CHAR(40) AS cLastName_b,
		CHAR(40) AS cMotherMaidenName_b,
		CHAR(40) AS cFirstName_f,
		CHAR(40) AS cMiddleName_f,
		CHAR(40) AS cLastName_f,
		CHAR(40) AS cMotherMaidenName_f,
		CHAR(80) AS cAddress_b,
		CHAR(40) AS cCity_b,
		CHAR(3) AS  cCountryCode_b,
		CHAR(3) AS  cStateCode_b,
		CHAR(10) AS cZipCode_b,
		CHAR(100) AS cEmail,
		CHAR(15) AS cHomePhoneNumber,
		CHAR(15) AS cWorkPhoneNumber,
		CHAR(15) AS cNumber_cl,
		CHAR(3) AS  cReceiveEmail,
		CHAR(3) AS  cReceiveSMS,
		CHAR(3) AS  cTypeCode_ib,
		CHAR(20) AS cNumber_ib,
		CHAR(8) AS  cExpirationDate_ib,
		CHAR(3) AS  cIssuerCountryCode_ib,
		CHAR(3) AS  cIssuerStateCode_ib,
		CHAR(3) AS  cReasonTypeCode,
		CHAR(40) AS cReasonForTransfer,
		CHAR(40) AS cSourceOfFunds,
		CHAR(40) AS cSecurityPhrase,
		CHAR(255) AS cFreeMessage,
		CHAR(8) AS  cUsuarioInsert,
		CHAR(25) AS cFechaInser,
		CHAR(255) AS cDescription_osc,
		CHAR(16) AS cFolio_suc,
		CHAR(4) AS cId_sucursal,
		CHAR(40) AS cDesc_sucursal,
		CHAR(3) AS cR_typecode_i,
		CHAR(20) AS cR_number,
		CHAR(80) AS cR_address_b,
		CHAR(10) AS cR_zipcode_b,
		CHAR(40) AS cR_city_b,
		CHAR(3) AS cR_statecode_b,
		CHAR(3) AS cR_countrycode_b,
		CHAR(15) AS cR_homephonenum,
		CHAR(1) AS cForma_pago,
		CHAR(8) AS cDate_Birth,
		CHAR(3) AS cIss_Uercc,
		CHAR(5) AS cContry_Code;		
	
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSqlErr 					INT;
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE iCodRetSp 				INTEGER;
	DEFINE cDescCodRet 				CHAR(80);
	DEFINE cEmpresa 				CHAR(3);
	
	DEFINE cTxn_status				CHAR(1);
	DEFINE cUnirefnum				CHAR(16);
	DEFINE cCode_Company			CHAR(3);
	DEFINE cChanneldid				CHAR(3);
	DEFINE cLocationunit			CHAR(15);
	DEFINE cNnumber					CHAR(15);
	DEFINE cTypecode_Branch			CHAR(3);	
	DEFINE cCountrycode_Branch		CHAR(3);
	DEFINE cStatecode_Branch		CHAR(3);
	DEFINE cTerminalid				CHAR(15);
	DEFINE cProcessdate_Qry			CHAR(8);
	DEFINE cProcesstime_Qry			CHAR(6);
	DEFINE cCode_Operacion			CHAR(5);
	DEFINE cCode					CHAR(4);
	DEFINE cMensCode				CHAR(255);
	DEFINE cCode_d					CHAR(4);
	DEFINE cMensajeD				CHAR(255);
	DEFINE cProcessDate				CHAR(8);
	DEFINE cProcessTime				CHAR(6);
	DEFINE cRule					CHAR(3);
	DEFINE cValue					CHAR(3);
	DEFINE cGlobalTrackingNumber	CHAR(20);
	DEFINE cOrderStatusCode			CHAR(3);
	DEFINE cOrderStatusDate			CHAR(8);
	DEFINE cOrderStatusTime			CHAR(6);
	DEFINE cUniqueReferenceNumber	CHAR(16);
	DEFINE cCodesalecom				CHAR(3);
	DEFINE cCountryCode				CHAR(3);
	DEFINE cStateCodeSale			CHAR(3);
	DEFINE cSaleDate				CHAR(8);
	DEFINE cSaleTime				CHAR(6);
	DEFINE cCountryCode_o			CHAR(3);
	DEFINE cCurrencyCode			CHAR(3);
	DEFINE cServiceCode				CHAR(3);
	DEFINE cCountryCode_d			CHAR(3);
	DEFINE cCurrencyCode_d			CHAR(3);
	DEFINE cDeliveryMethodCode		CHAR(3);
	DEFINE cPayNetworkCode			CHAR(3);
	DEFINE cPaySubNetworkCode		CHAR(15);
	DEFINE cBranchNumber			CHAR(15);
	DEFINE cAccountTypeCode			CHAR(3);
	DEFINE cAccountNumber			CHAR(30);
	DEFINE cOriginAmount			CHAR(20);
	DEFINE cDestinationAmount		CHAR(20);
	DEFINE cRetailExchangeRate		CHAR(21);
	DEFINE cWholesaleExchangeRate	CHAR(21);
	DEFINE cDestinExchangeRate 		CHAR(21);
	DEFINE cServiceFeeAmount		CHAR(20);
	DEFINE cDiscountAmount			CHAR(20);
	DEFINE cTypeCode				CHAR(3);
	DEFINE cAccountNumber_c			CHAR(30);
	DEFINE cBicCode					CHAR(11);
	DEFINE cReferenceNumber			CHAR(30);
	DEFINE cCustomerNumber			CHAR(20);
	DEFINE cFirstName				CHAR(40);
	DEFINE cMiddleName				CHAR(40);
	DEFINE cLastName				CHAR(40);
	DEFINE cMotherMaidenName		CHAR(40);
	DEFINE cAddress					CHAR(80);
	DEFINE cCity					CHAR(40);
	DEFINE cCountryCode_a			CHAR(3);
	DEFINE cStateCode				CHAR(3);
	DEFINE cZipCode					CHAR(10);
	DEFINE cTypeCode_i				CHAR(3);
	DEFINE cNumber					CHAR(20);
	DEFINE cExpirationDate			CHAR(8);
	DEFINE cIssuerCountryCode		CHAR(3);
	DEFINE cIssuerStateCode			CHAR(3);
	DEFINE cDateOfBirth				CHAR(8);
	DEFINE cCustomerNumber_b		CHAR(20);
	DEFINE cFirstName_b				CHAR(40);
	DEFINE cMiddleName_b			CHAR(40);
	DEFINE cLastName_b				CHAR(40);
	DEFINE cMotherMaidenName_b		CHAR(40);
	DEFINE cFirstName_f				CHAR(40);
	DEFINE cMiddleName_f			CHAR(40);
	DEFINE cLastName_f				CHAR(40);
	DEFINE cMotherMaidenName_f		CHAR(40);
	DEFINE cAddress_b				CHAR(80);
	DEFINE cCity_b					CHAR(40);
	DEFINE cCountryCode_b			CHAR(3);
	DEFINE cStateCode_b				CHAR(3);
	DEFINE cZipCode_b				CHAR(10);
	DEFINE cEmail					CHAR(100);
	DEFINE cHomePhoneNumber			CHAR(15);
	DEFINE cWorkPhoneNumber			CHAR(15);
	DEFINE cNumber_cl				CHAR(15);
	DEFINE cReceiveEmail			CHAR(3);
	DEFINE cReceiveSMS				CHAR(3);
	DEFINE cTypeCode_ib				CHAR(3);
	DEFINE cNumber_ib				CHAR(20);
	DEFINE cExpirationDate_ib		CHAR(8);
	DEFINE cIssuerCountryCode_ib	CHAR(3);
	DEFINE cIssuerStateCode_ib		CHAR(3);
	DEFINE cReasonTypeCode			CHAR(3);
	DEFINE cReasonForTransfer		CHAR(40);
	DEFINE cSourceOfFunds			CHAR(40);
	DEFINE cSecurityPhrase			CHAR(40);
	DEFINE cFreeMessage				CHAR(255);
	DEFINE cUsuarioInsert			CHAR(8);
	DEFINE cFechaInser				DATETIME YEAR TO FRACTION(5);
	DEFINE cDescription_osc			CHAR(255);
	DEFINE cFolio_suc				CHAR(16);
	DEFINE cId_sucursal				CHAR(4);
	DEFINE cDesc_sucursal 			CHAR(40);
	DEFINE cR_typecode_i 			CHAR(3);
	DEFINE cR_number 				CHAR(20);
	DEFINE cR_address_b 			CHAR(80);
	DEFINE cR_zipcode_b 			CHAR(10);
	DEFINE cR_city_b 				CHAR(40);
	DEFINE cR_statecode_b 			CHAR(3);
	DEFINE cR_countrycode_b 		CHAR(3);
	DEFINE cR_homephonenum 			CHAR(15);
	DEFINE cForma_pago 			    CHAR(1);	
	DEFINE cDateBirth				CHAR(8);
	DEFINE cIssuercc           	    CHAR(3);
	DEFINE cContryCode         	    CHAR(5);
	DEFINE dFechaInicial			DATE;
	DEFINE dFechaHoy				DATE;
	DEFINE iOperacionesRec			SMALLINT;
	DEFINE mImporteMesRec			MONEY(18,2);
	DEFINE iOperacionesRecTot		SMALLINT;
	DEFINE mImporteMesRecTot		MONEY(18,2);
	DEFINE iOperacionesPer			SMALLINT;
	DEFINE mImporteMesPer			MONEY(16,2);
	DEFINE mImporteDiaPer			MONEY(16,2);
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cDescCodRet 				= '';
	LET cEmpresa 					= '001';
	
	LET cTxn_status					= '';
	LET cUnirefnum					= '';
	LET cCode_Company				= '';
	LET cChanneldid					= '';
	LET cLocationunit				= '';
	LET cNnumber					= '';
	LET cTypecode_Branch			= '';
	LET cCountrycode_Branch			= '';
	LET cStatecode_Branch			= '';
	LET cTerminalid					= '';
	LET cProcessdate_Qry			= '';
	LET cProcesstime_Qry			= '';
	LET cCode_Operacion				= '';
	LET cCode						= '';
	LET cMensCode					= '';
	LET cCode_d						= '';
	LET cMensajeD					= '';
	LET cProcessDate				= '';
	LET cProcessTime				= '';
	LET cRule						= '';
	LET cValue						= '';
	LET cGlobalTrackingNumber		= '';
	LET cOrderStatusCode			= '';
	LET cOrderStatusDate			= '';
	LET cOrderStatusTime			= '';
	LET cUniqueReferenceNumber		= '';
	LET cCodesalecom				= '';
	LET cCountryCode				= '';
	LET cStateCodeSale				= '';
	LET cSaleDate					= '';
	LET cSaleTime					= '';
	LET cCountryCode_o				= '';
	LET cCurrencyCode				= '';
	LET cServiceCode				= '';
	LET cCountryCode_d				= '';
	LET cCurrencyCode_d				= '';
	LET cDeliveryMethodCode			= '';
	LET cPayNetworkCode				= '';
	LET cPaySubNetworkCode			= '';
	LET cBranchNumber				= '';
	LET cAccountTypeCode			= '';
	LET cAccountNumber				= '';
	LET cOriginAmount				= '';
	LET cDestinationAmount			= '';
	LET cRetailExchangeRate			= '';
	LET cWholesaleExchangeRate		= '';
	LET cDestinExchangeRate 		= '';
	LET cServiceFeeAmount			= '';
	LET cDiscountAmount				= '';
	LET cTypeCode					= '';
	LET cAccountNumber_c			= '';
	LET cBicCode					= '';
	LET cReferenceNumber			= '';
	LET cCustomerNumber				= '';
	LET cFirstName					= '';
	LET cMiddleName					= '';
	LET cLastName					= '';
	LET cMotherMaidenName			= '';
	LET cAddress					= '';
	LET cCity						= '';
	LET cCountryCode_a				= '';
	LET cStateCode					= '';
	LET cZipCode					= '';
	LET cTypeCode_i					= '';
	LET cNumber						= '';
	LET cExpirationDate				= '';
	LET cIssuerCountryCode			= '';
	LET cIssuerStateCode			= '';
	LET cDateOfBirth				= '';
	LET cCustomerNumber_b			= '';
	LET cFirstName_b				= '';
	LET cMiddleName_b				= '';
	LET cLastName_b					= '';
	LET cMotherMaidenName_b			= '';
	LET cFirstName_f				= '';
	LET cMiddleName_f				= '';
	LET cLastName_f					= '';
	LET cMotherMaidenName_f			= '';
	LET cAddress_b					= '';
	LET cCity_b						= '';
	LET cCountryCode_b				= '';
	LET cStateCode_b				= '';
	LET cZipCode_b					= '';
	LET cEmail						= '';
	LET cHomePhoneNumber			= '';
	LET cWorkPhoneNumber			= '';
	LET cNumber_cl					= '';
	LET cReceiveEmail				= '';
	LET cReceiveSMS					= '';
	LET cTypeCode_ib				= '';
	LET cNumber_ib					= '';
	LET cExpirationDate_ib			= '';
	LET cIssuerCountryCode_ib		= '';
	LET cIssuerStateCode_ib			= '';
	LET cReasonTypeCode				= '';
	LET cReasonForTransfer			= '';
	LET cSourceOfFunds				= '';
	LET cSecurityPhrase				= '';
	LET cFreeMessage				= '';
	LET cUsuarioInsert				= '';
	LET cFechaInser					= '';
	LET cDescription_osc			= '';
	LET cFolio_suc					= '';
	LET cId_sucursal				= '';
	LET cDesc_sucursal 				= '';
	LET cR_typecode_i               = '';
	LET cR_number                   = '';
	LET cR_address_b                = '';
	LET cR_zipcode_b                = '';
	LET cR_city_b                   = '';
	LET cR_statecode_b              = '';
	LET cR_countrycode_b            = '';
	LET cR_homephonenum             = '';
	LET cForma_pago 	            = '';	
	LET cDateBirth					= '';
	LET cIssuercc           		= '';
	LET cContryCode         		= '';
	LET dFechaInicial				= '';
	LET dFechaHoy					= '';
	LET iOperacionesRec				= 0;
	LET mImporteMesRec			    = 0.00;
	LET iOperacionesRecTot			= 0;
	LET mImporteMesRecTot		    = 0.00; 
	LET iOperacionesPer				= 0;
	LET mImporteMesPer			    = 0.00;
	LET mImporteDiaPer			    = 0.00;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCustomerNumber_b,
				cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
				cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
				cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
				cDescription_osc,cFolio_suc,cId_sucursal,cDesc_sucursal,
				cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cForma_pago,
				cDateBirth,cIssuercc,cContryCode;		
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultasacappqryi2_2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumRem = '' OR pRCode = '' OR pIdRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCustomerNumber_b,
			cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
			cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
			cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
			cDescription_osc,cFolio_suc,cId_sucursal,cDesc_sucursal,
			cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cForma_pago,
			cDateBirth,cIssuercc,cContryCode;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCustomerNumber_b,
			cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
			cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
			cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
			cDescription_osc,cFolio_suc,cId_sucursal,cDesc_sucursal,
			cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cForma_pago,
			cDateBirth,cIssuercc,cContryCode;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		SELECT r_customernum_b,
		r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,
		r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,
		r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha,
		description_osc,folio_sucursal,id_sucursal,desc_sucursal,
		typecodeci,numberci,adress,zipcode,city,statecodeadr,countrycodeadr,homephonenum,forma_pago,
		date_birth,iss_uercc,contry_code
		INTO cCustomerNumber_b,
		cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
		cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
		cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
		cDescription_osc,cFolio_suc,cId_sucursal,cDesc_sucursal,
		cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cForma_pago,
		cDateBirth,cIssuercc,cContryCode
		FROM "informix".sw_verifica_estatusrem
		WHERE unirefnum = pNumRem AND r_code = pRCode
		AND id_registro = pIdRegistro AND usuario_insert_proc = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';		
		END IF;
		
		RETURN cCodRet,cCustomerNumber_b,
		cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
		cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
		cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
		cDescription_osc,cFolio_suc,cId_sucursal,cDesc_sucursal,
		cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cForma_pago,
		cDateBirth,cIssuercc,cContryCode;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar el detalle del pago de remesas Appriza Pay.',
'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 27/10/2017',
'DESCRIPCION: SE AGREGARON LOS SIGUIENTES CAMPOS DATEOFBIRTH,ISSUERCC,CONTRYCODE PARA EL RETORNO DE DATOS DE LAS TABLA',
'BDISAC:SAC_APP_PAYI Y BDISAC:SAC_APP_PAYI_OLD',
'AUTOR: L. Montserrat León Amador',
'FECHA 21/05/2018',
'DESCRIPCION: Se realiza clon de spl sp_rem_consultasacappqryi2.',
'Se actualiza la tabla para la consulta de los campos correspondientes al panel datos de pago.',
'Se actualizan campos para recuperar información correspondiente al panel dirección del beneficiario.',
'Se implementa la consulta a la tabla que controla el timeout del proceso para la obtención de todos los campos,',
'ya que esta tabla se llena mediante un proceso anterior (sp_rem_consultasacappqryi) de acuerdo a las reglas de negocio establecidas.',
'AUTOR: L. Montserrat León Amador',
'FECHA 30/07/2018',
'DESCRIPCION: Se realiza cambio de nomenclatura a la tabla sp_rem_statusappqryi2 por sw_verifica_estatusrem.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_verificastatusappqryi(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumRem CHAR(12), pRCode CHAR(4))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error,
			  INTEGER AS id_registro,
			  CHAR(1) AS cTxn_status,
			  CHAR(16) AS cUnirefnum,
			  CHAR(3) AS cCode_Company,
			  CHAR(3) AS cChanneldid,
			  CHAR(15) AS cLocationunit,
			  CHAR(15) AS cNnumber,
			  CHAR(3) AS cTypecode_Branch,
			  CHAR(3) AS cCountrycode_Branch,
			  CHAR(3) AS cStatecode_Branch,
			  CHAR(15) AS cTerminalid,
			  CHAR(8) AS cProcessdate_Qry,
			  CHAR(6) AS cProcesstime_Qry,
			  CHAR(5) AS cCode_Operacion,
			  CHAR(4) AS cCode,
			  CHAR(255) AS cMensCode,
			  CHAR(4) AS cCode_d,
			  CHAR(255) AS cMensajeD,
			  CHAR(8) AS cProcessDate,
			  CHAR(6) AS cProcessTime,
			  CHAR(3) AS cRule,
			  CHAR(3) AS cValue,
			  CHAR(20) AS cGlobalTrackingNumber,
			  CHAR(3) AS cOrderStatusCode,
			  CHAR(8) AS cOrderStatusDate,
			  CHAR(6) AS cOrderStatusTime,
			  CHAR(16) AS cUniqueReferenceNumber,
			  CHAR(3) AS cCodesalecom,
			  CHAR(3) AS cCountryCode,
			  CHAR(3) AS cStateCodeSale,
			  CHAR(8) AS cSaleDate,
			  CHAR(6) AS cSaleTime,
			  CHAR(3) AS cCountryCode_o,
			  CHAR(3) AS cCurrencyCode,
			  CHAR(3) AS cServiceCode,
			  CHAR(3) AS cCountryCode_d,
			  CHAR(3) AS cCurrencyCode_d,
			  CHAR(3) AS cDeliveryMethodCode,
			  CHAR(3) AS cPayNetworkCode,
			  CHAR(15) AS cPaySubNetworkCode,
			  CHAR(15) AS cBranchNumber,
			  CHAR(3) AS  cAccountTypeCode,
			  CHAR(30) AS cAccountNumber,
			  CHAR(20) AS cOriginAmount,
			  CHAR(20) AS cDestinationAmount,
			  CHAR(21) AS cRetailExchangeRate,
			  CHAR(21) AS cWholesaleExchangeRate,
			  CHAR(21) AS cDestinExchangeRate,
			  CHAR(20) AS cServiceFeeAmount,
			  CHAR(20) AS cDiscountAmount,
			  CHAR(3) AS  cTypeCode,
			  CHAR(30) AS cAccountNumber_c,
			  CHAR(11) AS cBicCode,
			  CHAR(30) AS cReferenceNumber,
			  CHAR(20) AS cCustomerNumber,
			  CHAR(40) AS cFirstName,
			  CHAR(40) AS cMiddleName,
			  CHAR(40) AS cLastName,
			  CHAR(40) AS cMotherMaidenName,
			  CHAR(80) AS cAddress,
			  CHAR(40) AS cCity,
			  CHAR(3) AS cCountryCode_a,
			  CHAR(3) AS cStateCode,
			  CHAR(10) AS cZipCode,
			  CHAR(3) AS cTypeCode_i,
			  CHAR(20) AS cNumber,
			  CHAR(8) AS cExpirationDate,
			  CHAR(3) AS cIssuerCountryCode,
			  CHAR(3) AS cIssuerStateCode,
			  CHAR(8) AS cDateOfBirth,
			  CHAR(8) AS cUsuarioInsert,
			  CHAR(25) AS cFechaInser;
			  
	
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSqlErr 					INTEGER;
	DEFINE cEmpresa 				CHAR(3);	
	DEFINE cStatus 					CHAR(1);
	DEFINE cErrorProceso 			CHAR(1);
	DEFINE cError 					CHAR(5);
	DEFINE iIdRegistro				INTEGER;
	
	DEFINE cTxn_status				CHAR(1);
	DEFINE cUnirefnum				CHAR(16);
	DEFINE cCode_Company			CHAR(3);
	DEFINE cChanneldid				CHAR(3);
	DEFINE cLocationunit			CHAR(15);
	DEFINE cNnumber					CHAR(15);
	DEFINE cTypecode_Branch			CHAR(3);	
	DEFINE cCountrycode_Branch		CHAR(3);
	DEFINE cStatecode_Branch		CHAR(3);
	DEFINE cTerminalid				CHAR(15);
	DEFINE cProcessdate_Qry			CHAR(8);
	DEFINE cProcesstime_Qry			CHAR(6);
	DEFINE cCode_Operacion			CHAR(5);
	DEFINE cCode					CHAR(4);
	DEFINE cMensCode				CHAR(255);
	DEFINE cCode_d					CHAR(4);
	DEFINE cMensajeD				CHAR(255);
	DEFINE cProcessDate				CHAR(8);
	DEFINE cProcessTime				CHAR(6);
	DEFINE cRule					CHAR(3);
	DEFINE cValue					CHAR(3);
	DEFINE cGlobalTrackingNumber	CHAR(20);
	DEFINE cOrderStatusCode			CHAR(3);
	DEFINE cOrderStatusDate			CHAR(8);
	DEFINE cOrderStatusTime			CHAR(6);
	DEFINE cUniqueReferenceNumber	CHAR(16);
	DEFINE cCodesalecom				CHAR(3);
	DEFINE cCountryCode				CHAR(3);
	DEFINE cStateCodeSale			CHAR(3);
	DEFINE cSaleDate				CHAR(8);
	DEFINE cSaleTime				CHAR(6);
	DEFINE cCountryCode_o			CHAR(3);
	DEFINE cCurrencyCode			CHAR(3);
	DEFINE cServiceCode				CHAR(3);
	DEFINE cCountryCode_d			CHAR(3);
	DEFINE cCurrencyCode_d			CHAR(3);
	DEFINE cDeliveryMethodCode		CHAR(3);
	DEFINE cPayNetworkCode			CHAR(3);
	DEFINE cPaySubNetworkCode		CHAR(15);
	DEFINE cBranchNumber			CHAR(15);
	DEFINE cAccountTypeCode			CHAR(3);
	DEFINE cAccountNumber			CHAR(30);
	DEFINE cOriginAmount			CHAR(20);
	DEFINE cDestinationAmount		CHAR(20);
	DEFINE cRetailExchangeRate		CHAR(21);
	DEFINE cWholesaleExchangeRate	CHAR(21);
	DEFINE cDestinExchangeRate 		CHAR(21);
	DEFINE cServiceFeeAmount		CHAR(20);
	DEFINE cDiscountAmount			CHAR(20);
	DEFINE cTypeCode				CHAR(3);
	DEFINE cAccountNumber_c			CHAR(30);
	DEFINE cBicCode					CHAR(11);
	DEFINE cReferenceNumber			CHAR(30);
	DEFINE cCustomerNumber			CHAR(20);
	DEFINE cFirstName				CHAR(40);
	DEFINE cMiddleName				CHAR(40);
	DEFINE cLastName				CHAR(40);
	DEFINE cMotherMaidenName		CHAR(40);
	DEFINE cAddress					CHAR(80);
	DEFINE cCity					CHAR(40);
	DEFINE cCountryCode_a			CHAR(3);
	DEFINE cStateCode				CHAR(3);
	DEFINE cZipCode					CHAR(10);
	DEFINE cTypeCode_i				CHAR(3);
	DEFINE cNumber					CHAR(20);
	DEFINE cExpirationDate			CHAR(8);
	DEFINE cIssuerCountryCode		CHAR(3);
	DEFINE cIssuerStateCode			CHAR(3);
	DEFINE cDateOfBirth				CHAR(8);
	DEFINE cUsuarioInsert			CHAR(8);
	DEFINE cFechaInser				DATETIME YEAR TO FRACTION(5);
	
	DEFINE cCustomerNumber_b		CHAR(20);
	DEFINE cFirstName_b				CHAR(40);
	DEFINE cMiddleName_b			CHAR(40);
	DEFINE cLastName_b				CHAR(40);
	DEFINE cMotherMaidenName_b		CHAR(40);
	DEFINE cFirstName_f				CHAR(40);
	DEFINE cMiddleName_f			CHAR(40);
	DEFINE cLastName_f				CHAR(40);
	DEFINE cMotherMaidenName_f		CHAR(40);
	DEFINE cAddress_b				CHAR(80);
	DEFINE cCity_b					CHAR(40);
	DEFINE cCountryCode_b			CHAR(3);
	DEFINE cStateCode_b				CHAR(3);
	DEFINE cZipCode_b				CHAR(10);
	DEFINE cEmail					CHAR(100);
	DEFINE cHomePhoneNumber			CHAR(15);
	DEFINE cWorkPhoneNumber			CHAR(15);
	DEFINE cNumber_cl				CHAR(15);
	DEFINE cReceiveEmail			CHAR(3);
	DEFINE cReceiveSMS				CHAR(3);
	DEFINE cTypeCode_ib				CHAR(3);
	DEFINE cNumber_ib				CHAR(20);
	DEFINE cExpirationDate_ib		CHAR(8);
	DEFINE cIssuerCountryCode_ib	CHAR(3);
	DEFINE cIssuerStateCode_ib		CHAR(3);
	DEFINE cReasonTypeCode			CHAR(3);
	DEFINE cReasonForTransfer		CHAR(40);
	DEFINE cSourceOfFunds			CHAR(40);
	DEFINE cSecurityPhrase			CHAR(40);
	DEFINE cFreeMessage				CHAR(255);
	--DEFINE cUsuarioInsert			CHAR(8);
	--DEFINE cFechaInser			DATETIME YEAR TO FRACTION(5);
	DEFINE cDescription_osc			CHAR(255);
	DEFINE cFolio_suc				CHAR(16);
	DEFINE cId_sucursal				CHAR(4);
	DEFINE cDesc_sucursal 			CHAR(40);
	DEFINE cR_typecode_i 			CHAR(3);
	DEFINE cR_number 				CHAR(20);
	DEFINE cR_address_b 			CHAR(80);
	DEFINE cR_zipcode_b 			CHAR(10);
	DEFINE cR_city_b 				CHAR(40);
	DEFINE cR_statecode_b 			CHAR(3);
	DEFINE cR_countrycode_b 		CHAR(3);
	DEFINE cR_homephonenum 			CHAR(15);
	DEFINE cForma_pago 			    CHAR(1);	
	DEFINE cDateBirth				CHAR(8);
	DEFINE cIssuercc           	    CHAR(3);
	DEFINE cContryCode         	    CHAR(5);
	DEFINE dFecha_hoy				DATE;
	DEFINE dFecha 					DATE;
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;	
	LET cEmpresa					= '001';
	LET cStatus 					= '';
	LET cErrorProceso 				= '';
	LET cError 						= '';
	LET iIdRegistro					= 0;
	
	LET cTxn_status					= '';
	LET cUnirefnum					= '';
	LET cCode_Company				= '';
	LET cChanneldid					= '';
	LET cLocationunit				= '';
	LET cNnumber					= '';
	LET cTypecode_Branch			= '';
	LET cCountrycode_Branch			= '';
	LET cStatecode_Branch			= '';
	LET cTerminalid					= '';
	LET cProcessdate_Qry			= '';
	LET cProcesstime_Qry			= '';
	LET cCode_Operacion				= '';
	LET cCode						= '';
	LET cMensCode					= '';
	LET cCode_d						= '';
	LET cMensajeD					= '';
	LET cProcessDate				= '';
	LET cProcessTime				= '';
	LET cRule						= '';
	LET cValue						= '';
	LET cGlobalTrackingNumber		= '';
	LET cOrderStatusCode			= '';
	LET cOrderStatusDate			= '';
	LET cOrderStatusTime			= '';
	LET cUniqueReferenceNumber		= '';
	LET cCodesalecom				= '';
	LET cCountryCode				= '';
	LET cStateCodeSale				= '';
	LET cSaleDate					= '';
	LET cSaleTime					= '';
	LET cCountryCode_o				= '';
	LET cCurrencyCode				= '';
	LET cServiceCode				= '';
	LET cCountryCode_d				= '';
	LET cCurrencyCode_d				= '';
	LET cDeliveryMethodCode			= '';
	LET cPayNetworkCode				= '';
	LET cPaySubNetworkCode			= '';
	LET cBranchNumber				= '';
	LET cAccountTypeCode			= '';
	LET cAccountNumber				= '';
	LET cOriginAmount				= '';
	LET cDestinationAmount			= '';
	LET cRetailExchangeRate			= '';
	LET cWholesaleExchangeRate		= '';
	LET cDestinExchangeRate 		= '';
	LET cServiceFeeAmount			= '';
	LET cDiscountAmount				= '';
	LET cTypeCode					= '';
	LET cAccountNumber_c			= '';
	LET cBicCode					= '';
	LET cReferenceNumber			= '';
	LET cCustomerNumber				= '';
	LET cFirstName					= '';
	LET cMiddleName					= '';
	LET cLastName					= '';
	LET cMotherMaidenName			= '';
	LET cAddress					= '';
	LET cCity						= '';
	LET cCountryCode_a				= '';
	LET cStateCode					= '';
	LET cZipCode					= '';
	LET cTypeCode_i					= '';
	LET cNumber						= '';
	LET cExpirationDate				= '';
	LET cIssuerCountryCode			= '';
	LET cIssuerStateCode			= '';
	LET cDateOfBirth				= '';
	LET cUsuarioInsert				= '';
	LET cFechaInser					= '';
	
	LET cCustomerNumber_b			= '';
	LET cFirstName_b				= '';
	LET cMiddleName_b				= '';
	LET cLastName_b					= '';
	LET cMotherMaidenName_b			= '';
	LET cFirstName_f				= '';
	LET cMiddleName_f				= '';
	LET cLastName_f					= '';
	LET cMotherMaidenName_f			= '';
	LET cAddress_b					= '';
	LET cCity_b						= '';
	LET cCountryCode_b				= '';
	LET cStateCode_b				= '';
	LET cZipCode_b					= '';
	LET cEmail						= '';
	LET cHomePhoneNumber			= '';
	LET cWorkPhoneNumber			= '';
	LET cNumber_cl					= '';
	LET cReceiveEmail				= '';
	LET cReceiveSMS					= '';
	LET cTypeCode_ib				= '';
	LET cNumber_ib					= '';
	LET cExpirationDate_ib			= '';
	LET cIssuerCountryCode_ib		= '';
	LET cIssuerStateCode_ib			= '';
	LET cReasonTypeCode				= '';
	LET cReasonForTransfer			= '';
	LET cSourceOfFunds				= '';
	LET cSecurityPhrase				= '';
	LET cFreeMessage				= '';
	--LET cUsuarioInsert			= '';
	--LET cFechaInser				= '';
	LET cDescription_osc			= '';
	LET cFolio_suc					= '';
	LET cId_sucursal				= '';
	LET cDesc_sucursal 				= '';
	LET cR_typecode_i 				= '';
	LET cR_number 					= '';
	LET cR_address_b 				= '';
	LET cR_zipcode_b 				= '';
	LET cR_city_b 					= '';
	LET cR_statecode_b 				= '';
	LET cR_countrycode_b 			= '';
	LET cR_homephonenum 			= '';
	LET cForma_pago 				= '';
	LET cDateBirth					= '';
	LET cIssuercc           		= '';
	LET cContryCode         		= '';
	LET dFecha_hoy					= '';
	LET dFecha 						= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError,iIdRegistro,
			cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
			cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
			cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
			cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
			cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
			cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
			cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,
			cUsuarioInsert,cFechaInser;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_verificastatusappqryi.out';
		--TRACE ON;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pNumRem = '' OR pRCode = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iIdRegistro,
			cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
			cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
			cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
			cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
			cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
			cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
			cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,
			cUsuarioInsert,cFechaInser;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iIdRegistro,
			cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
			cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
			cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
			cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
			cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
			cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
			cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,
			cUsuarioInsert,cFechaInser;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,error_proceso,error,id_registro,
		txn_status,unirefnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,
		processdate,processtime,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,
		r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,
		r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,
		r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,
		r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,
		r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,
		user_insert,fecha
		INTO cStatus,cErrorProceso,cError,iIdRegistro,
		cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
		cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
		cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
		cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
		cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
		cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
		cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,
		cUsuarioInsert,cFechaInser
		FROM "informix".sw_verifica_estatusrem 
		WHERE unirefnum = pNumRem AND r_code = pRCode
		AND usuario_insert_proc = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			LET cStatus = 'I';
		END IF;
		
		RETURN cCodRet,cStatus,cErrorProceso,cError,iIdRegistro,
		cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
		cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
		cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
		cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
		cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
		cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
		cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,
		cUsuarioInsert,cFechaInser;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 11/06/2018',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: Spl encargado de verificar el status de la consulta del detalle del pago de remesas Appriza Pay.',
'AUTOR: L. Montserrat León Amador',
'FECHA 30/07/2018',
'DESCRIPCION: Se realiza cambio de nomenclatura a la tabla sp_rem_statusappqryi2 por sw_verifica_estatusrem.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasconsultawu(pUsuario CHAR(8), pIdFuncion CHAR(10),pMtcn  CHAR(10),pNumeroConvenio CHAR(3))
RETURNING CHAR(5) AS codret,
	CHAR(1)     AS txn_status,
	CHAR(3) 	AS channel_type,
	CHAR(3) 	AS channel_name,
	CHAR(4) 	AS channel_version,
	CHAR(11) 	AS foreign_rs_system_id_rq,
	CHAR(16) 	AS foreign_rs_refnum_rq,
	CHAR(11) 	AS foreign_rs_cntid_rq,
	CHAR(10) 	AS mtcn,
	CHAR(25) 	AS fecha_hora_rq,
	CHAR(5) 	AS retcode,
	CHAR(1) 	AS emisor_nametype,
	CHAR(40) 	AS emisor_nombre1,
	CHAR(40) 	AS emisor_nombre2,
	CHAR(40) 	AS emisor_appaterno,
	CHAR(40) 	AS emisor_apmaterno,
	CHAR(20) 	AS emisor_ciudad,
	CHAR(3) 	AS emisor_edo,
	CHAR(3) 	AS emisor_cod_pais,
	CHAR(3) 	AS emisor_cod_moneda,
	CHAR(8) 	AS emisor_cp,
	CHAR(30) 	AS emisor_calle,
	CHAR(15) 	AS emisor_telefono,
	CHAR(1) 	AS benef_nametype,
	CHAR(40) 	AS benef_nombre1,
	CHAR(40) 	AS benef_nombre2,
	CHAR(40) 	AS benef_appaterno,
	CHAR(40) 	AS benef_apmaterno,
	CHAR(20) 	AS benef_ciudad,
	CHAR(40) 	AS benef_edo,
	CHAR(3) 	AS benef_cod_pais,
	CHAR(3) 	AS benef_cod_moneda,
	CHAR(8) 	AS benef_cp,
	CHAR(30) 	AS benef_calle,
	CHAR(15) 	AS benef_tel_part,
	CHAR(10) 	AS benef_tel_celular,
	CHAR(10) 	AS monto_total_origen,
	CHAR(10) 	AS monto_total_destino,
	CHAR(10) 	AS monto_origen,
	CHAR(10) 	AS monto_cargos,
	CHAR(30) 	AS cd_origen_pago,
	CHAR(10) 	AS tipo_cambio,
	CHAR(8) 	AS fecha_alta_remesa,
	CHAR(16) 	AS hora_alta_remesa,
	CHAR(10) 	AS money_transfer_key,
	CHAR(50) 	AS estatus_remesa,
	CHAR(16) 	AS new_mtcn,
	CHAR(4) 	AS fusion_status,
	CHAR(2) 	AS no_paginas,
	CHAR(2) 	AS pagina_actual,
	CHAR(2) 	AS num_coincidencias,
	CHAR(11) 	AS foreign_rs_system_id_rp,
	CHAR(16) 	AS foreign_rs_refnum_rp,
	CHAR(11) 	AS foreign_rs_cntid_rp,
	CHAR(250) 	AS desc_error,
	CHAR(10) 	AS partnerid_err,
	CHAR(25) 	AS fecha_hora_rp,
	CHAR(8) 	AS user_insert,
	CHAR(25) 	AS fecha_insert,
	CHAR(4)     AS id_sucursal,
	CHAR(16)    AS folio_suc,
	CHAR(1)     AS forma_pago,
	CHAR(255)	AS retcode_traduccion;

DEFINE cCodRet 				CHAR(5);
DEFINE iSqlErr 				INTEGER;
DEFINE cCodRetSp 			CHAR(5);
DEFINE iCodRetSp 			INTEGER;
DEFINE iNoRegistros			INTEGER;
DEFINE cTxnStatus           CHAR(1);     
DEFINE cChannelType         CHAR(3); 	
DEFINE cChannelName         CHAR(3); 	
DEFINE cChannelVersion      CHAR(4); 	
DEFINE cForeignRsSystemIdRq CHAR(11); 	
DEFINE cForeignRsRefnumRq   CHAR(16); 	
DEFINE cForeignRsCntidRq    CHAR(11); 	
DEFINE cMtcn                CHAR(10); 	
DEFINE cFechaHoraRq         DATETIME YEAR to SECOND; 	
DEFINE cRetcode             CHAR(5); 	
DEFINE cEmisorNametype      CHAR(1); 	
DEFINE cEmisorNombre1       CHAR(40); 	
DEFINE cEmisorNombre2       CHAR(40); 	
DEFINE cEmisorAppaterno     CHAR(40); 	
DEFINE cEmisorApmaterno     CHAR(40); 	
DEFINE cEmisorCiudad        CHAR(20); 	
DEFINE cEmisorEdo           CHAR(3); 	
DEFINE cEmisorCodPais       CHAR(3); 	
DEFINE cEmisorCodMoneda     CHAR(3); 	
DEFINE cEmisorCp            CHAR(8); 	
DEFINE cEmisorCalle         CHAR(30); 	
DEFINE cEmisorTelefono      CHAR(15); 	
DEFINE cBenefNametype       CHAR(1); 	
DEFINE cBenefNombre1        CHAR(40); 	
DEFINE cBenefNombre2        CHAR(40); 	
DEFINE cBenefAppaterno      CHAR(40); 	
DEFINE cBenefApmaterno      CHAR(40); 	
DEFINE cBenefCiudad         CHAR(20); 	
DEFINE cBenefEdo            CHAR(40); 	
DEFINE cBenefCodPais        CHAR(3); 	
DEFINE cBenefCodMoneda      CHAR(3); 	
DEFINE cBenefCp             CHAR(8); 	
DEFINE cBenefCalle          CHAR(30); 	
DEFINE cBenefTelPart        CHAR(15); 	
DEFINE cBenefTelCelular     CHAR(10); 	
DEFINE cMontoTotalOrigen    CHAR(10); 	
DEFINE cMontoTotalDestino   CHAR(10); 	
DEFINE cMontoOrigen         CHAR(10); 	
DEFINE cMontoCargos         CHAR(10); 	
DEFINE cCdOrigenPago        CHAR(30); 	
DEFINE cTipoCambio          CHAR(10); 	
DEFINE cFechaAltaRemesa     CHAR(8); 	
DEFINE cHoraAltaRemesa      CHAR(16); 	
DEFINE cMoneyTransferKey    CHAR(10); 	
DEFINE cEstatusRemesa       CHAR(4); 	
DEFINE cDescEstatusRemesa   CHAR(50); 	
DEFINE cNewMtcn             CHAR(16); 	
DEFINE cFusionStatus        CHAR(4); 	
DEFINE cNoPaginas           CHAR(2); 	
DEFINE cPaginaActual        CHAR(2); 	
DEFINE cNumCoincidencias    CHAR(2); 	
DEFINE cForeignRsSystemIdRp CHAR(11); 	
DEFINE cForeignRsRefnumRp   CHAR(16); 	
DEFINE cForeignRsCntidRp    CHAR(11); 	
DEFINE cDescError           CHAR(250); 	
DEFINE cPartneridErr        CHAR(10); 	
DEFINE cFechaHoraRp         DATETIME YEAR to SECOND; 	
DEFINE cUserInsert          CHAR(8); 	
DEFINE cFechaInsert         DATETIME YEAR to SECOND; 	
DEFINE cIdSucursal          CHAR(4);     
DEFINE cFolioSuc            CHAR(16);  
DEFINE cFormaPago			CHAR(1);
DEFINE cRetcodeTraduccion	CHAR(255);

LET cCodRet 			 	='00000';	
LET iSqlErr 			 	=0;
LET cCodRetSp 			 	='';
LET iCodRetSp 			 	=0;
LET iNoRegistros		 	=0;
LET cTxnStatus           	='';
LET cChannelType         	='';
LET cChannelName         	='';
LET cChannelVersion      	='';
LET cForeignRsSystemIdRq 	='';
LET cForeignRsRefnumRq   	='';
LET cForeignRsCntidRq    	='';
LET cMtcn                	='';
LET cFechaHoraRq         	=NULL;
LET cRetcode             	='';
LET cEmisorNametype      	='';
LET cEmisorNombre1       	='';
LET cEmisorNombre2       	='';
LET cEmisorAppaterno     	='';
LET cEmisorApmaterno     	='';
LET cEmisorCiudad        	='';
LET cEmisorEdo           	='';
LET cEmisorCodPais       	='';
LET cEmisorCodMoneda     	='';
LET cEmisorCp            	='';
LET cEmisorCalle         	='';
LET cEmisorTelefono      	='';
LET cBenefNametype       	='';
LET cBenefNombre1        	='';
LET cBenefNombre2        	='';
LET cBenefAppaterno      	='';
LET cBenefApmaterno      	='';
LET cBenefCiudad         	='';
LET cBenefEdo            	='';
LET cBenefCodPais        	='';
LET cBenefCodMoneda      	='';
LET cBenefCp             	='';
LET cBenefCalle          	='';
LET cBenefTelPart        	='';
LET cBenefTelCelular     	='';
LET cMontoTotalOrigen    	='';
LET cMontoTotalDestino   	='';
LET cMontoOrigen         	='';
LET cMontoCargos         	='';
LET cCdOrigenPago        	='';
LET cTipoCambio          	='';
LET cFechaAltaRemesa     	='';
LET cHoraAltaRemesa      	='';
LET cMoneyTransferKey    	='';
LET cEstatusRemesa       	='';
LET cDescEstatusRemesa   	='';
LET cNewMtcn             	='';
LET cFusionStatus        	='';
LET cNoPaginas           	='';
LET cPaginaActual        	='';
LET cNumCoincidencias    	='';
LET cForeignRsSystemIdRp 	='';
LET cForeignRsRefnumRp   	='';
LET cForeignRsCntidRp    	='';
LET cDescError           	='';
LET cPartneridErr        	='';
LET cFechaHoraRp         	=NULL;
LET cUserInsert          	='';
LET cFechaInsert         	=NULL;
LET cIdSucursal          	='';
LET cFolioSuc            	='';
LET cFormaPago			 	='';
LET cRetcodeTraduccion	 	='';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cMtcn,cFechaHoraRq,cRetcode,cEmisorNametype,cEmisorNombre1,cEmisorNombre2,cEmisorAppaterno,cEmisorApmaterno,cEmisorCiudad,
			cEmisorEdo,cEmisorCodPais,cEmisorCodMoneda,cEmisorCp,cEmisorCalle,cEmisorTelefono,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,cBenefCodPais,cBenefCodMoneda,cBenefCp,cBenefCalle,
			cBenefTelPart,cBenefTelCelular,cMontoTotalOrigen,cMontoTotalDestino,cMontoOrigen,cMontoCargos,cCdOrigenPago,cTipoCambio,cFechaAltaRemesa,cHoraAltaRemesa,cMoneyTransferKey,cEstatusRemesa,cNewMtcn,cFusionStatus,cNoPaginas,cPaginaActual,
			cNumCoincidencias,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cIdSucursal,cFolioSuc,cFormaPago,cRetcodeTraduccion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasconsultawu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pMtcn=''  OR pNumeroConvenio ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cMtcn,cFechaHoraRq,cRetcode,cEmisorNametype,cEmisorNombre1,cEmisorNombre2,cEmisorAppaterno,cEmisorApmaterno,cEmisorCiudad,
			cEmisorEdo,cEmisorCodPais,cEmisorCodMoneda,cEmisorCp,cEmisorCalle,cEmisorTelefono,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,cBenefCodPais,cBenefCodMoneda,cBenefCp,cBenefCalle,
			cBenefTelPart,cBenefTelCelular,cMontoTotalOrigen,cMontoTotalDestino,cMontoOrigen,cMontoCargos,cCdOrigenPago,cTipoCambio,cFechaAltaRemesa,cHoraAltaRemesa,cMoneyTransferKey,cEstatusRemesa,cNewMtcn,cFusionStatus,cNoPaginas,cPaginaActual,
			cNumCoincidencias,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cIdSucursal,cFolioSuc, cFormaPago, cRetcodeTraduccion;
		END IF;
		
    	SET ISOLATION TO DIRTY READ;            
        SET LOCK MODE TO WAIT 3;

		SELECT  
		txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,
		emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_ciudad,
		benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,
		hora_alta_remesa,money_transfer_key,s.estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,foreign_rs_cntid_rp,desc_error,partnerid_err,
		fecha_hora_rp,s.user_insert,s.fecha_insert, e.descripcion_bcp
		INTO 
		cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cMtcn,cFechaHoraRq,cRetcode,cEmisorNametype,cEmisorNombre1,cEmisorNombre2,cEmisorAppaterno,cEmisorApmaterno,cEmisorCiudad,
		cEmisorEdo,cEmisorCodPais,cEmisorCodMoneda,cEmisorCp,cEmisorCalle,cEmisorTelefono,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,cBenefCodPais,cBenefCodMoneda,cBenefCp,cBenefCalle,
		cBenefTelPart,cBenefTelCelular,cMontoTotalOrigen,cMontoTotalDestino,cMontoOrigen,cMontoCargos,cCdOrigenPago,cTipoCambio,cFechaAltaRemesa,cHoraAltaRemesa,cMoneyTransferKey,cEstatusRemesa,cNewMtcn,cFusionStatus,cNoPaginas,cPaginaActual,
		cNumCoincidencias,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cDescEstatusRemesa
		FROM bdisac:sac_wu_search s LEFT JOIN bdisac:sac_wu_estatusrems e ON e.estatus_remesa = s.estatus_remesa
		WHERE retcode='00000' AND mtcn=pMtcn 
		AND fecha_insert=(SELECT MAX(fecha_insert) FROM bdisac:sac_wu_search 
                  WHERE  mtcn=pMtcn AND retcode='00000');
				  
						  
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cMtcn,cFechaHoraRq,cRetcode,cEmisorNametype,cEmisorNombre1,cEmisorNombre2,cEmisorAppaterno,cEmisorApmaterno,cEmisorCiudad,
			cEmisorEdo,cEmisorCodPais,cEmisorCodMoneda,cEmisorCp,cEmisorCalle,cEmisorTelefono,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,cBenefCodPais,cBenefCodMoneda,cBenefCp,cBenefCalle,
			cBenefTelPart,cBenefTelCelular,cMontoTotalOrigen,cMontoTotalDestino,cMontoOrigen,cMontoCargos,cCdOrigenPago,cTipoCambio,cFechaAltaRemesa,cHoraAltaRemesa,cMoneyTransferKey,cEstatusRemesa,cNewMtcn,cFusionStatus,cNoPaginas,cPaginaActual,
			cNumCoincidencias,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cIdSucursal,cFolioSuc, cFormaPago, cRetcodeTraduccion;
		END IF;
		
		--FECHAS INSERT = HOY
		  IF DATE(cFechaInsert) = (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN

				SELECT id_sucursal,folio_suc,forma_pago INTO  cIdSucursal,cFolioSuc,cFormaPago
				FROM bdisac:sac_movimientos WHERE
				numcategoria = '07'
				AND numconvenio=pNumeroConvenio
				AND referencia1 =pMtcn
				AND status_cancelado = 'N'
				AND flag_confirmacion_sucursal = '1'
				AND flag_confirmacion_central = '1'
				AND fecha_insert=(SELECT MAX(fecha_insert) FROM bdisac:sac_movimientos
								  WHERE
								  numcategoria = '07'
									AND numconvenio=pNumeroConvenio
									AND referencia1 =pMtcn
									AND status_cancelado = 'N'
									AND flag_confirmacion_sucursal = '1'
									AND flag_confirmacion_central = '1');
				
				IF NVL(cFolioSuc,'') <> '' THEN
					LET cDescEstatusRemesa = 'Pagada';
				END IF;
		--FECHAS INSERT < HOY 
		ELIF DATE(cFechaInsert) < (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN

		
				SELECT id_sucursal,folio_suc,forma_pago INTO  cIdSucursal,cFolioSuc,cFormaPago  
				FROM bdisac:sac_movimientoshistorial
				WHERE
				numcategoria = '07'
				AND numconvenio=pNumeroConvenio
				AND referencia1 =pMtcn
				AND status_cancelado = 'N'
				AND flag_confirmacion_sucursal = '1'
				AND flag_confirmacion_central = '1'
				AND rowid=(SELECT MAX(rowid) FROM bdisac:sac_movimientoshistorial
								  WHERE
								  numcategoria = '07'
									AND numconvenio=pNumeroConvenio
									AND referencia1 =pMtcn
									AND status_cancelado = 'N'
									AND flag_confirmacion_sucursal = '1'
									AND flag_confirmacion_central = '1');
				
				IF NVL(cFolioSuc,'') <> '' THEN
					LET cDescEstatusRemesa = 'Pagada';
				END IF;
				
				IF NVL(cFolioSuc,'') = '' THEN
							
					SELECT id_sucursal,folio_suc,forma_pago INTO  cIdSucursal,cFolioSuc,cFormaPago
					FROM bdisac:sac_movimientoshistorial_old
					WHERE
					numcategoria = '07'
					AND numconvenio=pNumeroConvenio
					AND referencia1 =pMtcn
					AND status_cancelado = 'N'
					AND flag_confirmacion_sucursal = '1'
					AND flag_confirmacion_central = '1'
					AND rowid=(SELECT MAX(rowid) FROM bdisac:sac_movimientoshistorial_old
									  WHERE
									  numcategoria = '07'
										AND numconvenio=pNumeroConvenio
										AND referencia1 =pMtcn
										AND status_cancelado = 'N'
										AND flag_confirmacion_sucursal = '1'
										AND flag_confirmacion_central = '1');
										
					IF NVL(cFolioSuc,'') <> '' THEN
						LET cDescEstatusRemesa = 'Pagada';
					END IF;

				END IF;
				
		--FECHA INSERT INVALIDA		
		 ELIF DATE(cFechaInsert) > (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
               LET cCodRet = '00975'; 
         END IF;
		 
		 RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cMtcn,cFechaHoraRq,cRetcode,cEmisorNametype,cEmisorNombre1,cEmisorNombre2,cEmisorAppaterno,cEmisorApmaterno,cEmisorCiudad,
			cEmisorEdo,cEmisorCodPais,cEmisorCodMoneda,cEmisorCp,cEmisorCalle,cEmisorTelefono,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,cBenefCodPais,cBenefCodMoneda,cBenefCp,cBenefCalle,
			cBenefTelPart,cBenefTelCelular,cMontoTotalOrigen,cMontoTotalDestino,cMontoOrigen,cMontoCargos,cCdOrigenPago,cTipoCambio,cFechaAltaRemesa,cHoraAltaRemesa,cMoneyTransferKey,cDescEstatusRemesa,cNewMtcn,cFusionStatus,cNoPaginas,cPaginaActual,
			cNumCoincidencias,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cIdSucursal,cFolioSuc,cFormaPago,cRetcodeTraduccion;
		 
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 08/05/2017',
'MODULO: REMESAS ',
'FUNCIONALIDAD: Consulta Remesas WU',
'DESCRIPCION:SPL que consulta los datos de remesa WU',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actualizatipoconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pConcentracion CHAR(10), pTrama CHAR(250))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);	
	DEFINE cEstatus CHAR(1);
	DEFINE cConcentracion CHAR(10);
	DEFINE iRowId INTEGER;
	DEFINE cNo_sucursal_atm CHAR(4);
	DEFINE cNombre_sucursal_atm CHAR(40);
	DEFINE cNoSucursal CHAR(4);
	DEFINE cNoAtm CHAR(6);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';	
	LET cEstatus = '';
	LET cConcentracion = '';
	LET iRowId = 0;
	LET cNo_sucursal_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cNoSucursal = '';
	LET cNoAtm = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_actualizatipoconcentracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion = '' OR pTrama = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 30;
		
		-- ALTA
		IF pEjecucion = '1' THEN
		
			IF pConcentracion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
			
			IF TRIM(pConcentracion) = 'U' THEN
				LET cConcentracion = 'URBANA';
			ELIF TRIM(pConcentracion) = 'F' THEN
				LET cConcentracion = 'FORANEA';
			END IF;
		
			FOREACH
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(TRIM(pTrama), '|')
				INTO iRowId
				
				SELECT no_sucursal_atm, TRIM(UPPER(nombre_sucursal_atm))
				INTO cNo_sucursal_atm, cNombre_sucursal_atm
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE ROWID = iRowId;
				
				--Atm
				IF LEFT(TRIM(UPPER(cNo_sucursal_atm)),1) = 'P' THEN
					LET cNoSucursal = '';
					LET cNoAtm = cNo_sucursal_atm;
					LET cEstatus = 'C';
				--Sucursal
				ELSE
					LET cNoSucursal = cNo_sucursal_atm;
					LET cNoAtm = '';
					LET cEstatus = 'S';
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				UPDATE bdisuc:"informix".ss_tipo_concentracion_etv
				SET tipo_concentracion = TRIM(pConcentracion), estatus = cEstatus
				WHERE ROWID = iRowId;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cCodRet = '00283'; 	
					RETURN cCodRet;
				END IF;
				
				INSERT INTO bdisuc:"informix".ss_bitacora_tipo_concentracion(empresa,fecha,hora,tipo_mantenimiento,usuario,no_sucursal,no_atm,nombre_sucursal_atm,tipo_concentracion_asignado)
				VALUES(cEmpresa,CURRENT,CURRENT,'ALTA',pUsuario,cNoSucursal,cNoAtm,TRIM(cNombre_sucursal_atm),cConcentracion);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cCodRet = '00282'; 	
					RETURN cCodRet;
				END IF;
				
			END FOREACH;
		
		-- BAJA
		ELIF pEjecucion = '2' THEN
		
			FOREACH 
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(TRIM(pTrama), '|')
				INTO iRowId
				
				SELECT no_sucursal_atm, TRIM(UPPER(nombre_sucursal_atm))
				INTO cNo_sucursal_atm, cNombre_sucursal_atm
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE ROWID = iRowId;
				
				--Sucursal
				IF cNo_sucursal_atm <> '' THEN
					LET cNoSucursal = cNo_sucursal_atm;
					LET cNoAtm = '';
				--Atm
				ELSE
					LET cNoSucursal = '';
					LET cNoAtm = cNo_sucursal_atm;
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				UPDATE bdisuc:"informix".ss_tipo_concentracion_etv
				SET estatus = 'N'
				WHERE ROWID = iRowId;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cCodRet = '00283'; 	
					RETURN cCodRet;
				END IF;
				
				INSERT INTO bdisuc:"informix".ss_bitacora_tipo_concentracion(empresa,fecha,hora,tipo_mantenimiento,usuario,no_sucursal,no_atm,nombre_sucursal_atm,tipo_concentracion_asignado)
				VALUES(cEmpresa,CURRENT,CURRENT,'BAJA',pUsuario,cNoSucursal,cNoAtm,TRIM(cNombre_sucursal_atm),'');
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cCodRet = '00282'; 	
					RETURN cCodRet;
				END IF;
				
			END FOREACH;
			
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de actualizar el tipo de concentración de los registros seleccionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_altaccetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcionEtv CHAR(40), pCodProveedor CHAR(4), pCentroCostosEtv CHAR(4))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcionCC CHAR(30);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iRecuperacion = 0;
	LET cDescripcionCC = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_altaccetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionEtv = ''OR pCodProveedor = '' OR pCentroCostosEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE OBTIENE DESCRIPCION CENTRO DE COSTOS
		SELECT descripcion
		INTO cDescripcionCC
		FROM bdisuc:"informix".ss_proveedores
		WHERE cod_proveedor = pCodProveedor;
		
		IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_relacion_cc_etvs WHERE TRIM(UPPER(caja_general)) = TRIM(UPPER(cDescripcionCC)) AND cc_etv = pCentroCostosEtv AND etv = pDescripcionEtv ) THEN
			LET cCodRet = '01056'; -- EL ETV Y CENTRO DE COSTOS QUE DESEA ASIGNAR A LA CAJA GENERAL YA EXISTE. VERIFIQUE.
			RETURN cCodRet;
		ELSE						
			INSERT INTO bdisuc:"informix".ss_relacion_cc_etvs(caja_general, cc_etv, etv, cc_banco, estatus) 
			VALUES(UPPER(cDescripcionCC),pCentroCostosEtv,UPPER(pDescripcionEtv),'', 'ACTIVO'); 
			
			IF DBINFO('sqlca.sqlerrd2') =  0 THEN
				LET cCodRet = '00282'; -- ERROR AL GUARDAR EL REGISTRO
				RETURN cCodRet;
			ELSE			
				RETURN cCodRet;
			END IF;			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE ETV',
'DESCRIPCION: SPL encargado de insertar un registro a la tabla ss_relacion_cc_etvs.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_altaetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcionEtv CHAR(40))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iRecuperacion = 0;
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_altaetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_catalago_etv WHERE TRIM(UPPER(nombre_etv)) = TRIM(UPPER(pDescripcionEtv)) ) THEN
			LET cCodRet = '01055'; --EL NOMBRE DE ETV QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE.
			RETURN cCodRet;
		ELSE				
			
			INSERT INTO bdisuc:"informix".ss_catalago_etv(empresa, nombre_etv, activa) 
			VALUES(cEmpresa,UPPER(pDescripcionEtv),'S');
			
			IF DBINFO('sqlca.sqlerrd2') =  0 THEN
				LET cCodRet = '00282'; -- ERROR AL GUARDAR EL REGISTRO
				RETURN cCodRet;
			ELSE
				
				--SE REGISTRA EN BITÃCORA
				INSERT INTO bdisuc:"informix".ss_bitacora_mant_etv(empresa,fecha,hora,tipo_mantenimiento,no_empleado,id_etv) 
				VALUES(cEmpresa,CURRENT,CURRENT,'ALTA',pUsuario,(SELECT MAX(rowid) FROM bdisuc:"informix".ss_catalago_etv));
				
				IF DBINFO('sqlca.sqlerrd2') =  0 THEN
					LET cCodRet = '00282'; -- ERROR AL GUARDAR EL REGISTRO
					RETURN cCodRet;
				ELSE
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: SPL encargado de insertar un registro al catÃ¡logo de ETV.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 06/07/2018',
'DESCRIPCION: Se modifica spl para registrar la alta de etv en la tabla bdisuc:ss_bitacora_mant_etv.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 31/07/2018',
'DESCRIPCION: Se modifica spl para agregar columna id_etv en la insercion de registro en la tabla ss_bitacora_mant_etv.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_bajaccetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pBajaCcEtv CHAR(250))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValor CHAR(40);
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValor = '';
	LET iNoRegsProcesados = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_bajaccetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pBajaCcEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pBajaCcEtv, '|')
					INTO cCadenaValor					
										
					SET LOCK MODE TO WAIT 3;
					UPDATE bdisuc:"informix".ss_relacion_cc_etvs
					SET estatus = 'INACTIVO'
					WHERE rowid = TRIM(cCadenaValor);
										
					LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: Actualiza los registros del de la tabla bdisuc:"informix".ss_relacion_cc_etvs a inactivos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_bajaetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pEtvBaja CHAR(250))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValor CHAR(40);
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValor = '';
	LET iNoRegsProcesados = 0;
	LET bInTransaction = 'f';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_bajaetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pEtvBaja = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pEtvBaja, '|')
					INTO cCadenaValor	
						
						LET cCadenaValor = TRIM(cCadenaValor);
										
					SET LOCK MODE TO WAIT 3;
					UPDATE bdisuc:"informix".ss_catalago_etv
					SET activa = 'N'
					WHERE rowid = cCadenaValor;
										
					LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
										
					--SE REGISTRA EN BITÁCORA
					INSERT INTO bdisuc:"informix".ss_bitacora_mant_etv(empresa,fecha,hora,tipo_mantenimiento,no_empleado,id_etv) 
					VALUES(cEmpresa,CURRENT,CURRENT,'BAJA',pUsuario,cCadenaValor);

					IF DBINFO('sqlca.sqlerrd2') =  0 THEN
						LET cCodRet = '00282'; -- ERROR AL GUARDAR EL REGISTRO
						RETURN cCodRet, iNoRegsProcesados;
					END IF;
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: SPL que actualiza los registros del catalogo de ETV',
'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018',
'DESCRIPCION: Se modifica spl para registrar la baja de etv en la tabla bdisuc:ss_bitacora_mant_etv.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 31/07/2018',
'DESCRIPCION: Se modifica spl para agregar columna id_etv en la insercion de registro en la tabla ss_bitacora_mant_etv.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_bitacoraerroreslibro1(pUsuario CHAR(8), pIdFuncion CHAR(10),pTramaErrores CHAR(250), pSucursal CHAR(4), pTramaEnviada CHAR(600))
		RETURNING CHAR(5) AS codRet;
   
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cCodError CHAR(3);
   DEFINE cDescError CHAR(100);    
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cCodError = '';
   LET cDescError = '';    
   
   BEGIN

	  ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
	  		RETURN cCodRet;
	  	END IF;
	  END EXCEPTION;
		
	  --SET DEBUG FILE TO '/tmp/mfinis/sp_cg_bitacoraerroreslibro1.out';
	  --TRACE ON;
		
	  IF pUsuario = '' OR pIdFuncion = '' OR pTramaErrores = '' THEN
		LET cCodRet = '00003';			
		RETURN cCodRet;
	  END IF;
		
	  EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	  IF cCodRet <> '00000' THEN
	  	RETURN cCodRet;
	  END IF;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  FOREACH
		EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaErrores, '|')
			INTO cCodError
		
		SELECT desc_cod_error 
			INTO cDescError
		FROM bdicnweb:"informix".sw_cat_errores_panamericano 
		WHERE cod_error = cCodError;					

		INSERT INTO bdisuc:"informix".ss_bitacora_envio_libro (empresa,codigo_ws,descripcion_codigo_ws,sucursal,cadena_ent,user_insert,fecha_hora_insert)
		VALUES('001',cCodError,cDescError,pSucursal,pTramaEnviada,pUsuario,CURRENT);
	  
	  END FOREACH;
	  
	  RETURN cCodRet;
   END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL que guarda los códigos de respuesta recibidos de la ejecución del ws de panamericano',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_bitacoraerrorespanamericano(pUsuario CHAR(8), pIdFuncion CHAR(10),pTramaErrores CHAR(250), pMetodoServicio CHAR(40))
		RETURNING CHAR(5) AS codRet;
   
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cCodError CHAR(3);
   DEFINE cDescError CHAR(100);
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cCodError = '';
   LET cDescError = '';
   
   BEGIN

	  ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
	  		RETURN cCodRet;
	  	END IF;
	  END EXCEPTION;
		
	  --SET DEBUG FILE TO '/tmp/mfinis/sp_cg_bitacoraerrorespanamericano.out';
	  --TRACE ON;
		
	  IF pUsuario = '' OR pIdFuncion = '' OR pTramaErrores = '' OR pMetodoServicio = '' THEN
		LET cCodRet = '00003';			
		RETURN cCodRet;
	  END IF;
		
	  EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	  IF cCodRet <> '00000' THEN
	  	RETURN cCodRet;
	  END IF;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  FOREACH
		  EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaErrores, '|')INTO cCodError
		  
		  SELECT desc_cod_error INTO cDescError
		  FROM bdicnweb:"informix".sw_cat_errores_panamericano 
		  WHERE cod_error = cCodError;
		  
		  INSERT INTO bdicnweb:"informix".sw_cg_bitacoraerrorwspanamericano (cod_error,descripcion,metodo,usuario_insert,fecha_insert,hora_insert)
		  VALUES(cCodError,cDescError,pMetodoServicio,pUsuario,CURRENT,TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%H:%M:%S'));
	  
	  END FOREACH;
	  
	  RETURN cCodRet;
   END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL que bitacorea errores recibidos de la ejecución del ws de panamericano',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_cat_atmsuc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(5) AS no_atm_suc,
		CHAR(100) AS desc_atm_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;	
	DEFINE cEmpresa CHAR(3);
	DEFINE cNoAtmSuc CHAR(5);
	DEFINE cDescAtmSuc CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNoAtmSuc = '';
	LET cDescAtmSuc = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_cat_atmsuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH				
			SELECT id, descripcion
			INTO cNoAtmSuc, cDescAtmSuc
			FROM bdicnweb:"informix".sw_cat_atm_sucursal 
			WHERE status = '1'			
			ORDER BY 1 ASC
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNoAtmSuc, TRIM(UPPER(cDescAtmSuc)) WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		ELIF iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Uriel CaamaÃ±o Mejia',
'FECHA: 21/06/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle del catÃ¡logo atm o sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_catatmsuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pCg CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(10) AS no_atm_suc,
		CHAR(40) AS desc_atm_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNoAtmSuc CHAR(10);
	DEFINE cDescAtmSuc CHAR(40);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNoAtmSuc = '';
	LET cDescAtmSuc = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_catatmsuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET pCg = TRIM(pCg);
		-- ALTA
		IF pEjecucion = '1' THEN
			IF pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion no_sucursal_atm, nombre_sucursal_atm
					INTO cNoAtmSuc, cDescAtmSuc
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N'
					AND centro_costos = centro_costos
					ORDER BY 2 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNoAtmSuc, TRIM(UPPER(cDescAtmSuc)) WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion no_sucursal_atm, nombre_sucursal_atm
					INTO cNoAtmSuc, cDescAtmSuc
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N'
					AND centro_costos = pCg
					ORDER BY 2 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNoAtmSuc, TRIM(UPPER(cDescAtmSuc)) WITH RESUME;
				END FOREACH;
			END IF;
		-- BAJA
		ELIF pEjecucion = '2' THEN
			IF pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion no_sucursal_atm, nombre_sucursal_atm
					INTO cNoAtmSuc, cDescAtmSuc
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus IN ('C','S')
					AND centro_costos = centro_costos
					ORDER BY 2 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNoAtmSuc, TRIM(UPPER(cDescAtmSuc)) WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion no_sucursal_atm, nombre_sucursal_atm
					INTO cNoAtmSuc, cDescAtmSuc
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus IN ('C','S')
					AND centro_costos = pCg
					ORDER BY 2 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNoAtmSuc, TRIM(UPPER(cDescAtmSuc)) WITH RESUME;
				END FOREACH;
			END IF;		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNoAtmSuc, cDescAtmSuc;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo atm o sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_cattipoconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(10) AS tipo_concentracion,
		CHAR(40) AS desc_concentracion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipo CHAR(10);
	DEFINE cDescripcion CHAR(40);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cTipo = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cTipo, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_cattipoconcentracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipo, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cTipo, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion tipo, descripcion
			INTO cTipo, cDescripcion
			FROM bdicnweb:"informix".sw_cg_tipoconcentracion_etv
			ORDER BY 2 ASC
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, TRIM(UPPER(cTipo)), TRIM(UPPER(cDescripcion)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTipo, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTipo, cDescripcion;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo tipo de concentración.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consfuncionalidadesmttoetv(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS id_catalogo,
		CHAR(100) AS desc_funcion;
	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdCatalogo INTEGER;
	DEFINE cDescFuncion CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdCatalogo = 0;
	LET cDescFuncion = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdCatalogo, cDescFuncion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consfuncionalidadesmttoetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCatalogo, cDescFuncion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCatalogo, cDescFuncion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT id_catalogo, desc_funcion
			INTO iIdCatalogo, cDescFuncion
			FROM bdicnweb:"informix".sw_cg_catalogomantenimientoetv
			ORDER BY desc_funcion ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdCatalogo, cDescFuncion WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017'; -- NO SE ENCONTRARON RESULTADOS
			RETURN cCodRet, iIdCatalogo, cDescFuncion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 15/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: SPL encargado de consultar las opciones que llenan el catalogo de Mantenimiento ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consfuncionalidadesoperacionesmttocat(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdCatalogo INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS id_catalogo,
		CHAR(10) AS id_funcion,
		CHAR(100) AS desc_funcion,
		INTEGER AS id_submodulo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdCatalogo INTEGER;
	DEFINE cIdFuncion CHAR(10);
	DEFINE cDescFuncion CHAR(100);
	DEFINE iIdSubmodulo INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdCatalogo = 0;
	LET cIdFuncion = '';
	LET cDescFuncion = '';
	LET iIdSubmodulo = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consfuncionalidadesoperacionesmttocat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT a.id_operacion, a.id_funcion, a.desc_funcion, b.id_submodulo
			INTO iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo
			FROM bdicnweb:"informix".sw_cg_operacionesmantenimientoetv AS a
			INNER JOIN bdinteg:"informix".si_seg_funciones AS b ON a.id_funcion = b.id_funcion
			WHERE a.id_funcion IN (SELECT a.id_funcion
								   FROM bdinteg:"informix".si_seg_usuarios_funciones a, bdinteg:"informix".si_seg_funciones b
								   WHERE id_usuario = pUsuario
								   AND a.id_funcion[1, 3] =  'CGR'
								   AND a.status = '1'
								   AND b.id_funcion = a.id_funcion
								   AND b.id_submodulo = 28)
			AND a.id_catalogo = pIdCatalogo
			ORDER BY a.id_operacion ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00749'; --EL USUARIO NO TIENE NINGÃN CATÃLOGO ASIGNADO
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: SPL encargado de consultar las opciones que llenan las operaciones de Mantenimiento ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_conslistasolicitudesconcentracion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdBanco CHAR(2), pFechaDel DATE,  pFechaAl DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_conslistasolicitudesconcentracion_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pIdBanco = '' OR pFechaDel IS NULL OR pFechaAl IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
				
		SELECT  {+INDEX(bdisuc:"informix".ss_mae_entradasalida  idx01ss_mae_entradasalida)} COUNT(*)
			INTO iNoRegistros
		FROM bdisuc:"informix".ss_mae_entradasalida a
		INNER JOIN bdisuc:"informix".ss_operaciones d ON a.folio_oper = d.folio_oper 
                AND d.cod_trans = '0002' 
				AND d.id_solicitud <> ''
					
		INNER JOIN bdinteg:"informix".si_sucursales b ON a.empresa = b.empresa
			AND a.sucursal = b.sucursal
		LEFT JOIN bdisuc:"informix".ss_sucursales_panamericano c ON a.cod_proveedor = c.centro_costos 		 						
		WHERE a.fecha_solicitud BETWEEN pFechaDel AND pFechaAl
			AND a.monto > 0;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '01058';
			RETURN cCodRet, iNoRegistros;
		ELSE 
			RETURN cCodRet, iNoRegistros;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP que consulta el total de Acuses Libro 1 del Monitor de Efectivo en Línea Bancoppel',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA: 07/06/2018',
'DESCRIPCION: Se agrega parametro de fechas para consultar por periodos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacajagenetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS cod_provedor,
		CHAR(60) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodProvedor CHAR(4);
	DEFINE cDescripcion CHAR(60);		
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCodProvedor = '';
	LET cDescripcion = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCodProvedor,cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacajagenetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodProvedor,cDescripcion;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCodProvedor,cDescripcion;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodProvedor,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_cajagen_etv2(pRegistros,pRecuperacion)
			INTO cCodRetSp,cCodProvedor, cDescripcion
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_consulta_cajagen_etv2';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,cCodProvedor, TRIM(UPPER(cDescripcion)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet,cCodProvedor, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCodProvedor,cDescripcion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar la caja general de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacatalogoetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstatus CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_etv,
		CHAR(1) AS activa,
		INTEGER AS id_row;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreEtv CHAR(40);	
	DEFINE cActiva CHAR(1);
	DEFINE iRecuperacion INTEGER;
	DEFINE iIdRow INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreEtv = '';
	LET cActiva = '';
	LET iRecuperacion = 0;
	LET iIdRow = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacatalogoetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEstatus = ''  OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
		END IF;
		
		IF pEstatus NOT IN ('S', 'N', 'T' ) THEN
			LET cCodRet = '00275'; -- ESTATUS INVALIDO PARA REALIZAR LA CONSULTA
			RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEstatus = 'S' THEN  --- ETV'S ACTIVAS
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion nombre_etv, activa, rowid
				INTO cNombreEtv, cActiva, iIdRow
				FROM bdisuc:ss_catalago_etv
				WHERE activa = 'S'
				ORDER BY nombre_etv ASC
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet, TRIM(UPPER(cNombreEtv)), TRIM(UPPER(cActiva)), iIdRow WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01054'; -- EL CATÁLOGO DE ETV NO CUENTA CON INFORMACIÓN
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			END IF;
			
		ELIF pEstatus = 'N' THEN --- ETV'S INACTIVAS
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion nombre_etv, activa, rowid
				INTO cNombreEtv, cActiva, iIdRow
				FROM bdisuc:ss_catalago_etv
				WHERE activa = 'N'
				ORDER BY nombre_etv ASC
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet, TRIM(UPPER(cNombreEtv)), TRIM(UPPER(cActiva)), iIdRow WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01054'; -- EL CATÁLOGO DE ETV NO CUENTA CON INFORMACIÓN
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			END IF;
		ELIF pEstatus = 'T' THEN --- ETV'S ACTIVAS E INACTIVAS
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion nombre_etv, activa, rowid
				INTO cNombreEtv, cActiva,iIdRow
				FROM bdisuc:ss_catalago_etv
				WHERE activa IN ('S','N')
				ORDER BY nombre_etv ASC
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet, TRIM(UPPER(cNombreEtv)), TRIM(UPPER(cActiva)), iIdRow WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01054'; -- EL CATÁLOGO DE ETV NO CUENTA CON INFORMACIÓN
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreEtv,cActiva,iIdRow;
			END IF;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMINETO ETV Y MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el catalogo de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaccetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcionEtv CHAR(40), pCodProveedor CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		INTEGER AS id_row,
		CHAR(30) AS caja_general,
		CHAR(4) AS cc_etv,
		CHAR(30) AS etv,
		CHAR(8) AS estatus;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRowId INTEGER;
	DEFINE cCajaGeneral CHAR(30);	
	DEFINE cCcEtv CHAR(4);
	DEFINE cEtv CHAR(30);
	DEFINE cEstatus CHAR(8);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRowId = 0;
	LET cCajaGeneral = '';
	LET cCcEtv = '';
	LET cEtv = '';
	LET cEstatus = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaccetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionEtv = '' OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
		END IF;
		
		-- VALIDACIÃ?N DE LOS DATOS DE PAGINACIÃ?N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pDescripcionEtv = UPPER(pDescripcionEtv); 
		
		IF pCodProveedor = '' THEN 
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion rowid, caja_general, cc_etv, etv, estatus 
				INTO iRowId, cCajaGeneral, cCcEtv, cEtv, cEstatus
				FROM bdisuc:"informix".ss_relacion_cc_etvs
				WHERE caja_general IN (	SELECT UPPER(descripcion) 
										FROM bdisuc:"informix".ss_proveedores
										WHERE cod_proveedor =  cod_proveedor )
				AND etv = pDescripcionEtv
				AND estatus = 'ACTIVO'
				ORDER BY caja_general ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iRowId, TRIM(cCajaGeneral), cCcEtv, TRIM(cEtv), cEstatus WITH RESUME;	
			END FOREACH;
		ELSE 
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion rowid, caja_general, cc_etv, etv, estatus 
				INTO iRowId, cCajaGeneral, cCcEtv, cEtv, cEstatus
				FROM bdisuc:"informix".ss_relacion_cc_etvs
				WHERE caja_general IN (	SELECT UPPER(descripcion) 
										FROM bdisuc:"informix".ss_proveedores
										WHERE cod_proveedor =  pCodProveedor )
				AND etv = pDescripcionEtv
				AND estatus = 'ACTIVO'
				ORDER BY caja_general ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iRowId, TRIM(cCajaGeneral), cCcEtv, TRIM(cEtv), cEstatus WITH RESUME;	
			END FOREACH;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,iRowId,cCajaGeneral,cCcEtv,cEtv,cEstatus;
		END IF;			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar la tabla ss_relacion_cc_etvs.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaccetv_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcionEtv CHAR(40), pCodProveedor CHAR(4))
    RETURNING CHAR(5) AS codRet,
		INTEGER AS total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotalRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iTotalRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaccetv_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET pDescripcionEtv = UPPER(pDescripcionEtv);

		IF pCodProveedor = '' THEN
			SELECT COUNT(*) 
			INTO iTotalRegistros
			FROM bdisuc:"informix".ss_relacion_cc_etvs
			WHERE caja_general IN (	SELECT UPPER(descripcion) 
									FROM bdisuc:"informix".ss_proveedores
									WHERE cod_proveedor = cod_proveedor)
			AND etv = pDescripcionEtv
			AND estatus = 'ACTIVO';
		ELSE
			SELECT COUNT(*) 
			INTO iTotalRegistros
			FROM bdisuc:"informix".ss_relacion_cc_etvs
			WHERE caja_general IN (	SELECT UPPER(descripcion) 
									FROM bdisuc:"informix".ss_proveedores
									WHERE cod_proveedor = pCodProveedor)
			AND etv = pDescripcionEtv
			AND estatus = 'ACTIVO';
		END IF;			
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,iTotalRegistros;
		END IF;
			
		RETURN cCodRet,iTotalRegistros;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el total de registros de la tabla ss_relacion_cc_etvs.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadotacionesrecoleccionesetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoServicio CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(25) AS id_servicio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdServicio CHAR(25);	
	DEFINE iRecuperacion INTEGER;
	DEFINE iTipoServicio INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cIdServicio = '';
	LET iRecuperacion = 0;
	LET iTipoServicio = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cIdServicio;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadotacionesrecoleccionesetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoServicio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdServicio;
		END IF;
		
		-- VALIDACIÃ?N DE LOS DATOS DE PAGINACIÃ?N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cIdServicio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdServicio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pTipoServicio = TRIM(pTipoServicio);
		
		IF (pTipoServicio = 'CONCENTRACIONES') THEN
			LET iTipoServicio = 1;
		ELIF pTipoServicio = 'DOTACIONES' THEN
			LET iTipoServicio = 2;
		END IF;
			
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion 	valor.id_servicio 
															INTO cIdServicio
				FROM 
				
				(SELECT id_servicio FROM  bdisuc:'informix'.ss_servicios_sucursales 
				WHERE tipo_servicio = iTipoServicio	--CASE WHEN pTipoServicio = 'CONCENTRACIONES' THEN 1 WHEN pTipoServicio = 'DOTACIONES' THEN 2 END 
				UNION ALL
				SELECT id_servicio FROM bdisuc:'informix'.ss_servicios_atms 
				WHERE tipo_servicio = iTipoServicio )	--CASE WHEN pTipoServicio = 'CONCENTRACIONES' THEN 1 WHEN pTipoServicio = 'DOTACIONES' THEN 2 END)									
				AS valor ORDER BY valor.id_servicio
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet,TRIM(cIdServicio) WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00981'; 
				RETURN cCodRet,cIdServicio;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cIdServicio;
			END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMINETO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar registros de concentraciones y dotaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultadotacionesrecoleccionesetv_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoServicio CHAR(30))
    RETURNING CHAR(5) AS codRet,
		INTEGER AS total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotalRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iTotalRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadotacionesrecoleccionesetv_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoServicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iTotalRegistros
		FROM (SELECT id_servicio FROM  bdisuc:'informix'.ss_servicios_sucursales WHERE tipo_servicio = CASE WHEN TRIM(pTipoServicio) = 'CONCENTRACIONES' THEN 1 WHEN TRIM(pTipoServicio) = 'DOTACIONES' THEN 2 END 
		UNION ALL 
		SELECT id_servicio FROM bdisuc:'informix'.ss_servicios_atms WHERE tipo_servicio = CASE WHEN TRIM(pTipoServicio) = 'CONCENTRACIONES' THEN 1 WHEN TRIM(pTipoServicio) = 'DOTACIONES' THEN 2 END)
		AS valor;
	
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00981'; 
			RETURN cCodRet,iTotalRegistros;
		END IF;
			
		RETURN cCodRet,iTotalRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 22/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMINETO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el total de registros de concentraciones y dotaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultainfocomprobantetv(pUsuario CHAR(8), pIdFuncion CHAR(10),pFolioComprobante CHAR(16),pFechaConsulta CHAR(10), pTipoValidacion CHAR(1))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cFechaSol    CHAR(10);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cFechaSol = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultainfocomprobantetv.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFolioComprobante = '' OR pTipoValidacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;			
		
		IF pTipoValidacion = 1 THEN 

			SELECT COUNT(*)
				INTO iNoRegistros
			FROM bdisuc:"informix".ss_mae_entradasalida
			WHERE folio_servicio = pFolioComprobante;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '01059';
				RETURN cCodRet, iNoRegistros;
			ELSE 
				RETURN cCodRet, iNoRegistros;
			END IF;

		ELIF pTipoValidacion = 2 THEN
			
			IF  pFechaConsulta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
							
			SELECT fecha_envio
				INTO cFechaSol
			FROM bdisuc:"informix".ss_mae_entradasalida
			WHERE folio_servicio = pFolioComprobante;
			
			IF DATE(cFechaSol) = DATE(pFechaConsulta) THEN
				LET iNoRegistros = 1;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '01060';
				RETURN cCodRet, iNoRegistros;
			ELSE 
				RETURN cCodRet, iNoRegistros;
			END IF;

		END IF;
		
		

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL que consulta que exista el folio y la fecha ingresada en Información por Comprobante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultamelbconcentraciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta CHAR(10), pTipOperacion CHAR(5), 
		pSucursal CHAR(8), pDireccionMac CHAR(12))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultamelbconcentraciones_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaConsulta = '' OR pTipOperacion = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		
		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;			
		
		 IF pTipOperacion = 'TODAS' THEN
			SELECT COUNT(*)
				INTO iNoRegistros
			FROM bdisuc:"informix".ss_recibe_datosconcentracionws
			WHERE fecha_aplicacion = pFechaConsulta			
			AND usuario = pUsuario
			AND direccion_mac = pDireccionMac;
		 				
		ELSE 		
			IF  pSucursal = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
			
			SELECT COUNT(*)
				INTO iNoRegistros
			FROM bdisuc:"informix".ss_recibe_datosconcentracionws
			WHERE fecha_aplicacion = pFechaConsulta
			AND tipo_domicilio = pTipOperacion			
			AND sucursal_banco = pSucursal
			AND usuario = pUsuario
			AND direccion_mac = pDireccionMac;
		
		END IF; 
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		ELSE 
			RETURN cCodRet, iNoRegistros;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL que consulta el total de Concentraciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultamelbdetalleope(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSolicitud CHAR(25), pFechaSolicitud DATE)
		RETURNING CHAR(5) AS codret,
			CHAR(10) AS fecha_operacion, 
			MONEY(18,2) AS monto_entradasalida, 
			CHAR(30) AS desc_proveedor,
			CHAR(4) AS sucursal,
			CHAR(16) AS folio_servicio,
			CHAR(30) AS desc_status,
			CHAR(8) AS usuario_ope,
			INTEGER AS cantidad_1,
			INTEGER AS cantidad_2,
			INTEGER AS cantidad_3,
			INTEGER AS cantidad_4,
			INTEGER AS cantidad_5,
			INTEGER AS cantidad_6,
			INTEGER AS cantidad_7,
			MONEY(18,2) AS monto_oper,  
			CHAR(8) AS folio_oper,
			CHAR(30) AS desc_divisa,
			CHAR(10) AS fecha_solicitud,
			CHAR(5) AS hora_solicitud,
			CHAR(8) AS usuario_solicitud,
			CHAR(10) AS fecha_envio,
			CHAR(5) AS hora_envio,
			CHAR(8) AS usuario_envio,
			CHAR(10) AS fecha_recepcion,
			CHAR(5) AS hora_recepcion,
			CHAR(8) AS usuario_recepcion,				  
			MONEY(12,2) AS can_total_1,
			MONEY(12,2) AS can_total_2,
			MONEY(12,2) AS can_total_3,
			MONEY(12,2) AS can_total_4,
			MONEY(12,2) AS can_total_5,
			MONEY(12,2) AS can_total_6;				
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cFechaOperacion CHAR(10);
	DEFINE mMontoEntradaSalida MONEY(18,2); 
	DEFINE cDescProveedor CHAR(30);
	DEFINE cSucursal CHAR(4);
	DEFINE cFolioServicio CHAR(16);
	DEFINE cDescStatus CHAR(30);
	DEFINE cUsuarioOpe CHAR(8); 
	DEFINE dCantidad1 INTEGER;
	DEFINE dCantidad2 INTEGER;
	DEFINE dCantidad3 INTEGER;
	DEFINE dCantidad4 INTEGER;
	DEFINE dCantidad5 INTEGER;
	DEFINE dCantidad6 INTEGER;
	DEFINE dCantidad7 INTEGER;
	DEFINE mMontoOper MONEY(18,2); 
	DEFINE cFolioOper CHAR(8);
	DEFINE cDescDivisa CHAR(30);
	DEFINE cFechaSolicitud CHAR(10);
	DEFINE cHoraSolicitud CHAR(5);
	DEFINE cUsuarioSolicitud CHAR(8);
	DEFINE cFechaEnvio CHAR(10);
	DEFINE cHoraEnvio CHAR(5);
	DEFINE cUsuarioEnvio CHAR(8);
	DEFINE cFechaRecepcion CHAR(10);
	DEFINE cHoraRecepcion CHAR(5);
	DEFINE cUsuarioRecepcion CHAR(8);
	DEFINE mCanTotal1 MONEY(12,2);
	DEFINE mCanTotal2 MONEY(12,2);
	DEFINE mCanTotal3 MONEY(12,2);
	DEFINE mCanTotal4 MONEY(12,2);
	DEFINE mCanTotal5 MONEY(12,2);
	DEFINE mCanTotal6 MONEY(12,2);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cFechaOperacion = '';
	LET mMontoEntradaSalida = 0;
	LET cDescProveedor = '';
	LET cSucursal = '';
	LET cFolioServicio = '';
	LET cDescStatus = '';
	LET cUsuarioOpe = '';
	LET dCantidad1 = 0;
	LET dCantidad2 = 0;
	LET dCantidad3 = 0;
	LET dCantidad4 = 0;
	LET dCantidad5 = 0;
	LET dCantidad6 = 0;
	LET dCantidad7 = 0;
	LET mMontoOper = 0;
	LET cFolioOper = '';
	LET cDescDivisa = '';
	LET cFechaSolicitud = '';
	LET cHoraSolicitud = '';
	LET cUsuarioSolicitud = '';
	LET cFechaEnvio = '';
	LET cHoraEnvio = '';
	LET cUsuarioEnvio = '';
	LET cFechaRecepcion = '';
	LET cHoraRecepcion = '';
	LET cUsuarioRecepcion = '';
	LET mCanTotal1 = 0;
	LET mCanTotal2 = 0;
	LET mCanTotal3 = 0;
	LET mCanTotal4 = 0;
	LET mCanTotal5 = 0;
	LET mCanTotal6 = 0;
		
		
		
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
				dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
				cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
				mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultamelbdetalleope.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pIdSolicitud = '' OR pFechaSolicitud IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
				dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
				cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
				mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
				dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
				cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
				mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6;
		END IF;			
		
			SELECT a.fecha_operacion, b.monto, c.descripcion,b.sucursal,b.folio_servicio,d.descripcion,a.usuario, a.cantidad_1,a.cantidad_2,
				a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.monto,b.folio_oper,e.descripcion,b.fecha_solicitud,b.hora_solicitud,
				b.usuario_solicitud,b.fecha_envio,b.hora_envio,b.usuario_envio,b.fecha_recepcion,b.hora_recepcion,b.usuario_recepcion,
				(NVL(a.cantidad_1,0) * 1000),(NVL(a.cantidad_2,0) * 500),(NVL(a.cantidad_3,0) * 200),(NVL(a.cantidad_4,0) * 100),(NVL(a.cantidad_5,0) * 50),
				(NVL(a.cantidad_6,0) * 20)
			INTO cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
				dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
				cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
				mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6
			FROM bdisuc:"informix".ss_operaciones a
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper 
				 AND b.monto > 0
				LEFT JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor
				LEFT JOIN bdisuc:"informix".ss_catstatus d ON b.status = d.status
				LEFT JOIN bdinteg:"informix".si_divisas e ON e.divisa = a.divisa
			WHERE a.cod_trans = '0002'
                AND b.id_solicitud = pIdSolicitud
				AND b.fecha_solicitud = pFechaSolicitud;		    				    		
		
		IF cFechaOperacion = '' OR cFechaOperacion IS NULL THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
				dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
				cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
				mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6;		
		END IF;	
		
		RETURN cCodRet,cFechaOperacion,mMontoEntradaSalida,cDescProveedor,cSucursal,cFolioServicio,cDescStatus,cUsuarioOpe,dCantidad1,dCantidad2,
			dCantidad3,dCantidad4,dCantidad5,dCantidad6,dCantidad7,mMontoOper,cFolioOper,cDescDivisa,cFechaSolicitud,cHoraSolicitud,
			cUsuarioSolicitud,cFechaEnvio,cHoraEnvio,cUsuarioEnvio,cFechaRecepcion,cHoraRecepcion,cUsuarioRecepcion,
			mCanTotal1,mCanTotal2,mCanTotal3,mCanTotal4,mCanTotal5,mCanTotal6;
		
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP que Consulta los detalles de Acuses libro 1',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultamelbdotaciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta CHAR(10), pTipOperacion CHAR(5), 
		pSucursal CHAR(8), pDireccionMac CHAR(12))
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultamelbdotaciones_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaConsulta = '' OR pTipOperacion = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;			
		
		 IF pTipOperacion = 'TODAS' THEN
			SELECT COUNT(*)
				INTO iNoRegistros
			FROM bdisuc:"informix".ss_recibe_datosdotacionws
			WHERE fecha_aplicacion = pFechaConsulta			
			AND usuario = pUsuario
			AND direccion_mac = pDireccionMac;
		 				
		ELSE 	
			
			IF pSucursal = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
			
			SELECT COUNT(*)
				INTO iNoRegistros
			FROM bdisuc:"informix".ss_recibe_datosdotacionws
			WHERE fecha_aplicacion = pFechaConsulta
			AND tipo_domicilio = pTipOperacion			
			AND sucursal_banco = pSucursal
			AND usuario = pUsuario
			AND direccion_mac = pDireccionMac;
		
		END IF; 
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		ELSE 
			RETURN cCodRet, iNoRegistros;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en LÃ­nea Bancoppel',
'DESCRIPCION: SP que consulta el total de Dotaciones del Monitor de Efectivo en LÃ­nea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultamelbtotalesacusesetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pTipoServicio CHAR(1))
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_dot,
			INTEGER AS dot_aceptadas,
			INTEGER AS dot_rechazadas,
			INTEGER AS total_concentra,
			INTEGER AS concentra_aceptadas,
			INTEGER AS concentra_rechazadas;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iTotalDot INTEGER;
	DEFINE iDotAceptadas INTEGER;
	DEFINE iDotRechazadas INTEGER;
	DEFINE iTotalConcentra INTEGER;
	DEFINE iConcentraAceptadas INTEGER;
	DEFINE iConcentraRechazadas INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iTotalDot = 0;
	LET iDotAceptadas = 0;
	LET iDotRechazadas = 0;
	LET iTotalConcentra = 0;
	LET iConcentraAceptadas = 0;
	LET iConcentraRechazadas = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultamelbtotalesacusesetv.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pTipoServicio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
		END IF;			
		
		IF pTipoServicio = 0 THEN
		
			--Dotaciones
			SELECT COUNT(*)
				INTO iTotalDot
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans in ('0001','0010','0036')
				AND id_solicitud <> ''
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin;
										
			SELECT COUNT(*)
				INTO iDotAceptadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans in ('0001','0010','0036')
				AND id_solicitud <> ''
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '0';
			
			SELECT COUNT(*)
				INTO iDotRechazadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans in ('0001','0010','0036')
				AND id_solicitud <> ''
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '1';
			
			--Concentraciones
			SELECT COUNT(*)
				INTO iTotalConcentra
			FROM bdisuc:"informix".ss_operaciones			
				WHERE cod_trans = '0026'
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin;
										
			SELECT COUNT(*)
				INTO iConcentraAceptadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans = '0026' 
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '0';
			
			SELECT COUNT(*)
				INTO iConcentraRechazadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans = '0026' 
				AND DATE(fecha_operacion) BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '1';
				
			IF iTotalDot = 0 AND iDotAceptadas = 0 AND iDotRechazadas = 0 AND iTotalConcentra = 0 AND iConcentraAceptadas = 0 AND iConcentraRechazadas = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			ELSE
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			END IF;	
		
		ELIF pTipoServicio = 1 THEN
		
			LET iTotalDot = 0;
			LET iDotAceptadas = 0;
			LET iDotRechazadas = 0;
			
			--Concentraciones
			SELECT COUNT(*)
				INTO iTotalConcentra
			FROM bdisuc:"informix".ss_operaciones			
				WHERE cod_trans = '0026'
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin;
										
			SELECT COUNT(*)
				INTO iConcentraAceptadas
			FROM bdisuc:"informix".ss_operaciones
			WHERE cod_trans = '0026' 
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '0';
			
			SELECT COUNT(*)
				INTO iConcentraRechazadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans = '0026' 
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '1';
				
			IF iTotalConcentra = 0 AND iConcentraAceptadas = 0 AND iConcentraRechazadas = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			ELSE
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			END IF;	
			
		ELIF pTipoServicio = 2 THEN
			
			LET iTotalConcentra = 0;
			LET iConcentraAceptadas = 0;
			LET iConcentraRechazadas = 0;
			
			--Dotaciones
			SELECT COUNT(*)
				INTO iTotalDot
			FROM bdisuc:"informix".ss_operaciones			
				WHERE cod_trans in ('0001','0010','0036')
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin;
										
			SELECT COUNT(*)
				INTO iDotAceptadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans in ('0001','0010','0036')
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin			
				AND reversado = '0';
			
			SELECT COUNT(*)
				INTO iDotRechazadas
			FROM bdisuc:"informix".ss_operaciones
				WHERE cod_trans in ('0001','0010','0036') 
				AND fecha_operacion BETWEEN pFechaInicio AND pFechaFin
				AND reversado = '1';
				
			IF iTotalDot = 0 AND iDotAceptadas = 0 AND iDotRechazadas = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			ELSE
				RETURN cCodRet, iTotalDot, iDotAceptadas, iDotRechazadas, iTotalConcentra, iConcentraAceptadas, iConcentraRechazadas;
			END IF;		
		END IF;
		
		

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP que consulta el total de Concentraciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultapanamericanoetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS centro_costos,
		CHAR(30) AS caja_general;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCentroCostos CHAR(4);
	DEFINE cCajaGeneral CHAR(30);		
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCentroCostos = '';
	LET cCajaGeneral = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCentroCostos,cCajaGeneral;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultapanamericanoetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCentroCostos,cCajaGeneral;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCentroCostos,cCajaGeneral;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCentroCostos,cCajaGeneral;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_ccpanamericano_etv2(pRegistros,pRecuperacion)
			INTO cCodRetSp,cCentroCostos,cCajaGeneral
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_consulta_ccpanamericano_etv2';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,cCentroCostos, TRIM(UPPER(cCajaGeneral)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet,cCentroCostos, cCajaGeneral;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCentroCostos,cCajaGeneral;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV Y MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar centro de costos de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultasucursalatmetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipOperacion CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS centro_costos,
		CHAR(40) AS cNombrecc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCentroCostos CHAR(4);
	DEFINE cNombreCc CHAR(40);	
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCentroCostos = '';	
	LET cNombreCc = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCentroCostos,cNombrecc ;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultasucursalatmetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCentroCostos,cNombrecc;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCentroCostos, cNombrecc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCentroCostos,cNombrecc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipOperacion = 1 THEN
		
			FOREACH
				EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_sucursal_atm_etv2(pRegistros, pRecuperacion)
				INTO cCodRetSp,cCentroCostos														
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP sp_consulta_sucursal_atm_etv2';
				END IF;
				
				SELECT nombre 
					INTO cNombreCc
				FROM bdinteg:si_sucursales
				WHERE sucursal = cCentroCostos;
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet,TRIM(UPPER(cCentroCostos)), TRIM(UPPER(cNombrecc)) WITH RESUME;	
			END FOREACH;
		
		ELSE 
		
			FOREACH
				EXECUTE PROCEDURE bdisuc:"informix".sp_consulta_sucursal_atm_etv2_2(pRegistros, pRecuperacion)
				INTO cCodRetSp,cCentroCostos														
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP sp_consulta_sucursal_atm_etv2_2';
				END IF;
				
				SELECT nombre 
					INTO cNombreCc
				FROM bdinteg:si_sucursales
				WHERE sucursal = cCentroCostos;
			
				LET iRecuperacion = iRecuperacion + 1;				
				RETURN cCodRet,TRIM(UPPER(cCentroCostos)), TRIM(UPPER(cNombrecc)) WITH RESUME;	
			END FOREACH;
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cCentroCostos, cNombrecc;				
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCentroCostos, cNombrecc;
		END IF;	
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 15/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar las Sucursales o ATMs de acuerdo al tipo de Reporte seleccionado.',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 14/06/2018',
'DESCRIPCION: Se agrega paginado para la recuperacion de las sucursales',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA: 07/06/2018',
'DESCRIPCION: Se agrega validacion de fin de registros para el paginado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallealtatipoconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEtv CHAR(40), pCg CHAR(4), pAtmSuc CHAR(4), pCajaGral CHAR(40),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(30) AS etv,
		CHAR(40) AS caja_general,
		CHAR(4) AS centro_costos,
		CHAR(10) AS no_sucursal_atm,
		CHAR(40) AS nombre_sucursal_atm,
		CHAR(10) AS tipo_concentracion,
		CHAR(1) AS estatus,
		INTEGER AS row_id;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cEtv CHAR(30);
	DEFINE cCaja_general CHAR(40);
	DEFINE cCentro_costos CHAR(4);
	DEFINE cNo_sucursal_atm CHAR(10);
	DEFINE cNombre_sucursal_atm CHAR(40);
	DEFINE cTipo_concentracion CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE iRowId INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cEtv = '';
	LET cCaja_general = '';
	LET cCentro_costos = '';
	LET cNo_sucursal_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion = '';
	LET cEstatus = '';
	LET iRowId = 0;
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallealtatipoconcentracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEtv = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pEtv = TRIM(pEtv);
		LET pCajaGral = TRIM(pCajaGral);
		LET pCg = TRIM(pCg);
		
		IF pAtmSuc = 0 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = centro_costos
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral = '' AND pCg <> '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = pCg
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral <> '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = centro_costos
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = pCg
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			END IF;
		
		ELIF pAtmSuc = 1 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = centro_costos
					AND no_sucursal_atm LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral = '' AND pCg <> '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = pCg
					AND no_sucursal_atm LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral <> '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = centro_costos
					AND no_sucursal_atm LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = pCg
					AND no_sucursal_atm LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			END IF;			
		
		ELIF pAtmSuc = 2 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = centro_costos
					AND no_sucursal_atm NOT LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral = '' AND pCg <> '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = caja_general
					AND centro_costos = pCg
					AND no_sucursal_atm NOT LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELIF pCajaGral <> '' AND pCg = '' THEN
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = centro_costos
					AND no_sucursal_atm NOT LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion 
					etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
					INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
					FROM bdisuc:"informix".ss_tipo_concentracion_etv 
					WHERE estatus = 'N' AND etv = pEtv
					AND caja_general = pCajaGral
					AND centro_costos = pCg
					AND no_sucursal_atm NOT LIKE 'P%'
					ORDER BY 2, 5 ASC
				
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, TRIM(UPPER(cEtv)), TRIM(UPPER(cCaja_general)), cCentro_costos, cNo_sucursal_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion)), TRIM(UPPER(cEstatus)), iRowId WITH RESUME;
				END FOREACH;
			END IF;	
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle del alta de tipo de concentración.',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA: 07/06/2018',
'DESCRIPCION: Se agrega validacion para seleccionar ATMS o Sucursales',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/07/2018',
'DESCRIPCION: Se amplia el tamaño del parametro de retorno sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallealtatipoconcentracion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEtv CHAR(40), pCg CHAR(4), pAtmSuc CHAR(4), pCajaGral CHAR(40))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cEtv CHAR(30);
	DEFINE cCaja_general CHAR(40);
	DEFINE cCentro_costos CHAR(4);
	DEFINE cNo_sucursal_atm CHAR(4);
	DEFINE cNombre_sucursal_atm CHAR(40);
	DEFINE cTipo_concentracion CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cEtv = '';
	LET cCaja_general = '';
	LET cCentro_costos = '';
	LET cNo_sucursal_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion = '';
	LET cEstatus = '';
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/calizarraga/sp_cg_detallealtatipoconcentracion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pEtv = TRIM(pEtv);
		LET pCajaGral = TRIM(pCajaGral);
		LET pCg = TRIM(pCg);
		
		IF pAtmSuc = 0 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = centro_costos;
			ELIF pCajaGral = '' AND pCg <> '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = pCg;
			ELIF pCajaGral <> '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = centro_costos;
			ELSE
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = pCg;
			END IF;
			
		ELIF pAtmSuc = 1 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = centro_costos
				AND no_sucursal_atm LIKE 'P%';
			ELIF pCajaGral = '' AND pCg <> '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = pCg
				AND no_sucursal_atm LIKE 'P%';
			ELIF pCajaGral <> '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = centro_costos
				AND no_sucursal_atm LIKE 'P%';
			ELSE
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = pCg
				AND no_sucursal_atm LIKE 'P%';
			END IF;
			
		ELIF pAtmSuc = 2 THEN
			IF pCajaGral = '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = centro_costos
				AND no_sucursal_atm NOT LIKE 'P%';
			ELIF pCajaGral = '' AND pCg <> '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = caja_general
				AND centro_costos = pCg
				AND no_sucursal_atm NOT LIKE 'P%';
			ELIF pCajaGral <> '' AND pCg = '' THEN
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = centro_costos
				AND no_sucursal_atm NOT LIKE 'P%';
			ELSE
				SELECT COUNT(*) INTO iNoRegistros
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus = 'N' AND etv = pEtv		
				AND caja_general = pCajaGral
				AND centro_costos = pCg
				AND no_sucursal_atm NOT LIKE 'P%';
			END IF;
		END IF;
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el número total de registros del alta de tipo de concentración.',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA: 07/06/2018',
'DESCRIPCION: Se agrega validacion para seleccionar ATMS o Sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebajatipoconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEtv CHAR(40), pCg CHAR(4), pAtmSuc CHAR(10),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(30) AS etv,
		CHAR(40) AS caja_general,
		CHAR(4) AS centro_costos,
		CHAR(10) AS no_sucursal_atm,
		CHAR(40) AS nombre_sucursal_atm,
		CHAR(10) AS tipo_concentracion,
		CHAR(1) AS estatus,
		INTEGER AS row_id;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cEtv CHAR(30);
	DEFINE cCaja_general CHAR(40);
	DEFINE cCentro_costos CHAR(4);
	DEFINE cNo_sucursal_atm CHAR(10);
	DEFINE cNombre_sucursal_atm CHAR(40);
	DEFINE cTipo_concentracion CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE iRowId INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cEtv = '';
	LET cCaja_general = '';
	LET cCentro_costos = '';
	LET cNo_sucursal_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion = '';
	LET cEstatus = '';
	LET iRowId = 0;
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/calizarraga/sp_cg_detallebajatipoconcentracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEtv = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pEtv = TRIM(pEtv);
		LET pCg = TRIM(pCg);
		LET pAtmSuc = TRIM(pAtmSuc);
		
		IF pCg = '' AND pAtmSuc = '' THEN
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
				INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus IN ('C','S')
				AND etv = pEtv
				AND centro_costos = centro_costos
				AND no_sucursal_atm = no_sucursal_atm
				ORDER BY 2, 5 ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId WITH RESUME;
			END FOREACH;
		ELIF pCg <> '' AND pAtmSuc = '' THEN
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
				INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus IN ('C','S')
				AND etv = pEtv
				AND centro_costos = pCg
				AND no_sucursal_atm = no_sucursal_atm
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId WITH RESUME;
			END FOREACH;
		ELIF pCg = '' AND pAtmSuc <> '' THEN
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
				INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus IN ('C','S')
				AND etv = pEtv
				AND centro_costos = centro_costos
				AND no_sucursal_atm = pAtmSuc
				ORDER BY 2, 5 ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId WITH RESUME;
			END FOREACH;
		ELSE
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion etv, caja_general, centro_costos, no_sucursal_atm, nombre_sucursal_atm, tipo_concentracion, estatus, ROWID
				INTO cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId
				FROM bdisuc:"informix".ss_tipo_concentracion_etv 
				WHERE estatus IN ('C','S')
				AND etv = pEtv
				AND centro_costos = pCg
				AND no_sucursal_atm = pAtmSuc
				ORDER BY 2, 5 ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId WITH RESUME;
			END FOREACH;
		END IF;
		
		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEtv, cCaja_general, cCentro_costos, cNo_sucursal_atm, cNombre_sucursal_atm, cTipo_concentracion, cEstatus, iRowId;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle de la baja de tipo de concentración.',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 05/07/2018',
'DESCRIPCION: Se amplia el tamaño del parametro de retorno sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebajatipoconcentracion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEtv CHAR(40), pCg CHAR(4), pAtmSuc CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cEtv CHAR(30);
	DEFINE cCaja_general CHAR(40);
	DEFINE cCentro_costos CHAR(4);
	DEFINE cNo_sucursal_atm CHAR(4);
	DEFINE cNombre_sucursal_atm CHAR(40);
	DEFINE cTipo_concentracion CHAR(10);
	DEFINE cEstatus CHAR(1);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cEtv = '';
	LET cCaja_general = '';
	LET cCentro_costos = '';
	LET cNo_sucursal_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion = '';
	LET cEstatus = '';
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebajatipoconcentracion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEtv = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET pEtv = TRIM(pEtv);
		LET pCg = TRIM(pCg);
		LET pAtmSuc = TRIM(pAtmSuc);
		
		IF pCg = '' AND pAtmSuc = '' THEN
			SELECT COUNT(*) INTO iNoRegistros FROM bdisuc:"informix".ss_tipo_concentracion_etv 
			WHERE estatus IN ('C','S') AND etv = pEtv
			AND centro_costos = centro_costos
			AND no_sucursal_atm = no_sucursal_atm;
		ELIF pCg <> '' AND pAtmSuc = '' THEN
			SELECT COUNT(*) INTO iNoRegistros FROM bdisuc:"informix".ss_tipo_concentracion_etv 
			WHERE estatus IN ('C','S') AND etv = pEtv
			AND centro_costos = pCg
			AND no_sucursal_atm = no_sucursal_atm;
		ELIF pCg = '' AND pAtmSuc <> '' THEN
			SELECT COUNT(*) INTO iNoRegistros FROM bdisuc:"informix".ss_tipo_concentracion_etv 
			WHERE estatus IN ('C','S') AND etv = pEtv
			AND centro_costos = centro_costos
			AND no_sucursal_atm = pAtmSuc;
		ELSE
			SELECT COUNT(*) INTO iNoRegistros FROM bdisuc:"informix".ss_tipo_concentracion_etv 
			WHERE estatus IN ('C','S') AND etv = pEtv
			AND centro_costos = pCg
			AND no_sucursal_atm = pAtmSuc;
		END IF;		
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 20/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el número total de registros de la baja de tipo de concentración.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacoramodificaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		DATE AS fecha,
		DATETIME HOUR TO FRACTION(3) AS hora,
		CHAR(10) AS tipo_mantenimiento,
		CHAR(8)  AS no_empleado,
		CHAR(40) AS nombre_etv;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cTipoMantenimiento CHAR(10);
	DEFINE cNoEmpleado CHAR(8);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreETV CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFecha = '';
	LET dHora = '';
	LET cTipoMantenimiento = '';
	LET cNoEmpleado = '';
	LET iRecuperacion = 0;
	LET cNombreETV = '';
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacoramodificaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion fecha,hora,tipo_mantenimiento,no_empleado, NVL(nombre_etv,'') nombre_etv
			INTO dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV
			FROM bdisuc:"informix".ss_bitacora_mant_etv a
			LEFT JOIN bdisuc:"informix".ss_catalago_etv b ON a.id_etv= b.rowid
			WHERE fecha BETWEEN pFechaInicio AND pFechaFin
			ORDER BY fecha,hora ASC
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha,dHora,cTipoMantenimiento,cNoEmpleado,cNombreETV;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 22/06/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV - BITÁCORA ALTAS Y BAJAS ETV',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitácora altas y bajas etv.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 31/07/2018',
'DESCRIPCION: Se agrega nombre de etv como parámetro de retorno.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacoramodificaciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacoramodificaciones_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdisuc:"informix".ss_bitacora_mant_etv 
		WHERE fecha BETWEEN pFechaInicio AND pFechaFin;
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 22/06/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV - BITÁCORA ALTAS Y BAJAS ETV',
'DESCRIPCION: SPL encargado de consultar el número total de registros de la bitácora altas y bajas etv.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacoratipoconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		DATE AS fecha,
		CHAR(25) AS hora,
		CHAR(10) AS tipo_mantenimiento,
		CHAR(8) AS usuario,
		CHAR(4) AS no_sucursal,
		CHAR(6) AS no_atm,
		CHAR(60) AS nombre_sucursal_atm,
		CHAR(10) AS tipo_concentracion_asignado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE dHora CHAR(25);
	DEFINE cTipo_mantenimiento CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cNo_sucursal CHAR(4);
	DEFINE cNo_atm CHAR(6);
	DEFINE cNombre_sucursal_atm CHAR(60);
	DEFINE cTipo_concentracion_asignado CHAR(10);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFecha = '';
	LET dHora = '';
	LET cTipo_mantenimiento = '';
	LET cUsuario = '';
	LET cNo_sucursal = '';
	LET cNo_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion_asignado = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacoratipoconcentracion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, hora, tipo_mantenimiento, usuario, no_sucursal, no_atm, nombre_sucursal_atm, tipo_concentracion_asignado
			INTO dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado
			FROM bdisuc:"informix".ss_bitacora_tipo_concentracion 
			WHERE fecha BETWEEN pFechaInicio AND pFechaFin
			ORDER BY 2 ASC
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFecha, dHora, TRIM(UPPER(cTipo_mantenimiento)), cUsuario, cNo_sucursal, cNo_atm, TRIM(UPPER(cNombre_sucursal_atm)), TRIM(UPPER(cTipo_concentracion_asignado)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, dHora, cTipo_mantenimiento, cUsuario, cNo_sucursal, cNo_atm, cNombre_sucursal_atm, cTipo_concentracion_asignado;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitácora de altas y bajas de tipo de concentración.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacoratipoconcentracion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret,
		INTEGER AS no_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE dHora CHAR(25);
	DEFINE cTipo_mantenimiento CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cNo_sucursal CHAR(4);
	DEFINE cNo_atm CHAR(6);
	DEFINE cNombre_sucursal_atm CHAR(60);
	DEFINE cTipo_concentracion_asignado CHAR(10);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFecha = '';
	LET dHora = '';
	LET cTipo_mantenimiento = '';
	LET cUsuario = '';
	LET cNo_sucursal = '';
	LET cNo_atm = '';
	LET cNombre_sucursal_atm = '';
	LET cTipo_concentracion_asignado = '';
	LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacoratipoconcentracion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdisuc:"informix".ss_bitacora_tipo_concentracion 
		WHERE fecha BETWEEN pFechaInicio AND pFechaFin;
		
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO DE EMPRESAS DE TRASLADO DE VALORES',
'DESCRIPCION: SPL encargado de consultar el número total de registros de la bitácora de altas y bajas de tipo de concentración.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_insertainfocomprobantetv(pUsuario CHAR(8), pIdFuncion CHAR(10),pFolioComprobante CHAR(16), pIdSolicitud CHAR(25),pFechaHora CHAR(20),pEstado CHAR(20),
		pMisc1 CHAR(40),pMisc2 CHAR(40),pMisc3 CHAR(40),pMisc4 CHAR(40),pMisc5 CHAR(40))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;	

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_insertainfocomprobantetv.out';
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
		
		INSERT INTO bdisuc:"informix".ss_informacion_comprobante_etv(folio_comprobante,id_solicitud,fecha_hora_solicitud,estado,misc1,misc2,misc3,misc4,misc5)
		VALUES(pFolioComprobante,pIdSolicitud,pFechaHora,pEstado,pMisc1,pMisc2,pMisc3,pMisc4,pMisc5);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00282';
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP que inserta la respuesta del servicio web Panamericano(Informacion por Comprobante)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_tipooperacionetv(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codRet,
			CHAR(20) AS tipo_operacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoOperacion CHAR(20);	
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoOperacion = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cTipoOperacion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_tipooperacionetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_tipo_operacion_etv()
			INTO cCodRetSp,cTipoOperacion
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisuc:sp_tipo_operacion_etv';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,TRIM(UPPER(cTipoOperacion)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 22/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el tipo de Operación ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_tiporeportetv(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codRet,
		CHAR(35) AS tipo_operacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoOperacion CHAR(35);	
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoOperacion = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cTipoOperacion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_tiporeportetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_tipo_reporte_etv2()
			INTO cCodRetSp,cTipoOperacion
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_tipo_reporte_etv';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,TRIM(UPPER(cTipoOperacion)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipoOperacion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 15/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÃNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el tipo de reporte ETV.',
'MODIFICACION: Martha Salgado',
'FECHA 30/07/2018',
'DESCRIPCION: Se modifica la longitud del retorno del campo tipo Operacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_tiposervicioacusesetv(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codRet,
			CHAR(15) AS tipo_servicio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoServicio CHAR(15);		
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoServicio = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cTipoServicio;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_tiposervicioacusesetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoServicio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoServicio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_tipo_servicio_acuses_etv()
			INTO cCodRetSp,cTipoServicio
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisuc:sp_tipo_servicio_acuses_etv';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet, TRIM(UPPER(cTipoServicio)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipoServicio;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MONITOR EFECTIVO EN LÍNEA BANCOPPEL',
'DESCRIPCION: Spl encargado de consultar el tipo de servicio de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_tiposervicioetv(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		CHAR(30) AS tipo_servicio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoServicio CHAR(30);	
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoServicio = '';	
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cTipoServicio;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_tiposervicioetv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoServicio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoServicio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_tipo_servicio_etv2()
			INTO cCodRetSp,cTipoServicio
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_tipo_servicio_etv';
			END IF;
		
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet,TRIM(UPPER(cTipoServicio)) WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipoServicio;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA 21/03/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: Spl encargado de consultar el tipo de servicio ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_cargaarchivomanttoctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pBloqueInf CHAR(2000), pIteracion CHAR(1))
	RETURNING CHAR(5) AS codret; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cRegistro LVARCHAR;
	DEFINE cCuenta CHAR(20);
	DEFINE cImporte CHAR(20);
	DEFINE cDescripcion CHAR(40);
	DEFINE cFecha CHAR(10);
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET cRegistro = '';
	LET cCuenta = '';
	LET cImporte = '';
	LET cDescripcion = '';
	LET cFecha = '';
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet; 
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_cargaarchivomanttoctas.out';
		--TRACE ON;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBloqueInf = '' OR pIteracion = '' THEN
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
		
		-- SE LIMPIA TABLA
		IF pIteracion = '0' THEN
			DELETE FROM "informix".sw_mc_ctascanceladas_tmp WHERE usuario = pUsuario;
		END IF;
		
		FOREACH
			
			EXECUTE PROCEDURE "informix".sp_split_cadena(pBloqueInf, '|')
			INTO cRegistro
			 
			LET cCuenta = SUBSTRING_INDEX(TRIM(cRegistro),'+',1);
			LET cImporte = SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(cRegistro),'+',2),'+',-1); 
			LET cDescripcion = SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(cRegistro),'+',-2),'+',1); 
			LET cFecha = SUBSTRING_INDEX(TRIM(cRegistro),'+',-1);
			
			INSERT INTO "informix".sw_mc_ctascanceladas_tmp(cuenta,importe,descripcion,fecha,usuario) 
			VALUES(cCuenta,cImporte,cDescripcion,cFecha,pUsuario);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;
			
		END FOREACH;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MANTENIMIENTO DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de hacer la carga del contenido del archivo a la tabla de paso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_detallectascanceladas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		MONEY(14,2) AS importe,
		CHAR(40) AS descripcion,
		DATE AS fecha;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE mImporte MONEY(14,2);
	DEFINE cDescripcion CHAR(40);	
	DEFINE dFecha DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET mImporte = 0.00;
	LET cDescripcion = '';
	LET dFecha = '';
	LET iRecuperacion = 0;

	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_detallectascanceladas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
		END IF;			
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion cuenta,importe,descripcion,fecha
			INTO cCuenta, mImporte, cDescripcion, dFecha
			FROM "informix".sw_mc_detallectascanceladas
			WHERE usuario_insert = pUsuario
			ORDER BY id_serial ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MANTENIMIENTO DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas cargadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_detallectascanceladas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_detallectascanceladas_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM "informix".sw_mc_detallectascanceladas
		WHERE usuario_insert = pUsuario;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MANTENIMIENTO DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de consultar el número total de cuentas cargadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_detallectasrecuperacionesp(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		MONEY(14,2) AS importe,
		CHAR(40) AS descripcion,
		DATE AS fecha,
		INTEGER AS id_registro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE mImporte MONEY(14,2);
	DEFINE cDescripcion CHAR(40);	
	DEFINE dFecha DATE;
	DEFINE iIdRegistro INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET mImporte = 0.00;
	LET cDescripcion = '';
	LET dFecha = '';
	LET iIdRegistro = 0;
	LET iRecuperacion = 0;

	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_detallectasrecuperacionesp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
		END IF;			
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion cuenta,importe,descripcion,fecha,id_serial
			INTO cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro
			FROM "informix".sw_mc_detallectasrecuperacionesp
			WHERE usuario_insert = pUsuario
			ORDER BY fecha DESC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01077'; --NO SE ENCONTRARON RESULTADOS CON EL NÚMERO DE CUENTA CAPTURADO, VERIFIQUE
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCuenta, mImporte, cDescripcion, dFecha, iIdRegistro;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas con recuperación especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_detallectasrecuperacionesp_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				UPDATE "informix".sw_mc_statusctasrecuperacionesp
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_detallectasrecuperacionesp_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_mc_statusctasrecuperacionesp WHERE usuario = pUsuario;
		DELETE FROM "informix".sw_mc_detallectasrecuperacionesp WHERE fecha_insert < DATE(CURRENT);
		DELETE FROM "informix".sw_mc_detallectasrecuperacionesp WHERE usuario_insert = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_mc_statusctasrecuperacionesp(usuario,status,num_registros,error_proceso,error)
		VALUES(pUsuario,'I',0,'','');  
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_mc_statusctasrecuperacionesp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_mc_statusctasrecuperacionesp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO "informix".sw_mc_detallectasrecuperacionesp(usuario_insert,fecha_insert,cuenta,importe,descripcion,fecha)
		SELECT pUsuario,DATE(CURRENT),cuenta,importe,descripcion,fecha
		FROM bdicheq:"informix".cuentas
		WHERE cuenta = pCuenta;
			
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM "informix".sw_mc_detallectasrecuperacionesp
		WHERE usuario_insert = pUsuario;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '01077'; --NO SE ENCONTRARON RESULTADOS CON EL NÚMERO DE CUENTA CAPTURADO, VERIFIQUE
			UPDATE "informix".sw_mc_statusctasrecuperacionesp
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		UPDATE "informix".sw_mc_statusctasrecuperacionesp
		SET status = 'T', error_proceso = 'N', error = cCodRet, num_registros = iNumRegistros WHERE usuario = pUsuario;  
		RETURN cCodRet, iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de consultar el número total de cuentas con recuperación especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_ejecutadesbloqueoctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cCodRetSp = '';
	LET cEmpresa = '001';
	LET iExiste = 0;
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				RETURN cCodRet; 
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_ejecutadesbloqueoctas.out';
		--TRACE ON; 
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
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
		
		-- SE EJECUTA LA CARGA DE LAS CUENTAS A LA TABLA DESTINO
		EXECUTE PROCEDURE bdicheq:"informix".desbloq_cuentas_corresp2(pCuenta,cEmpresa)
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicheq:"informix".desbloq_cuentas_corresp2';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '01078'; --NO HAY CUENTAS POR DESBLOQUEAR
			RETURN cCodRet;
		ELIF cCodRetSp::INTEGER = 0 THEN 
			RETURN cCodRet;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de ejecutar el desbloqueo de cuentas con recuperación especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_ejecutamanttoctas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cCodRetSp = '';
	LET cEmpresa = '001';
	LET iExiste = 0;
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				UPDATE "informix".sw_mc_statusctascanceladas
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
				RETURN cCodRet; 
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_ejecutamanttoctas.out';
		--TRACE ON;		
		
		-- SE LIMPIAN TABLAS POR USUARIO
		DELETE FROM "informix".sw_mc_statusctascanceladas WHERE usuario = pUsuario;		
		DELETE FROM "informix".sw_mc_detallectascanceladas WHERE fecha_insert < DATE(CURRENT);
		DELETE FROM "informix".sw_mc_detallectascanceladas WHERE usuario_insert = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_mc_statusctascanceladas(usuario,status,error_proceso,error)
		VALUES(pUsuario,'I','',''); 
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_mc_statusctascanceladas
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_mc_statusctascanceladas
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDA DUPLICIDAD DE CUENTAS
		SELECT COUNT(DISTINCT(cuenta))
		INTO iExiste
		FROM bdicnweb:"informix".sw_mc_ctascanceladas_tmp
		WHERE usuario = pUsuario
		AND cuenta IN(SELECT cuenta
						FROM bdicnweb:"informix".sw_mc_ctascanceladas_tmp
						WHERE usuario = pUsuario
						GROUP BY 1
						HAVING COUNT(*) > 1);
			
		IF NVL(iExiste,0) > 0 THEN
			LET cCodRet = '01075'; --EL ARCHIVO SELECCIONADO PRESENTA CUENTAS DUPLICADAS
			UPDATE "informix".sw_mc_statusctascanceladas
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet;
		END IF;
		
		-- SE EJECUTA LA CARGA DE LAS CUENTAS A LA TABLA DESTINO
		EXECUTE PROCEDURE bdicheq:"informix".bloqueoctas_corr2(pUsuario,cEmpresa)
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:"informix".bloqueoctas_corr2';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '01076'; --NO HAY CUENTAS POR CARGAR, EL ARCHIVO SE ENCUENTRA VACÃO
			UPDATE "informix".sw_mc_statusctascanceladas
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
			RETURN cCodRet;
		ELIF cCodRetSp::INTEGER = 0 THEN
			UPDATE "informix".sw_mc_statusctascanceladas
			SET status = 'T', error_proceso = 'N', error = cCodRet WHERE usuario = pUsuario; 
			RETURN cCodRet;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/07/2018',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MANTENIMIENTO DE CUENTAS CON RECUPERACIÃN ESPECIAL', 
'DESCRIPCION: SPL encargado de ejecutar la carga de cuentas canceladas.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/08/2018',
'DESCRIPCION: Se modifica SPL para realizar la validaciÃ³n de cuentas duplicadas por usuario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusctasrecuperacionesp(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusctasrecuperacionesp.out';
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
		FROM "informix".sw_mc_statusctasrecuperacionesp 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: CONSULTA DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de verificar el status de la consulta de cuentas con recuperación especial.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusmanttoctas(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusmanttoctas.out';
		--TRACE ON;
		
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
	
		SELECT status,error_proceso,error
		INTO cStatus,cErrorProceso,cError
		FROM "informix".sw_mc_statusctascanceladas 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/07/2018',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MANTENIMIENTO DE CUENTAS CON RECUPERACIÓN ESPECIAL', 
'DESCRIPCION: SPL encargado de verificar el status de la ejecución de la carga de cuentas canceladas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_conslistasolicitudesconcentracion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdBanco CHAR(2), pFechaDel DATE,  pFechaAl DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS id_banco,
			CHAR(25) AS id_solicitud, 
			CHAR(10) AS fecha_solicitud,
			CHAR(16) AS folio_comprobante, 
			CHAR(8) AS sucursal_banco, 	
			CHAR(40) AS nombre_sucursal,
			CHAR(30) AS sucursal_panam,
			DECIMAL(10,2) AS importe,
			CHAR(4) AS cod_panam,
			CHAR(5) AS hora_sol;				
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cIdbanco CHAR(5);
	DEFINE cIdSolicitud CHAR(25); 
	DEFINE cFechaSolicitud CHAR(10);
	DEFINE cFolioComprobante CHAR(16); 
	DEFINE cSucursalBanco CHAR(8); 	
	DEFINE cNombreSucursal CHAR(40);
	DEFINE cSucursalPanam CHAR(30); 
	DEFINE dImporte DECIMAL(10,2);
	DEFINE cCodPanam CHAR(4);
	DEFINE cHoraSol CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cIdbanco = '';
	LET cIdSolicitud = '';
	LET cFechaSolicitud = '';
	LET cFolioComprobante = '';
	LET cSucursalBanco = '';
	LET cNombreSucursal = '';
	LET cSucursalPanam = '';
	LET dImporte = 0.00;
	LET cCodPanam = '';
	LET cHoraSol = '';
		
		
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/informix/calizarraga/sp_cg_conslistasolicitudesconcentracion.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pIdBanco = '' OR pFechaDel IS NULL OR pFechaAl IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol;
		END IF;			
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion pIdBanco,a.id_solicitud,a.fecha_solicitud,a.folio_servicio,a.sucursal,b.nombre,c.caja_general,a.monto,c.sucursal,a.hora_solicitud
				INTO cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol
			FROM bdisuc:"informix".ss_mae_entradasalida a
			INNER JOIN bdisuc:"informix".ss_operaciones d ON a.folio_oper = d.folio_oper 
                AND d.cod_trans = '0002'   
				AND d.id_solicitud <> ''
			INNER JOIN bdinteg:"informix".si_sucursales b ON a.empresa = b.empresa
				AND a.sucursal = b.sucursal
			LEFT JOIN bdisuc:"informix".ss_sucursales_panamericano c ON a.cod_proveedor = c.centro_costos 
			WHERE a.fecha_solicitud BETWEEN pFechaDel AND pFechaAl
				AND a.monto > 0
			
			
			LET cIdSolicitud = SUBSTR(cIdSolicitud, 0, 4)||TRIM(LEADING '0' FROM SUBSTR(cIdSolicitud, 5, 4))|| SUBSTR(cIdSolicitud, 9, 13);
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol WITH RESUME;
		
		END FOREACH;		
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cIdbanco,cIdSolicitud,cFechaSolicitud,cFolioComprobante,cSucursalBanco,cNombreSucursal,cSucursalPanam,dImporte,cCodPanam,cHoraSol;
		END IF;		

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP que Consulta listado solicitudes concetracion',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA: 07/06/2018',
'DESCRIPCION: Se agrega parametro de fechas para consultar por periodos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_activaetv(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcionEtv CHAR(40))
    RETURNING CHAR(5) AS codret;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iRecuperacion INTEGER;
        DEFINE cEmpresa CHAR(3);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iRecuperacion = 0;
        LET cEmpresa = '001';

        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet;
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_cg_activaetv.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pDescripcionEtv = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
				
                UPDATE bdisuc:"informix".ss_catalago_etv
                SET activa = 'S'
                WHERE empresa = cEmpresa
                AND nombre_etv = UPPER(pDescripcionEtv);
				
				 --SE REGISTRA EN BITÁCORA
                 INSERT INTO bdisuc:"informix".ss_bitacora_mant_etv(empresa,fecha,hora,tipo_mantenimiento,no_empleado, id_etv)
                 VALUES(cEmpresa,CURRENT,CURRENT,'ALTA',pUsuario, (SELECT MAX(rowid) FROM bdisuc:"informix".ss_catalago_etv WHERE empresa = cEmpresa AND nombre_etv = UPPER(pDescripcionEtv)) );
				
                IF DBINFO('sqlca.sqlerrd2') =  0 THEN
                        LET cCodRet = '00282'; -- ERROR AL GUARDAR EL REGISTRO
                        RETURN cCodRet;
                ELSE
                        RETURN cCodRet;
                END IF;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Uriel Caamaño Mejia',
'FECHA: 21/06/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: MANTENIMIENTO ETV',
'DESCRIPCION: SPL encargado de actualizar un registro al catálogo de ETV.',
'AUTOR: Martha Salgado',
'FECHA: 22/08/2018',
'DESCRIPCION: Se agrega inserción a bitacora',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportectasconcentradas( pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pArchDescarga CHAR(500) )
RETURNING CHAR(5) AS codret;
    
	DEFINE cCodRet  CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE iExiste  INTEGER;
	DEFINE cCmd1    CHAR(1600);
	DEFINE cCmd2    CHAR(1600);
	
	LET cCodRet  = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
	LET iExiste  = 0;
    LET cCmd1    = '';
    LET cCmd2    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_reportectasconcentradas.err";
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN iSqlErr;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_reportectasconcentradas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet;
    END IF;
    
    EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo( pUsuario, pIdFuncion ) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM bdicheq:sc_ctasinactinfor3anios3meses cta,
           bdicnweb:sc_cuentas_concentradas_procesadas pro
     WHERE cta.cuenta = pro.cuenta
       AND pro.fecha_proceso BETWEEN pFechaInicio AND pFechaFin;
    
    IF iExiste = 0 THEN
        LET cCodRet = '00151';
        RETURN cCodRet;
    END IF;
    
    LET cCmd1 = 'SELECT UNIQUE cta.num_cte, TRIM(cta.cliente), cta.cuenta, mae.sucursal||" "||TRIM(suc.nombre), cta.num_tarjeta, TRIM(cta.producto), '||
                'mae.fec_ult_mov, cta.fech_ult_dep, cta.fech_ult_ret, NVL(TRIM(TO_CHAR(cta.sdo_actual, "#,###,###,###,##&.&&")),""), '||
                'NVL(DECODE(con.resultado, "1", "EXITOSO", "NO EXITOSO"),""), UPPER(stt.descripcion), NVL(con.folio,""), NVL(con.fecha_concentra,"") '||
                'FROM bdicnweb:sc_cuentas_concentradas_procesadas pro '||
                'INNER JOIN bdicheq:sc_ctasinactinfor3anios3meses cta ON ( cta.cuenta = pro.cuenta ) '||
                'INNER JOIN bdicheq:sc_maechq mae ON ( mae.cuenta = cta.cuenta ) '||
                'INNER JOIN bdicheq:sc_mae_estatus stt ON ( stt.cod_estatus = mae.status_cta ) '||
                'INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = mae.sucursal ) '||
                'LEFT OUTER JOIN bdicheq:sc_cuentas_concentradas con ON ( con.cuenta = cta.cuenta ) '||
                'WHERE pro.fecha_proceso BETWEEN "'||pFechaInicio||'" AND "'||pFechaFin||'" '; 
    
    LET cCmd2 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; UNLOAD TO "||TRIM(pArchDescarga)||" "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
    
    SYSTEM TRIM(cCmd2);
    
    RETURN cCodRet;
		
	END; 
    
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Realiza el reporte (unload) de las cuentas que fueron concentradas";

CREATE PROCEDURE "informix".sp_consultacatnumnomconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(2) AS numcategoria,
	CHAR(3) AS numconvenio,
	CHAR(40) AS nomconvenio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE isqlerr INTEGER;
	DEFINE cNumCategoria CHAR(2);
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE iNumRows INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET isqlerr = 0;
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cNomconvenio = '';
	LET iNoRegistros=0;


	BEGIN

	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatnumnomconveniosac.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL  THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
			RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END IF;
	
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END IF;

		IF pTipo = 'F' THEN
			SELECT COUNT(*)
			INTO iNumRows
			FROM bdisac:sac_convenios;
			IF iNumRows = 0 THEN
				LET cCodRet = '00017';
				RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion numcategoria, numconvenio, nomconvenio 
					INTO cNumCategoria, cNumConvenio, cNomconvenio
					FROM bdisac:sac_convenios
					
					LET iNoRegistros = iNoRegistros +1;
					
					RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
		
		IF  pTipo = 'E' THEN
			SELECT COUNT(flgreporte)
			INTO iNumRows
			FROM bdisac:sac_convenios
			WHERE flgreporte = '1';
			IF iNumRows = 0 THEN
				LET cCodRet = '00017';
				RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
			ELSE
				FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion numcategoria, numconvenio, nomconvenio 
					INTO cNumCategoria, cNumConvenio, cNomconvenio
					FROM bdisac:sac_convenios WHERE flgreporte = '1'
					
					LET iNoRegistros = iNoRegistros +1;
					
					RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
		
		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
		
			RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END IF;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'AUTOR MODIFICACIÃN: Martha Salgado Mendoza ',
'FECHA: 13/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Convenio SAC',
'DESCRIPCION: SP que consulta los Convenios, la modificaciÃ³n consiste en agregar paginado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargarchivobinesemisor(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaArchivo CHAR(100), pNombreArchivo CHAR(100))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);	
	DEFINE bInTransaction BOOLEAN;
	DEFINE cSQL CHAR(500);
	DEFINE ven_transacc SMALLINT;
	
	DEFINE cCampos CHAR(1024);
	DEFINE cTablaDst CHAR(150);
	DEFINE cBaseDatos CHAR(50);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cCmd2 CHAR(2000);
	DEFINE cUsrBin CHAR(15);
	
	
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cSQL = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET cCampos = '';
	LET cTablaDst = 'sw_ope_binesemisor';
	LET cBaseDatos = 'bdicnweb';
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cUsrBin = '/usr/bin/';
	
	
	BEGIN		
	
		ON EXCEPTION SET iSqlErr, cIsamErr, cDescErr  
			IF iSqlErr <> 0 THEN
			
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
			RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cargarchivobinesemisor.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaArchivo = '' OR  pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		TRUNCATE TABLE bdicnweb:"informix".sw_ope_binesemisor;
				
		BEGIN WORK;
		LET ven_transacc = 1;		
		
		LET cCampos = 'bin_emisor,id_bco,cd,monto_max,tipo,monto_acum,frecuencia,status_reg,fe_alta,fe_ultima,id_ultima,gpo_inter,nat_bin,id_prosa,';
		LET cCampos = TRIM(cCampos)||'banco_pros,id_eglobal,banco_eglo,pagos,marca_priv,tipo_produ,marca_prod,cuenta_mae,stand_in,responsabl,nombre_cor,';
		LET cCampos = TRIM(cCampos)||'manual,tpv,interred,atm,ecommerce,cargo_auto,venta_tele,sucursal,pago_inter,tarjeta_ch,fe_certifi,entidad_ce,folio_chip,linea_prod,producto';
		
		LET cCmd1 = TRIM(cUsrBin)||"echo "||'"'||"LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" DELIMITER '|' INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
		LET cCmd2 = TRIM(cCmd1)||TRIM(cCampos)||")"||'"'||" | /informix/bin/dbaccess bdicnweb > /dev/null 2>&1";
		SYSTEM TRIM(cCmd2);
		COMMIT WORK;
		
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE ELIMINA EL ARCHIVO ORIGINAL
		LET cSQL = '';
		LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
		SYSTEM TRIM(cSQL);
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 31/08/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Alta Baja de Bines',
'DESCRIPCION: SPL que inserta el archivo de Bines a BD para realizar la comparación de los mismos',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 31/08/2018',
'DESCRIPCION: Se amplia tamaño de parametro de entrada pNombreArchivo de CHAR(35) a CHAR(100)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_altabajabines_genrep(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoReporte CHAR(1), pRutaDescarga CHAR(150),pNombreReporte CHAR(50))
	RETURNING CHAR(5) AS codret,
	CHAR(150) AS archivo_generado;		

	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);	
	DEFINE cCmd1 CHAR(3000);	
	DEFINE cReporteGenerar CHAR(150);
	DEFINE cBinesElimina CHAR(150);
	DEFINE cArchDescarga CHAR(150);
	DEFINE cRuta CHAR(80);
	DEFINE cSql CHAR(3000);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cCmd1 = '';	
	LET cReporteGenerar = TRIM(pRutaDescarga) || pNombreReporte;	
	LET cArchDescarga = '';
	LET cRuta = '/tmp/mfinis/bines/';
	LET cSql = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, cIsamErr, cDescErr  
			IF iSqlErr <> 0 THEN
			
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
			RETURN cCodRet, cArchDescarga;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;	

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_altabajabines_genrep.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipoReporte = '' OR pRutaDescarga = '' OR pNombreReporte = '' THEN
			LET cCodRet = '00003';			
			RETURN cCodRet, cArchDescarga;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cArchDescarga;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		IF(pTipoReporte = 1) THEN
		
			BEGIN WORK;
			LET ven_transacc = 1;	
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'BIN','ID_BCO','CD','MONTO_MAX','TIPO','MONTO_ACUM','FRECUENCIA','STATUS_REG','FE_ALTA','FE_ULTIMA_','ID_ULTIMA_','GPO_INTER','NAT_BIN',"|| 
			"'ID_PROSA','BANCO_PROS','ID_EGLOBAL','BANCO_EGLO','PAGOS','MARCA_PRIV','TIPO_PRODU','MARCA_PROD','CUENTA_MAE','STAND_IN','RESPONSABL',"||	
			"'NOMBRE_COR','MANUAL','TPV','INTERRED','ATM','ECOMMERCE','CARGO_AUTO','VENTA_TELE','SUCURSAL','PAGO_INTER','TARJETA_CH','FE_CERTIFI',"||
			"'ENTIDAD_CE','FOLIO_CHIP','LINEA_PROD','PRODUCTO'"||
			'FROM systables WHERE tabid = 1 UNION ALL '|| 'SELECT bin_emisor::CHAR(6),id_bco::CHAR(2),cd::CHAR(1),monto_max::CHAR(20),tipo::CHAR(2),monto_acum::CHAR(20),frecuencia::CHAR(2),status_reg::CHAR(2),fe_alta::CHAR(25),fe_ultima::CHAR(25),id_ultima::CHAR(10),gpo_inter::CHAR(2),nat_bin::CHAR(2), ' ||
			'id_prosa::CHAR(8),banco_pros::CHAR(40),id_eglobal::CHAR(8),banco_eglo::CHAR(40),pagos::CHAR(2),marca_priv::CHAR(4),tipo_produ::CHAR(4),marca_prod::CHAR(4),cuenta_mae::CHAR(4),stand_in::CHAR(4),responsabl::CHAR(30),nombre_cor::CHAR(20),manual::CHAR(4),tpv::CHAR(4),interred::CHAR(4),atm::CHAR(4),ecommerce::CHAR(4),cargo_auto::CHAR(4),venta_tele::CHAR(4),' ||
			'sucursal::CHAR(4),pago_inter::CHAR(4),tarjeta_ch::CHAR(4),fe_certifi::CHAR(10),entidad_ce::CHAR(30),folio_chip::CHAR(4),linea_prod::CHAR(4),producto::CHAR(4) FROM bdicnweb:sw_ope_binesemisor '||
			'WHERE bin_emisor NOT IN(SELECT bin FROM bdicheq:sc_bines)';				
			
			LET cSql = 'echo "UNLOAD TO  '||TRIM(cReporteGenerar)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cCmd1)||'" > '|| TRIM(cRuta) ||'query4.sql';
			
			SYSTEM TRIM(cSql);			
			
			LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicnweb ' ||trim(cRuta)||'query4.sql';
			SYSTEM trim(cSql);
			
			COMMIT WORK;
		
		
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			LET cArchDescarga = pNombreReporte;
			
			
			RETURN cCodRet, cArchDescarga;
		
		END IF;
		
		IF(pTipoReporte = 2) THEN
			BEGIN WORK;
			LET ven_transacc = 1;	
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'BIN','ID_BCO','CD','MONTO_MAX','TIPO','MONTO_ACUM','FRECUENCIA','STATUS_REG','FE_ALTA','FE_ULTIMA_','ID_ULTIMA_','GPO_INTER','NAT_BIN',"|| 
			"'ID_PROSA','BANCO_PROS','ID_EGLOBAL','BANCO_EGLO','PAGOS','MARCA_PRIV','TIPO_PRODU','MARCA_PROD','CUENTA_MAE','STAND_IN','RESPONSABL',"||	
			"'NOMBRE_COR','MANUAL','TPV','INTERRED','ATM','ECOMMERCE','CARGO_AUTO','VENTA_TELE','SUCURSAL','PAGO_INTER','TARJETA_CH','FE_CERTIFI',"||
			"'ENTIDAD_CE','FOLIO_CHIP','LINEA_PROD','PRODUCTO'"||
			'FROM systables WHERE tabid = 1 UNION ALL '|| "SELECT bin,id_bco,creditodebito,''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1), " ||
			"cve_banco,banco_prosa,''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1)," ||
			"''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1),''::CHAR(1)  FROM bdicheq:sc_bines "||
			'WHERE bin NOT IN (SELECT bin_emisor FROM bdicnweb:sw_ope_binesemisor)';					
			 
			LET cSql = 'echo "UNLOAD TO  '||TRIM(cReporteGenerar)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cCmd1)||'" > '|| TRIM(cRuta) ||'query4.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicnweb ' ||trim(cRuta)||'query4.sql';
			SYSTEM trim(cSql);
	
	
			COMMIT WORK;		
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			LET cArchDescarga = pNombreReporte;
			RETURN cCodRet, cArchDescarga;
		
		END IF;											
				
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ALTA/BAJA DE BINES',
'DESCRIPCION: SP que genera reporte txt de las Transacciones Conciliadas de Inversion Creciente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_totalregistrosbines(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_encontrados,
			INTEGER AS total_noencontrados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalEncontrados INTEGER;
	DEFINE iTotalNoEncontrados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotalEncontrados = 0;
	LET iTotalNoEncontrados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalEncontrados, iTotalNoEncontrados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_totalregistrosbines.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalEncontrados, iTotalNoEncontrados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalEncontrados, iTotalNoEncontrados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iTotalEncontrados
		FROM bdicnweb:sw_ope_binesemisor 
		WHERE bin_emisor NOT IN(SELECT bin FROM bdicheq:sc_bines);
		
		SELECT COUNT(*) 
		INTO iTotalNoEncontrados
		FROM bdicheq:sc_bines
		WHERE bin NOT IN (SELECT bin_emisor FROM bdicnweb:sw_ope_binesemisor);	
		
		RETURN cCodRet, iTotalEncontrados, iTotalNoEncontrados;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 31/08/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Alta Baja de Bines',
'DESCRIPCION: SPL que realiza la consulta del total de bines encontrados y total de bines no encontrados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ca_ejecutacargaautomaticaxmlpba(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pNumIntentos SMALLINT)
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_error;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(6);
	DEFINE cDesCodRet CHAR(250);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(250);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cBanDetError CHAR(1);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cCmd CHAR(2000);
	DEFINE cPathdbaccess CHAR(35);
	DEFINE cUsrbin CHAR(15);
	--
	DEFINE dFormatoFechaPeriodo DATE;
	DEFINE dFechaPeriodo DATE;
	DEFINE cPeriodo CHAR(8);
	DEFINE cNombreOficio CHAR(100);
	DEFINE cGenClaveOficio CHAR(45);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicio DATE;
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE iCtrlIntentos SMALLINT;
	DEFINE iTotalArchivos INTEGER;
	DEFINE iContArch INTEGER;
	DEFINE cIniciaProceso CHAR(1);
	DEFINE cContinuaProceso CHAR(1);
	DEFINE cValidaContPro CHAR(1);
	DEFINE cCodRetSpCarga CHAR(5);
	DEFINE cCodRetSpProcesa CHAR(5);
	DEFINE cNumOficioSp CHAR(60);
	DEFINE iIdOficioSp INTEGER;
	--
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE cSolicitudSiara CHAR(60);
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE dFechaPublicacionDate DATE;
	DEFINE iDiasPlazo CHAR(2);
	DEFINE cNombreAutoridad CHAR(60);
	DEFINE cReferencia CHAR(60);
	DEFINE cUsuarioInsert CHAR(8);
	DEFINE dFechaInsert CHAR(25);
	DEFINE iIdSolEspecifica INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cNombre1 CHAR(60);
	DEFINE cNombre2 CHAR(60);
	DEFINE cRazonSocial CHAR(160);
	DEFINE cPrimerPalabra CHAR(150);
	DEFINE cSegundaPalabra CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombreSiCte CHAR(150);
	DEFINE cApellPaternoSiCte CHAR(26);
	DEFINE cApellMaternoSiCte CHAR(26);
	DEFINE cNom1ApPaterno CHAR(86);
	DEFINE cRFC CHAR(15);
	DEFINE cEntidad CHAR(50);
	DEFINE cCuenta CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cEstatus CHAR(1);
	DEFINE iTotalNumCliente INTEGER;
	DEFINE cFiltroRfc CHAR(15);
	--
	DEFINE cNomOfValEst CHAR(100);
	DEFINE iTotRegValEst INTEGER;
	DEFINE iTotSiCteValEst INTEGER;
	DEFINE iTotNoCteValEst INTEGER;
	--
	DEFINE cIdPlantilla CHAR(10);
	DEFINE cIdUsuario CHAR(8);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	
	DEFINE cValidaSegPalabra INTEGER;
	
	DEFINE iCountInfo INTEGER;
	DEFINE iRespuesta INTEGER;
	DEFINE iCounUifPe INTEGER;
	
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDesCodRet = 'EJECUCIÃN EXITOSA DEL PROCEDIMIENTO';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cBanDetError = 'f';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCmd = '';
	LET cPathdbaccess = '/ifxsif01/bin/';
	--LET cPathdbaccess = '/informix/bin/';
	LET cUsrbin = '/usr/bin/';
	--
	LET dFormatoFechaPeriodo = '';
	LET dFechaPeriodo = '';
	LET cPeriodo = '';
	LET cNombreOficio = '';
	LET cGenClaveOficio = 'OFICIOS_XML_'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.XML';
	LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicio = DATE(CURRENT);
	LET dFechaHoraFin = '';
	LET iCtrlIntentos = 0;
	LET iTotalArchivos = 0;
	LET iContArch = 0;
	LET cIniciaProceso = 'f';
	LET cContinuaProceso = 'f';
	LET cValidaContPro = 'f';
	LET cCodRetSpCarga = '00000';
	LET cCodRetSpProcesa = '00000';
	LET cNumOficioSp = '';
	LET iIdOficioSp = 0;
	--
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET cSolicitudSiara = '';
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET dFechaPublicacion = '';
	LET dFechaPublicacionDate = '';
	LET iDiasPlazo = '';
	LET cNombreAutoridad = '';
	LET cReferencia = '';
	LET cUsuarioInsert = '';
	LET dFechaInsert = '';
	LET iIdSolEspecifica = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cRazonSocial = '';
	LET cPrimerPalabra = '';
	LET cSegundaPalabra = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombreSiCte = '';
	LET cApellPaternoSiCte = '';
	LET cApellMaternoSiCte = '';
	LET cNom1ApPaterno = '';
	LET cRFC = '';
	LET cEntidad = '';
	LET cCuenta = '';
	LET cNumCliente = '';
	LET cEstatus = '';
	LET iTotalNumCliente = 0;
	LET cFiltroRfc = '';
	--
	LET cNomOfValEst = '';
	LET iTotRegValEst = 0;
	LET iTotSiCteValEst = 0;
	LET iTotNoCteValEst = 0;
	--
	LET cIdPlantilla = '';
	LET cIdUsuario = '';
	LET cStr6 = '';
	LET cStr7 = '';
	LET dHoy = '';	

	LET cValidaSegPalabra = 0;
	
	LET iCountInfo = 0;
	LET iRespuesta = 0;
	LET iCounUifPe = 0;
						
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
				--LET cCodRet = iSqlErr;
				LET cIdCodRet = iSqlErr;
				LET cDesCodRet = cDescErr;
				LET cBanDetError = 't';
				
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);

				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					LET cIdCodRet = '01028';
					LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
					
					UPDATE "informix".sw_ca_bitacoraprocesoxml
					SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
					WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01022';
						LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					END IF;
						
					-- SI EXISTEN, ELIMINA LOS ARCHIVO XML
					SELECT 1 INTO iRespuesta
					FROM "informix".sw_ca_buscaarchivosxml
					WHERE linea = TRIM(cNombreOficio);

					IF DBINFO('sqlca.sqlerrd2') > 0 THEN
						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
					END IF;
					
				END IF;	
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
						
				RETURN cCodRet, cBanDetError;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/informix/VHS/bdicnweb/sp/11052018/sp_ca_ejecutacargaautomaticaxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR pNumIntentos IS NULL THEN
			--LET cCodRet = '00003';
			LET cIdCodRet = '00003';
			LET cDesCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
				
			RETURN cCodRet, cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET cCodRet = '00000';
			LET cIdCodRet = '00028';
			LET cDesCodRet = 'EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR LA CONSULTA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
		
			RETURN cCodRet, cBanDetError;
		END IF;
		
		-- SE VALIDA QUE NO EXISTA ALGUNA EJECUCIÃN EN PROCESO
		SELECT 1 INTO iRespuesta
		FROM "informix".sw_ca_statuscargaxml
		WHERE status = 'I';		
		
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
		
			--LET cCodRet = '01029';
			LET cIdCodRet = '01029';
			LET cDesCodRet = 'NO ES POSIBLE CONTINUAR CON LA CARGA AUTOMÃTICA DE ARCHIVOS, ACTUALMENTE YA HAY UNA SOLICITUD EN PROCESO';
			LET cBanDetError = 't';
			
			INSERT INTO "informix".sw_ca_statuscargaxml(clave_oficio,status,bandera_error,cod_error,desc_error,usuario_insert,fecha_insert,fecha_hora_insert)
			VALUES(TRIM(cGenClaveOficio),'E',cBanDetError,cIdCodRet,cDesCodRet,pUsuario,dFechaInicio,dFechaHoraInicio);
		
			RETURN cCodRet, cBanDetError;
		
		ELSE
		
			-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
			DELETE FROM "informix".sw_ca_statuscargaxml WHERE usuario_insert = pUsuario;
			
			INSERT INTO "informix".sw_ca_statuscargaxml(clave_oficio,status,bandera_error,cod_error,desc_error,usuario_insert,fecha_insert,fecha_hora_insert)
			VALUES(TRIM(cGenClaveOficio),'I',cBanDetError,cIdCodRet,cDesCodRet,pUsuario,dFechaInicio,dFechaHoraInicio);
		
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
		
			-- SE CREAN TABLAS DE TRABAJO TEMPORALES
			DELETE FROM "informix".sw_ca_buscaarchivosxml;
			
			/*
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_ca_buscaarchivosxml') THEN
				DROP TABLE "informix".sw_ca_buscaarchivosxml;
			END IF;
			
			CREATE TABLE "informix".sw_ca_buscaarchivosxml(
																	linea CHAR(100)
																	);*/
			
			LET pRutaCarga = TRIM(pRutaCarga) || '/';
			
			-- SE GUARDAN LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA ESPECIFICADA
			LET cCmd = '';
			LET cCmd = 'ls '||TRIM(pRutaCarga)||' > '||TRIM(pRutaCarga)||'carpeta.car';
			SYSTEM TRIM(cCmd);
			
			LET cCmd = '';
			LET cCmd = 'echo "LOAD FROM '||TRIM(pRutaCarga)||'carpeta.car'||' INSERT INTO bdicnweb:sw_ca_buscaarchivosxml" > '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);		
			
			LET cCmd = '';
			LET cCmd = TRIM(cPathdbaccess)||'dbaccess bdicnweb '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			COMMIT WORK;
			SYSTEM TRIM(cCmd);
			BEGIN WORK;
			
			LET cCmd = '';
			LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||'carpeta.car'||" "||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);
			
			-- SE VALIDA QUE EL ARCHIVO EXISTA EN LA RUTA ESPECIFICADA
			SELECT COUNT(*) INTO iTotalArchivos
			FROM "informix".sw_ca_buscaarchivosxml
			WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml';
			
			IF iTotalArchivos = 0 THEN
				--LET cCodRet = '01021';
				LET cIdCodRet = '01021';
				LET cDesCodRet = 'NO EXISTE NINGÃN ARCHIVO .XML EN LA RUTA ESPECIFICADA';
				LET cBanDetError = 't';
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
					
				RETURN cCodRet, cBanDetError;
			END IF;		
			
			FOREACH WITH HOLD	--FOR Principal
			
				SELECT linea 
				INTO cNombreOficio
				FROM "informix".sw_ca_buscaarchivosxml
				WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml'
				
				-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
				DELETE FROM "informix".sw_ca_bitacoraprocesoxml WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert <> dFechaInicio;
				DELETE FROM "informix".sw_ca_bitacoraerroresxml WHERE nombre_oficio = TRIM(cNombreOficio);
				
				--DELETE FROM "informix".sw_ca_cuentasconocidas;
				--DELETE FROM "informix".sw_ca_personassolicitud;
				--DELETE FROM "informix".sw_ca_solicitudespecifica;
				--DELETE FROM "informix".sw_ca_solicitudpartes;
				--DELETE FROM "informix".sw_ca_encabezado;							
				
				LET iContArch = iContArch + 1;
				LET cIniciaProceso = 'f';
				LET cContinuaProceso = 'f';
				LET cValidaContPro = 'f';
				
				-- SE REGISTRA PROCESO
				SELECT 1 INTO iRespuesta
				FROM "informix".sw_ca_bitacoraprocesoxml
				WHERE nombre_oficio = TRIM(cNombreOficio)
				AND fecha_insert = dFechaInicio;
		
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					
					SELECT num_intentos INTO iCtrlIntentos 
					FROM "informix".sw_ca_bitacoraprocesoxml 
					WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;

					IF NVL(iCtrlIntentos,0) < pNumIntentos THEN
						
						LET iCtrlIntentos = NVL(iCtrlIntentos,0) + 1;
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'R', desc_estatus = 'REPROCESO', num_intentos = iCtrlIntentos, cod_error = '', desc_error = '', usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						ELSE
							LET cIniciaProceso = 't';
						END IF;
					
					ELSE
						
						LET cIdCodRet = '01028';
						LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						-- SE ELIMINAN TODOS LOS ARCHIVO XML
						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
						
					END IF;			
				
				ELSE 
				
					LET iCtrlIntentos = 1;
					
					INSERT INTO "informix".sw_ca_bitacoraprocesoxml(clave_oficio,nombre_oficio,id_estatus,desc_estatus,num_intentos,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
					VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),'E','EN PROCESO',iCtrlIntentos,'','','','',pUsuario,dFechaInicio,dFechaHoraInicio);
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01023';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REGISTRAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					ELSE
						LET cIniciaProceso = 't';
					END IF;
						
				END IF;
				
				-- SE INICIA EL PROCESO DE LA CARGA
				IF cIniciaProceso = 't' THEN
					
					EXECUTE PROCEDURE "informix".sp_ca_cargaarchivoxml(pUsuario, pIdFuncion, TRIM(pRutaCarga), TRIM(cNombreOficio))
					INTO cCodRetSpCarga;
					
					IF cCodRetSpCarga::INTEGER < 0 THEN
					
						--RAISE EXCEPTION cCodRetSpCarga::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						LET cIdCodRet = cCodRetSpCarga;
						LET cDesCodRet = 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
					ELIF cCodRetSpCarga::INTEGER > 0 THEN
					
						--LET cIdCodRet = cCodRetSpCarga;
						LET cIdCodRet = '01024';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
					ELIF cCodRetSpCarga::INTEGER = 0 THEN
						
						EXECUTE PROCEDURE "informix".sp_ca_procesaarchivoxml(pUsuario, pIdFuncion)
						INTO cCodRetSpProcesa, cNumOficioSp, iIdOficioSp;
						
						IF cCodRetSpProcesa::INTEGER < 0 THEN
						
							--RAISE EXCEPTION cCodRetSpProcesa::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							LET cIdCodRet = cCodRetSpProcesa;
							LET cDesCodRet = 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
							
						ELIF cCodRetSpProcesa::INTEGER > 0 THEN
						
							--LET cIdCodRet = cCodRetSpProcesa;
							LET cIdCodRet = '01025';
							LET cDesCodRet = 'OCURRIO UN ERROR AL PROCESAR LA INFORMACIÃN DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
						
						ELIF cCodRetSpProcesa::INTEGER = 0 THEN
						
							-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÃN
							SELECT COUNT(id_expediente) INTO iCountInfo
							FROM "informix".sw_ca_encabezado
							WHERE id_expediente = iIdOficioSp
							AND num_oficio = TRIM(cNumOficioSp);
							
							IF iCountInfo = 0 THEN	
								LET cIdCodRet = '01026';
								LET cDesCodRet = 'EL ARCHIVO SE ENCUENTRA VACÃO';
								
								INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
								VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
							
								LET cValidaContPro = 'f';
								
							ELSE
							
								-- SE INICIA EL LLENADO DE LA TABLA DESTINO
			
								SELECT num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,
								fecha_publicacion,dias_plazo,nombre_autoridad,referencia,usuario_insert,fecha_insert
								INTO cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,
								dFechaPublicacion,iDiasPlazo,cNombreAutoridad,cReferencia,cUsuarioInsert,dFechaInsert 
								FROM "informix".sw_ca_encabezado 
								WHERE id_expediente = iIdOficioSp
								AND num_oficio = TRIM(cNumOficioSp);
								
								LET dFechaPublicacionDate = MDY(SUBSTR(dFechaPublicacion, 6, 2), SUBSTR(dFechaPublicacion, 9, 2), SUBSTR(dFechaPublicacion, 1, 4));
								
								FOREACH WITH HOLD	--FOR Solicitud Especifica
									
									SELECT DISTINCT(id_solicitud_especifica)
									INTO iIdSolEspecifica
									FROM "informix".sw_ca_solicitudespecifica 
									WHERE id_expediente = iIdOficioSp 
									
									FOREACH WITH HOLD	--FOR Persona Solicitud/Cuentas Conocidas
									
										SELECT id_persona,caracter,des_tipo_persona,ap_paterno,ap_materno,nombre,rfc
										INTO iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC
										FROM "informix".sw_ca_personassolicitud 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										
										SELECT entidad,cuenta
										INTO cEntidad,cCuenta
										FROM "informix".sw_ca_cuentasconocidas 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										AND id_persona = iIdPersona;
										
										-- SE ELIMINAN ACENTOS
										LET cApellPaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellPaterno)),'Ã?','A'),'Ã?','E'),'Ã?','I'),'Ã?','O'),'Ã?','U')));
										LET cApellMaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellMaterno)),'Ã?','A'),'Ã?','E'),'Ã?','I'),'Ã?','O'),'Ã?','U')));
										LET cNombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cNombre)),'Ã','A'),'Ã','E'),'Ã','I'),'Ã','O'),'Ã','U');
										
										IF TRIM(UPPER(cDescTipoPersona)) = 'FISICA' THEN
											
											IF LENGTH(TRIM(cRFC)) = 13 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cNombre2 = NVL(TRIM(UPPER(SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1))), '');
											LET cNombre1 = TRIM(UPPER(SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre))));
											LET cNom1ApPaterno = '%'||TRIM(TRIM(UPPER(cNombre1))||' '||TRIM(UPPER(cApellPaterno)))||'%';
											
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente 
											WHERE nombre1 = cNombre1
											AND apell_paterno = cApellPaterno
											AND apell_materno = (CASE WHEN cApellMaterno = '' THEN '' ELSE cApellMaterno END)
											AND TRIM(UPPER(nombre2)) = (CASE WHEN cNombre2 = '' THEN '' ELSE cNombre2 END);
											--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
											--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END);
											--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END);					
											
											IF iTotalNumCliente > 0 THEN
											
												FOREACH	--FOR si_cliente
													
													SELECT  FIRST 1 apell_paterno,apell_materno,TRIM(TRIM(nombre1)||' '||TRIM(nombre2)),numcte 
													INTO cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente 
													WHERE nombre1 = cNombre1
													AND apell_paterno = cApellPaterno
													AND apell_materno = (CASE WHEN cApellMaterno = '' THEN '' ELSE cApellMaterno END)
													AND nombre2 = (CASE WHEN cNombre2 = '' THEN '' ELSE cNombre2 END)
													--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
													--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END)
													--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END)
													
													--INSERT
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
													
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--END si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												--INSERT
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
									
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
											
										ELIF TRIM(UPPER(cDescTipoPersona)) = 'MORAL' THEN
											
											IF LENGTH(TRIM(cRFC)) = 12 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cValidaSegPalabra = INSTR(cNombre, ' ',1,2);
											IF cValidaSegPalabra = 0 THEN
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1);
											ELSE
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre)+1, INSTR(cNombre, ' ',1,2)- CHARINDEX(' ', cNombre)-1);												
											END IF;
											LET cPrimerPalabra = SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre));
											LET cRazonSocial = TRIM(UPPER(cPrimerPalabra))|| ' ' || TRIM(UPPER(cSegundaPalabra)) || '%';
											
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente
											WHERE razon_social LIKE cRazonSocial
											AND rfc = (CASE WHEN cFiltroRfc = '' THEN rfc ELSE cFiltroRfc END);
											
											IF iTotalNumCliente > 0 THEN
											
												FOREACH	--FOR si_cliente
														
													SELECT  FIRST 1 razon_social,numcte 
													INTO cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente
													WHERE razon_social LIKE cRazonSocial
													AND rfc = (CASE WHEN cFiltroRfc = '' THEN rfc ELSE cFiltroRfc END)
													
													--INSERT
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
														
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--FOR si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												--INSERT
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
												
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
										
										ELSE --si no es ni MORAL ni FISICA
											
											--INSERT
											INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
											dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
											VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
											iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
												
											IF DBINFO('sqlca.sqlerrd2') = 0 THEN
											
												LET cIdCodRet = '01027';
												LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
												
												INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
											
												LET cValidaContPro = 'f';
											
											ELSE
												LET cValidaContPro = 't';
											END IF;
										
										END IF;
										
										CONTINUE FOREACH;
									END FOREACH;	--END Persona Solicitud/Cuentas Conocidas
									
									CONTINUE FOREACH;
								END FOREACH;	--END Solicitud Especifica
							END IF;
							
							IF cValidaContPro = 'f' THEN
								LET cContinuaProceso = 'f';
							ELIF cValidaContPro = 't' THEN
								LET cContinuaProceso = 't';
							END IF;
							
						END IF;	--END SP procesa
						
					END IF;	--END SP carga
					
				END IF;	--END iniciaproceso
				
				-- VALIDA EL NÃMERO DE INTENTOS PARA ACTUALIZAR PROCESO
				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
					ELIF cContinuaProceso = 'f' THEN 
						
						LET cIdCodRet = '00824';
						LET cDesCodRet = 'EL ARCHIVO DE DATOS NO TIENE EL FORMATO CORRECTO, VERIFIQUE';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
				
						LET cIdCodRet = '01028';
						LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						-- SE ELIMINAN TODOS LOS ARCHIVO XML							
						LET cCmd = '';
						LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
						
					END IF;
				
				ELSE
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
					END IF;
						
				END IF;
				
			END FOREACH;	--END Principal
			
		COMMIT WORK;
		
		TRUNCATE TABLE "informix".sw_ca_cuentasconocidas;
		TRUNCATE TABLE "informix".sw_ca_personassolicitud;
		TRUNCATE TABLE "informix".sw_ca_solicitudespecifica;
		TRUNCATE TABLE "informix".sw_ca_solicitudpartes;
		TRUNCATE TABLE "informix".sw_ca_encabezado;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE INICIAN VALIDACIONES DE ESTATUS
		FOREACH
		
			SELECT DISTINCT(nombre_oficio)
			INTO cNomOfValEst
			FROM "informix".sw_ca_archivosxml 
			WHERE fecha_hora_insert = dFechaHoraInicio
			
			-- ValidaciÃ³n UIF
			SELECT COUNT(*) INTO iCounUifPe
			FROM "informix".sw_ca_archivosxml 
			WHERE nombre_oficio = TRIM(cNomOfValEst)
			AND fecha_hora_insert = dFechaHoraInicio
			AND TRIM(UPPER(nombre_autoridad)) LIKE '%UNIDAD DE INTELIGENCIA FINANCIERA%';

			IF iCounUifPe > 0 THEN
				UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
				WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
				
			ELSE
				
				-- ValidaciÃ³n PeticiÃ³n Especifica 
				SELECT COUNT(*) INTO iCounUifPe
				FROM "informix".sw_ca_archivosxml 
				WHERE nombre_oficio = TRIM(cNomOfValEst)
				AND fecha_hora_insert = dFechaHoraInicio
				AND TRIM(UPPER(entidad)) LIKE '%BANCOPPEL%' AND cuenta <> '';

				IF iCounUifPe > 0 THEN
					UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
				
				ELSE 
				
					SELECT COUNT(*) INTO iTotRegValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio =  TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
					
					SELECT COUNT(*) INTO iTotSiCteValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio AND num_cliente <> '';
					
					SELECT COUNT(*) INTO iTotNoCteValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio AND num_cliente = '';
					
					IF iTotSiCteValEst = iTotRegValEst THEN
				
						UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
						WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
					
					ELIF iTotNoCteValEst = iTotRegValEst THEN
						
						SELECT 1 INTO iRespuesta
						FROM "informix".sw_ca_archivosxml
						WHERE nombre_oficio = TRIM(cNomOfValEst)
						AND fecha_hora_insert = dFechaHoraInicio
						GROUP BY nombre_ps,ap_paterno_ps,ap_materno_ps HAVING COUNT(*) > 1;

						IF DBINFO('sqlca.sqlerrd2') > 0 THEN
							
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
							WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
						ELSE 
						
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'N' 
							WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
						END IF;
						
					ELIF (iTotSiCteValEst + iTotNoCteValEst) = iTotRegValEst THEN
				
						UPDATE "informix".sw_ca_archivosxml SET estatus = 'M' 
						WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
					END IF;
					
				END IF;
				
			END IF;
			
		END FOREACH;
			
		IF cIdCodRet = '00000' THEN
			-- PROCESO EXITOSO
			LET cIdPlantilla = 'WEB_PLAXML';
		ELIF cIdCodRet <> '00000' THEN
			-- PROCESO CON ERRORES
			LET cIdPlantilla = 'WEB_ERRXML';
		END IF;
		
		LET cStr6 = 'NOTIFICACION CARGA AUTOMATICA DE ARCHIVOS XML';
		LET cStr7 = 'CARGA AUTOMATICA DE ARCHIVOS XML';
		LET dHoy = CURRENT;
		
		-- NOTIFICACIÃN VÃA CORREO ELECTRÃNICO
		FOREACH 
		
			SELECT id_usuario INTO cIdUsuario
			FROM bdinteg:"informix".si_seg_usuarios_funciones 
			WHERE id_funcion = 'ROA232'
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1',
			'WEB_PLAROF',
			TRIM(cIdPlantilla),
			cIdUsuario,
			'',
			'',
			'1',
			'',
			'',
			'',
			'',
			'',
			TRIM(cStr6),
			TRIM(cStr7),
			'',
			'',
			'',
			'',
			'',
			1,
			0,
			0,
			0,
			0,
			current,
			'') INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				
				--LET cCodRet = '01018';
				LET cIdCodRet = '01018';
				LET cDesCodRet = 'OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE';
				LET cBanDetError = 't';
				
				---UPDATE "informix".sw_ca_statuscargaxml
				---SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				---WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
								
			END IF;
		
		END FOREACH;
		
		-- ACTUALIZA STATUS FINAL
		UPDATE "informix".sw_ca_statuscargaxml
		SET status = 'T', bandera_error = cBanDetError, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
		WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
		
		RETURN cCodRet, cBanDetError;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA AUTOMÃTICA DE ARCHIVOS XML',
'DESCRIPCION: SPL encargado de realizar el proceso de carga automÃ¡tica de archivos XML.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/02/2018',
'DESCRIPCION: Se coloca nueva validaciÃ³n para tratar los status del proceso y del archivo cuando Ã©ste no cuenta con el formato esperado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ca_ejecutacargaautomaticaxmlpbanew(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pNumIntentos SMALLINT)
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_error;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(6);
	DEFINE cDesCodRet CHAR(250);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(250);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cBanDetError CHAR(1);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cCmd CHAR(2000);
	DEFINE cPathdbaccess CHAR(35);
	DEFINE cUsrbin CHAR(15);
	--
	DEFINE dFormatoFechaPeriodo DATE;
	DEFINE dFechaPeriodo DATE;
	DEFINE cPeriodo CHAR(8);
	DEFINE cNombreOficio CHAR(100);
	DEFINE cGenClaveOficio CHAR(45);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicio DATE;
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE iCtrlIntentos SMALLINT;
	DEFINE iTotalArchivos INTEGER;
	DEFINE iContArch INTEGER;
	DEFINE cIniciaProceso CHAR(1);
	DEFINE cContinuaProceso CHAR(1);
	DEFINE cValidaContPro CHAR(1);
	DEFINE cCodRetSpCarga CHAR(5);
	DEFINE cCodRetSpProcesa CHAR(5);
	DEFINE cNumOficioSp CHAR(60);
	DEFINE iIdOficioSp INTEGER;
	--
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE cSolicitudSiara CHAR(60);
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE dFechaPublicacionDate DATE;
	DEFINE iDiasPlazo CHAR(2);
	DEFINE cNombreAutoridad CHAR(60);
	DEFINE cReferencia CHAR(60);
	DEFINE cUsuarioInsert CHAR(8);
	DEFINE dFechaInsert CHAR(25);
	DEFINE iIdSolEspecifica INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cNombre1 CHAR(60);
	DEFINE cNombre2 CHAR(60);
	DEFINE cRazonSocial CHAR(160);
	DEFINE cPrimerPalabra CHAR(150);
	DEFINE cSegundaPalabra CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombreSiCte CHAR(150);
	DEFINE cApellPaternoSiCte CHAR(26);
	DEFINE cApellMaternoSiCte CHAR(26);
	DEFINE cNom1ApPaterno CHAR(86);
	DEFINE cRFC CHAR(15);
	DEFINE cEntidad CHAR(50);
	DEFINE cCuenta CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cEstatus CHAR(1);
	DEFINE iTotalNumCliente INTEGER;
	DEFINE cFiltroRfc CHAR(15);
	--
	DEFINE cNomOfValEst CHAR(100);
	DEFINE iTotRegValEst INTEGER;
	DEFINE iTotSiCteValEst INTEGER;
	DEFINE iTotNoCteValEst INTEGER;
	--
	DEFINE cIdPlantilla CHAR(10);
	DEFINE cIdUsuario CHAR(8);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	
	DEFINE cValidaSegPalabra INTEGER;
	
	DEFINE iCountInfo INTEGER;
	DEFINE iRespuesta INTEGER;
	DEFINE iCounUifPe INTEGER;
	
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDesCodRet = 'EJECUCIÃN EXITOSA DEL PROCEDIMIENTO';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cBanDetError = 'f';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCmd = '';
	LET cPathdbaccess = '/ifxsif01/bin/';
	--LET cPathdbaccess = '/informix/bin/';
	LET cUsrbin = '/usr/bin/';
	--
	LET dFormatoFechaPeriodo = '';
	LET dFechaPeriodo = '';
	LET cPeriodo = '';
	LET cNombreOficio = '';
	LET cGenClaveOficio = 'OFICIOS_XML_'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.XML';
	LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicio = DATE(CURRENT);
	LET dFechaHoraFin = '';
	LET iCtrlIntentos = 0;
	LET iTotalArchivos = 0;
	LET iContArch = 0;
	LET cIniciaProceso = 'f';
	LET cContinuaProceso = 'f';
	LET cValidaContPro = 'f';
	LET cCodRetSpCarga = '00000';
	LET cCodRetSpProcesa = '00000';
	LET cNumOficioSp = '';
	LET iIdOficioSp = 0;
	--
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET cSolicitudSiara = '';
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET dFechaPublicacion = '';
	LET dFechaPublicacionDate = '';
	LET iDiasPlazo = '';
	LET cNombreAutoridad = '';
	LET cReferencia = '';
	LET cUsuarioInsert = '';
	LET dFechaInsert = '';
	LET iIdSolEspecifica = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cRazonSocial = '';
	LET cPrimerPalabra = '';
	LET cSegundaPalabra = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombreSiCte = '';
	LET cApellPaternoSiCte = '';
	LET cApellMaternoSiCte = '';
	LET cNom1ApPaterno = '';
	LET cRFC = '';
	LET cEntidad = '';
	LET cCuenta = '';
	LET cNumCliente = '';
	LET cEstatus = '';
	LET iTotalNumCliente = 0;
	LET cFiltroRfc = '';
	--
	LET cNomOfValEst = '';
	LET iTotRegValEst = 0;
	LET iTotSiCteValEst = 0;
	LET iTotNoCteValEst = 0;
	--
	LET cIdPlantilla = '';
	LET cIdUsuario = '';
	LET cStr6 = '';
	LET cStr7 = '';
	LET dHoy = '';	

	LET cValidaSegPalabra = 0;
	
	LET iCountInfo = 0;
	LET iRespuesta = 0;
	LET iCounUifPe = 0;
						
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
				--LET cCodRet = iSqlErr;
				LET cIdCodRet = iSqlErr;
				LET cDesCodRet = cDescErr;
				LET cBanDetError = 't';
				
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);

				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					LET cIdCodRet = '01028';
					LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
					
					UPDATE "informix".sw_ca_bitacoraprocesoxml
					SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
					WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01022';
						LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					END IF;
						
					-- SI EXISTEN, ELIMINA LOS ARCHIVO XML
					SELECT 1 INTO iRespuesta
					FROM "informix".sw_ca_buscaarchivosxml
					WHERE linea = TRIM(cNombreOficio);

					IF DBINFO('sqlca.sqlerrd2') > 0 THEN
						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
					END IF;
					
				END IF;	
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
						
				RETURN cCodRet, cBanDetError;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/informix/VHS/bdicnweb/sp/11052018/sp_ca_ejecutacargaautomaticaxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR pNumIntentos IS NULL THEN
			--LET cCodRet = '00003';
			LET cIdCodRet = '00003';
			LET cDesCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
				
			RETURN cCodRet, cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET cCodRet = '00000';
			LET cIdCodRet = '00028';
			LET cDesCodRet = 'EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR LA CONSULTA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
		
			RETURN cCodRet, cBanDetError;
		END IF;
		
		-- SE VALIDA QUE NO EXISTA ALGUNA EJECUCIÃN EN PROCESO
		SELECT 1 INTO iRespuesta
		FROM "informix".sw_ca_statuscargaxml
		WHERE status = 'I';		
		
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
		
			--LET cCodRet = '01029';
			LET cIdCodRet = '01029';
			LET cDesCodRet = 'NO ES POSIBLE CONTINUAR CON LA CARGA AUTOMÃTICA DE ARCHIVOS, ACTUALMENTE YA HAY UNA SOLICITUD EN PROCESO';
			LET cBanDetError = 't';
			
			INSERT INTO "informix".sw_ca_statuscargaxml(clave_oficio,status,bandera_error,cod_error,desc_error,usuario_insert,fecha_insert,fecha_hora_insert)
			VALUES(TRIM(cGenClaveOficio),'E',cBanDetError,cIdCodRet,cDesCodRet,pUsuario,dFechaInicio,dFechaHoraInicio);
		
			RETURN cCodRet, cBanDetError;
		
		ELSE
		
			-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
			DELETE FROM "informix".sw_ca_statuscargaxml WHERE usuario_insert = pUsuario;
			
			INSERT INTO "informix".sw_ca_statuscargaxml(clave_oficio,status,bandera_error,cod_error,desc_error,usuario_insert,fecha_insert,fecha_hora_insert)
			VALUES(TRIM(cGenClaveOficio),'I',cBanDetError,cIdCodRet,cDesCodRet,pUsuario,dFechaInicio,dFechaHoraInicio);
		
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
		
			-- SE CREAN TABLAS DE TRABAJO TEMPORALES
			DELETE FROM "informix".sw_ca_buscaarchivosxml;
			
			/*
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_ca_buscaarchivosxml') THEN
				DROP TABLE "informix".sw_ca_buscaarchivosxml;
			END IF;
			
			CREATE TABLE "informix".sw_ca_buscaarchivosxml(
																	linea CHAR(100)
																	);*/
			
			LET pRutaCarga = TRIM(pRutaCarga) || '/';
			
			-- SE GUARDAN LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA ESPECIFICADA
			LET cCmd = '';
			LET cCmd = 'ls '||TRIM(pRutaCarga)||' > '||TRIM(pRutaCarga)||'carpeta.car';
			SYSTEM TRIM(cCmd);
			
			LET cCmd = '';
			LET cCmd = 'echo "LOAD FROM '||TRIM(pRutaCarga)||'carpeta.car'||' INSERT INTO bdicnweb:sw_ca_buscaarchivosxml" > '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);		
			
			LET cCmd = '';
			LET cCmd = TRIM(cPathdbaccess)||'dbaccess bdicnweb '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			COMMIT WORK;
			SYSTEM TRIM(cCmd);
			BEGIN WORK;
			
			LET cCmd = '';
			LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||'carpeta.car'||" "||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);
			
			-- SE VALIDA QUE EL ARCHIVO EXISTA EN LA RUTA ESPECIFICADA
			SELECT COUNT(*) INTO iTotalArchivos
			FROM "informix".sw_ca_buscaarchivosxml
			WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml';
			
			IF iTotalArchivos = 0 THEN
				--LET cCodRet = '01021';
				LET cIdCodRet = '01021';
				LET cDesCodRet = 'NO EXISTE NINGÃN ARCHIVO .XML EN LA RUTA ESPECIFICADA';
				LET cBanDetError = 't';
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
					
				RETURN cCodRet, cBanDetError;
			END IF;		
			
			FOREACH WITH HOLD	--FOR Principal
			
				SELECT linea 
				INTO cNombreOficio
				FROM "informix".sw_ca_buscaarchivosxml
				WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml'
				
				-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
				DELETE FROM "informix".sw_ca_bitacoraprocesoxml WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert <> dFechaInicio;
				DELETE FROM "informix".sw_ca_bitacoraerroresxml WHERE nombre_oficio = TRIM(cNombreOficio);
				
				--DELETE FROM "informix".sw_ca_cuentasconocidas;
				--DELETE FROM "informix".sw_ca_personassolicitud;
				--DELETE FROM "informix".sw_ca_solicitudespecifica;
				--DELETE FROM "informix".sw_ca_solicitudpartes;
				--DELETE FROM "informix".sw_ca_encabezado;							
				
				LET iContArch = iContArch + 1;
				LET cIniciaProceso = 'f';
				LET cContinuaProceso = 'f';
				LET cValidaContPro = 'f';
				
				-- SE REGISTRA PROCESO
				SELECT 1 INTO iRespuesta
				FROM "informix".sw_ca_bitacoraprocesoxml
				WHERE nombre_oficio = TRIM(cNombreOficio)
				AND fecha_insert = dFechaInicio;
		
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					
					SELECT num_intentos INTO iCtrlIntentos 
					FROM "informix".sw_ca_bitacoraprocesoxml 
					WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;

					IF NVL(iCtrlIntentos,0) < pNumIntentos THEN
						
						LET iCtrlIntentos = NVL(iCtrlIntentos,0) + 1;
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'R', desc_estatus = 'REPROCESO', num_intentos = iCtrlIntentos, cod_error = '', desc_error = '', usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						ELSE
							LET cIniciaProceso = 't';
						END IF;
					
					ELSE
						
						LET cIdCodRet = '01028';
						LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						-- SE ELIMINAN TODOS LOS ARCHIVO XML
						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
						
					END IF;			
				
				ELSE 
				
					LET iCtrlIntentos = 1;
					
					INSERT INTO "informix".sw_ca_bitacoraprocesoxml(clave_oficio,nombre_oficio,id_estatus,desc_estatus,num_intentos,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
					VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),'E','EN PROCESO',iCtrlIntentos,'','','','',pUsuario,dFechaInicio,dFechaHoraInicio);
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01023';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REGISTRAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					ELSE
						LET cIniciaProceso = 't';
					END IF;
						
				END IF;
				
				-- SE INICIA EL PROCESO DE LA CARGA
				IF cIniciaProceso = 't' THEN
					
					EXECUTE PROCEDURE "informix".sp_ca_cargaarchivoxml(pUsuario, pIdFuncion, TRIM(pRutaCarga), TRIM(cNombreOficio))
					INTO cCodRetSpCarga;
					
					IF cCodRetSpCarga::INTEGER < 0 THEN
					
						--RAISE EXCEPTION cCodRetSpCarga::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						LET cIdCodRet = cCodRetSpCarga;
						LET cDesCodRet = 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
					ELIF cCodRetSpCarga::INTEGER > 0 THEN
					
						--LET cIdCodRet = cCodRetSpCarga;
						LET cIdCodRet = '01024';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
					ELIF cCodRetSpCarga::INTEGER = 0 THEN
						
						EXECUTE PROCEDURE "informix".sp_ca_procesaarchivoxml(pUsuario, pIdFuncion)
						INTO cCodRetSpProcesa, cNumOficioSp, iIdOficioSp;
						
						IF cCodRetSpProcesa::INTEGER < 0 THEN
						
							--RAISE EXCEPTION cCodRetSpProcesa::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							LET cIdCodRet = cCodRetSpProcesa;
							LET cDesCodRet = 'ERROR EN LA EJECUCIÃN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
							
						ELIF cCodRetSpProcesa::INTEGER > 0 THEN
						
							--LET cIdCodRet = cCodRetSpProcesa;
							LET cIdCodRet = '01025';
							LET cDesCodRet = 'OCURRIO UN ERROR AL PROCESAR LA INFORMACIÃN DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
						
						ELIF cCodRetSpProcesa::INTEGER = 0 THEN
						
							-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÃN
							SELECT COUNT(id_expediente) INTO iCountInfo
							FROM "informix".sw_ca_encabezado
							WHERE id_expediente = iIdOficioSp
							AND num_oficio = TRIM(cNumOficioSp);
							
							IF iCountInfo = 0 THEN	
								LET cIdCodRet = '01026';
								LET cDesCodRet = 'EL ARCHIVO SE ENCUENTRA VACÃO';
								
								INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
								VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
							
								LET cValidaContPro = 'f';
								
							ELSE
							
								-- SE INICIA EL LLENADO DE LA TABLA DESTINO
			
								SELECT num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,
								fecha_publicacion,dias_plazo,nombre_autoridad,referencia,usuario_insert,fecha_insert
								INTO cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,
								dFechaPublicacion,iDiasPlazo,cNombreAutoridad,cReferencia,cUsuarioInsert,dFechaInsert 
								FROM "informix".sw_ca_encabezado 
								WHERE id_expediente = iIdOficioSp
								AND num_oficio = TRIM(cNumOficioSp);
								
								LET dFechaPublicacionDate = MDY(SUBSTR(dFechaPublicacion, 6, 2), SUBSTR(dFechaPublicacion, 9, 2), SUBSTR(dFechaPublicacion, 1, 4));
								
								FOREACH WITH HOLD	--FOR Solicitud Especifica
									
									SELECT DISTINCT(id_solicitud_especifica)
									INTO iIdSolEspecifica
									FROM "informix".sw_ca_solicitudespecifica 
									WHERE id_expediente = iIdOficioSp 
									
									FOREACH WITH HOLD	--FOR Persona Solicitud/Cuentas Conocidas
									
										SELECT id_persona,caracter,des_tipo_persona,ap_paterno,ap_materno,nombre,rfc
										INTO iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC
										FROM "informix".sw_ca_personassolicitud 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										
										SELECT entidad,cuenta
										INTO cEntidad,cCuenta
										FROM "informix".sw_ca_cuentasconocidas 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										AND id_persona = iIdPersona;
										
										-- SE ELIMINAN ACENTOS
										LET cApellPaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellPaterno)),'Ã?','A'),'Ã?','E'),'Ã?','I'),'Ã?','O'),'Ã?','U')));
										LET cApellMaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellMaterno)),'Ã?','A'),'Ã?','E'),'Ã?','I'),'Ã?','O'),'Ã?','U')));
										LET cNombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cNombre)),'Ã','A'),'Ã','E'),'Ã','I'),'Ã','O'),'Ã','U');
										
										IF TRIM(UPPER(cDescTipoPersona)) = 'FISICA' THEN
											
											IF LENGTH(TRIM(cRFC)) = 13 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cNombre2 = NVL(TRIM(UPPER(SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1))), '');
											LET cNombre1 = TRIM(UPPER(SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre))));
											LET cNom1ApPaterno = '%'||TRIM(TRIM(UPPER(cNombre1))||' '||TRIM(UPPER(cApellPaterno)))||'%';
											
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente 
											WHERE nombre1 = cNombre1
											AND apell_paterno = cApellPaterno
											AND apell_materno = (CASE WHEN cApellMaterno = '' THEN '' ELSE cApellMaterno END)
											AND TRIM(UPPER(nombre2)) = (CASE WHEN cNombre2 = '' THEN '' ELSE cNombre2 END);
											--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
											--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END);
											--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END);					
											
											IF iTotalNumCliente > 0 THEN
											
												FOREACH	--FOR si_cliente
													
													SELECT  FIRST 1 apell_paterno,apell_materno,TRIM(TRIM(nombre1)||' '||TRIM(nombre2)),numcte 
													INTO cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente 
													WHERE nombre1 = cNombre1
													AND apell_paterno = cApellPaterno
													AND apell_materno = (CASE WHEN cApellMaterno = '' THEN '' ELSE cApellMaterno END)
													AND nombre2 = (CASE WHEN cNombre2 = '' THEN '' ELSE cNombre2 END)
													--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
													--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END)
													--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END)
													
													--INSERT
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
													
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--END si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												--INSERT
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
									
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
											
										ELIF TRIM(UPPER(cDescTipoPersona)) = 'MORAL' THEN
											
											IF LENGTH(TRIM(cRFC)) = 12 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cValidaSegPalabra = INSTR(cNombre, ' ',1,2);
											IF cValidaSegPalabra = 0 THEN
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1);
											ELSE
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre)+1, INSTR(cNombre, ' ',1,2)- CHARINDEX(' ', cNombre)-1);												
											END IF;
											LET cPrimerPalabra = SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre));
											LET cRazonSocial = TRIM(UPPER(cPrimerPalabra))|| ' ' || TRIM(UPPER(cSegundaPalabra)) || '%';
											
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente
											WHERE razon_social LIKE cRazonSocial
											AND rfc = (CASE WHEN cFiltroRfc = '' THEN rfc ELSE cFiltroRfc END);
											
											IF iTotalNumCliente > 0 THEN
											
												FOREACH	--FOR si_cliente
														
													SELECT  FIRST 1 razon_social,numcte 
													INTO cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente
													WHERE razon_social LIKE cRazonSocial
													AND rfc = (CASE WHEN cFiltroRfc = '' THEN rfc ELSE cFiltroRfc END)
													
													--INSERT
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
														
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--FOR si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												--INSERT
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
												
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
										
										ELSE --si no es ni MORAL ni FISICA
											
											--INSERT
											INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
											dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
											VALUES(iIdOficioSp,TRIM(cNombreOficio),cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
											iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
												
											IF DBINFO('sqlca.sqlerrd2') = 0 THEN
											
												LET cIdCodRet = '01027';
												LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÃN DEL ARCHIVO PROCESADO';
												
												INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
											
												LET cValidaContPro = 'f';
											
											ELSE
												LET cValidaContPro = 't';
											END IF;
										
										END IF;
										
										CONTINUE FOREACH;
									END FOREACH;	--END Persona Solicitud/Cuentas Conocidas
									
									CONTINUE FOREACH;
								END FOREACH;	--END Solicitud Especifica
							END IF;
							
							IF cValidaContPro = 'f' THEN
								LET cContinuaProceso = 'f';
							ELIF cValidaContPro = 't' THEN
								LET cContinuaProceso = 't';
							END IF;
							
						END IF;	--END SP procesa
						
					END IF;	--END SP carga
					
				END IF;	--END iniciaproceso
				
				-- VALIDA EL NÃMERO DE INTENTOS PARA ACTUALIZAR PROCESO
				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
					ELIF cContinuaProceso = 'f' THEN 
						
						LET cIdCodRet = '00824';
						LET cDesCodRet = 'EL ARCHIVO DE DATOS NO TIENE EL FORMATO CORRECTO, VERIFIQUE';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
				
						LET cIdCodRet = '01028';
						LET cDesCodRet = 'HA LLEGADO AL NÃMERO MÃXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||TRIM(cNombreOficio);
						
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = TRIM(cGenClaveOficio), id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						-- SE ELIMINAN TODOS LOS ARCHIVO XML							
						LET cCmd = '';
						LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						SYSTEM TRIM(cCmd);
						
					END IF;
				
				ELSE
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = TRIM(cNombreOficio) AND fecha_insert = dFechaInicio;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||TRIM(cNombreOficio);
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
					END IF;
						
				END IF;
				
			END FOREACH;	--END Principal
			
		COMMIT WORK;
		
		TRUNCATE TABLE "informix".sw_ca_cuentasconocidas;
		TRUNCATE TABLE "informix".sw_ca_personassolicitud;
		TRUNCATE TABLE "informix".sw_ca_solicitudespecifica;
		TRUNCATE TABLE "informix".sw_ca_solicitudpartes;
		TRUNCATE TABLE "informix".sw_ca_encabezado;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE INICIAN VALIDACIONES DE ESTATUS
		FOREACH
		
			SELECT DISTINCT(nombre_oficio)
			INTO cNomOfValEst
			FROM "informix".sw_ca_archivosxml 
			WHERE fecha_hora_insert = dFechaHoraInicio
			
			-- ValidaciÃ³n UIF
			SELECT COUNT(*) INTO iCounUifPe
			FROM "informix".sw_ca_archivosxml 
			WHERE nombre_oficio = TRIM(cNomOfValEst)
			AND fecha_hora_insert = dFechaHoraInicio
			AND TRIM(UPPER(nombre_autoridad)) LIKE '%UNIDAD DE INTELIGENCIA FINANCIERA%';

			IF iCounUifPe > 0 THEN
				UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
				WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
				
			ELSE
				
				-- ValidaciÃ³n PeticiÃ³n Especifica 
				SELECT COUNT(*) INTO iCounUifPe
				FROM "informix".sw_ca_archivosxml 
				WHERE nombre_oficio = TRIM(cNomOfValEst)
				AND fecha_hora_insert = dFechaHoraInicio
				AND TRIM(UPPER(entidad)) LIKE '%BANCOPPEL%' AND cuenta <> '';

				IF iCounUifPe > 0 THEN
					UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
				
				ELSE 
				
					SELECT COUNT(*) INTO iTotRegValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio =  TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
					
					SELECT COUNT(*) INTO iTotSiCteValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio AND num_cliente <> '';
					
					SELECT COUNT(*) INTO iTotNoCteValEst FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio AND num_cliente = '';
					
					IF iTotSiCteValEst = iTotRegValEst THEN
				
						UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
						WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
					
					ELIF iTotNoCteValEst = iTotRegValEst THEN
						
						SELECT 1 INTO iRespuesta
						FROM "informix".sw_ca_archivosxml
						WHERE nombre_oficio = TRIM(cNomOfValEst)
						AND fecha_hora_insert = dFechaHoraInicio
						GROUP BY nombre_ps,ap_paterno_ps,ap_materno_ps HAVING COUNT(*) > 1;

						IF DBINFO('sqlca.sqlerrd2') > 0 THEN
							
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
							WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
						ELSE 
						
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'N' 
							WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
						END IF;
						
					ELIF (iTotSiCteValEst + iTotNoCteValEst) = iTotRegValEst THEN
				
						UPDATE "informix".sw_ca_archivosxml SET estatus = 'M' 
						WHERE nombre_oficio = TRIM(cNomOfValEst) AND fecha_hora_insert = dFechaHoraInicio;
						
					END IF;
					
				END IF;
				
			END IF;
			
		END FOREACH;
			
		IF cIdCodRet = '00000' THEN
			-- PROCESO EXITOSO
			LET cIdPlantilla = 'WEB_PLAXML';
		ELIF cIdCodRet <> '00000' THEN
			-- PROCESO CON ERRORES
			LET cIdPlantilla = 'WEB_ERRXML';
		END IF;
		
		LET cStr6 = 'NOTIFICACION CARGA AUTOMATICA DE ARCHIVOS XML';
		LET cStr7 = 'CARGA AUTOMATICA DE ARCHIVOS XML';
		LET dHoy = CURRENT;
		
		-- NOTIFICACIÃN VÃA CORREO ELECTRÃNICO
		FOREACH 
		
			SELECT id_usuario INTO cIdUsuario
			FROM bdinteg:"informix".si_seg_usuarios_funciones 
			WHERE id_funcion = 'ROA232'
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1',
			'WEB_PLAROF',
			TRIM(cIdPlantilla),
			cIdUsuario,
			'',
			'',
			'1',
			'',
			'',
			'',
			'',
			'',
			TRIM(cStr6),
			TRIM(cStr7),
			'',
			'',
			'',
			'',
			'',
			1,
			0,
			0,
			0,
			0,
			current,
			'') INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				
				--LET cCodRet = '01018';
				LET cIdCodRet = '01018';
				LET cDesCodRet = 'OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE';
				LET cBanDetError = 't';
				
				---UPDATE "informix".sw_ca_statuscargaxml
				---SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				---WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(TRIM(cGenClaveOficio),TRIM(cNombreOficio),cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
								
			END IF;
		
		END FOREACH;
		
		-- ACTUALIZA STATUS FINAL
		UPDATE "informix".sw_ca_statuscargaxml
		SET status = 'T', bandera_error = cBanDetError, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
		WHERE clave_oficio = TRIM(cGenClaveOficio) AND usuario_insert = pUsuario;
		
		RETURN cCodRet, cBanDetError;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA AUTOMÃTICA DE ARCHIVOS XML',
'DESCRIPCION: SPL encargado de realizar el proceso de carga automÃ¡tica de archivos XML.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/02/2018',
'DESCRIPCION: Se coloca nueva validaciÃ³n para tratar los status del proceso y del archivo cuando Ã©ste no cuenta con el formato esperado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_actporcentajeproveedores(pUsuario CHAR(8), pIdFuncion CHAR(10), pTrama CHAR(2000))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCadena CHAR(250);
	DEFINE cProvedor CHAR(60);
	DEFINE cPorcentaje CHAR(5);
	DEFINE cValidaPorcentaje CHAR(5);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCadena = '';
	LET cProvedor = '';
	LET cPorcentaje = '';
	LET cValidaPorcentaje = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_actporcentajeproveedores.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTrama = '' THEN
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
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTrama, '|')
			INTO cCadena
			
			LET cProvedor = SUBSTR(cCadena, 1, CHARINDEX(',', cCadena) - 1);
			LET cPorcentaje = SUBSTR(cCadena, CHARINDEX(',', cCadena) + 1);
			
			
			SELECT porcentaje INTO cValidaPorcentaje FROM bdisac:"informix".sac_porcentaje_repsoc WHERE UPPER(provedor) = cProvedor;
			
			IF cValidaPorcentaje <> cPorcentaje THEN
			
				UPDATE bdisac:"informix".sac_porcentaje_repsoc SET porcentaje = cPorcentaje	WHERE UPPER(provedor) = cProvedor;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '01063'; --OCURRIÓ UN ERROR AL ACTUALIZAR LA INFORMACIÓN, VERIFIQUE
					RETURN cCodRet;
				END IF;
			
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
		END FOREACH;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de actualizar los porcentajes de los proveedores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_catantad(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
        CHAR(2) AS num_categoria,
		CHAR(3) AS num_convenio,
		CHAR(40) AS nom_convenio;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCategoria CHAR(2);
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_catantad.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--ANTAD
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion numcategoria, numconvenio, nomconvenio
			INTO cNumCategoria, cNumConvenio, cNomConvenio
			FROM bdisac:"informix".sac_convenios
			WHERE UPPER(nomconvenio) LIKE '%ANTAD%'
			ORDER BY numcategoria ASC, numconvenio ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumCategoria,cNumConvenio,cNomConvenio;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo antad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_catproceso(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
        SMALLINT AS id_proceso,
		CHAR(50) AS desc_proceso;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iId_proceso SMALLINT;
	DEFINE cDesc_proceso CHAR(50);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iId_proceso = 0;
	LET cDesc_proceso = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iId_proceso,cDesc_proceso;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_catproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iId_proceso,cDesc_proceso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iId_proceso,cDesc_proceso;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_proceso, desc_proceso
			INTO iId_proceso, cDesc_proceso
			FROM (SELECT 1 AS id_proceso, nomconvenio AS desc_proceso
				  FROM bdisac:"informix".sac_convenios
				  WHERE numcategoria = '03' AND numconvenio = '001'
				  UNION ALL
				  SELECT 2 AS id_proceso, 'ANTAD' AS desc_proceso
				  FROM systables WHERE tabid = 1
				  ORDER BY id_proceso ASC)
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iId_proceso,cDesc_proceso WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iId_proceso,cDesc_proceso;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo proceso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_catventatiempoaire(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
        CHAR(4) AS cod_param,
		CHAR(2) AS valor,
		CHAR(50) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodParam CHAR(4);
	DEFINE cValor CHAR(2);
	DEFINE cDescripcion CHAR(50);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCodParam = '';
	LET cValor = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCodParam,cValor,cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_catventatiempoaire.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodParam,cValor,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodParam,cValor,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VENTA DE TIEMPO AIRE
		FOREACH
			SELECT cod_param, valor,
			CASE 
				WHEN valor = '1' THEN 'UNEFON'
				WHEN valor = '2' THEN 'AT&T'
				WHEN valor = '3' THEN 'TELCEL'
				WHEN valor = '4' THEN 'MOVISTAR'
				ELSE NULL END AS provedor
			INTO cCodParam, cValor, cDescripcion
			FROM bdisac:"informix".sac_param
			WHERE cod_param IN ('83','84','85','86')
			ORDER BY valor ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCodParam,cValor,cDescripcion WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cCodParam,cValor,cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo venta de tiempo aire.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_detalleproveedores(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCategoria CHAR(2), pNumConvenio CHAR(3),
pIdProv CHAR(2), pDescProv CHAR(50), pIdConsulta CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
        CHAR(60) AS provedor,
		CHAR(5) AS porcentaje;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cProvedor CHAR(60);
	DEFINE cPorcentaje CHAR(5);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cProvedor = '';
	LET cPorcentaje = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cProvedor,cPorcentaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_detalleproveedores.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cProvedor,cPorcentaje;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cProvedor,cPorcentaje;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cProvedor,cPorcentaje;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VENTA DE TIEMPO AIRE
		IF pIdConsulta = '1' THEN
			
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion provedor, porcentaje
				INTO cProvedor, cPorcentaje
				FROM bdisac:"informix".sac_porcentaje_repsoc
				WHERE id_provedor::INTEGER = (CASE WHEN pIdProv = '' THEN id_provedor ELSE pIdProv END)
				AND UPPER(provedor) = (CASE WHEN pDescProv = '' THEN UPPER(provedor) ELSE pDescProv END)
				AND UPPER(provedor) NOT LIKE '%ANTAD%'
				ORDER BY numcategoria ASC, numconvenio ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cProvedor,cPorcentaje WITH RESUME;
			END FOREACH;
			
		--ANTAD
		ELIF pIdConsulta = '2' THEN
			
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion provedor, porcentaje
				INTO cProvedor, cPorcentaje
				FROM bdisac:"informix".sac_porcentaje_repsoc
				WHERE numcategoria = (CASE WHEN pNumCategoria = '' THEN numcategoria ELSE pNumCategoria END)
				AND numconvenio = (CASE WHEN pNumConvenio = '' THEN numconvenio ELSE pNumConvenio END)
				AND UPPER(provedor) LIKE '%ANTAD%'
				ORDER BY numcategoria ASC, numconvenio ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cProvedor,cPorcentaje WITH RESUME;
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01101'; --NO EXISTE INFORMACIÓN CON LOS CRITERIOS DE BÚSQUEDA SELECCIONADOS
			RETURN cCodRet,cProvedor,cPorcentaje;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cProvedor,cPorcentaje;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle de proveedores.',
'Donde, id_consulta = 1 se refiere al detalle de venta de tiempo aire y id_consulta = 2 al detalle antad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_detrepoperaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCategoria CHAR(2), pNumConvenio CHAR(3),
pIdProv CHAR(2), pDescProv CHAR(50), pIdConsulta CHAR(1), pFechaInicio DATE, pFechaFin DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
        CHAR(20) AS fecha_mes,
		CHAR(40) AS proveedor,
		INTEGER AS num_operaciones,
		MONEY(16,2) AS importe_total,
		CHAR(5) AS porcentaje,
		MONEY(16,2) AS importe_sobre,
		MONEY(16,2) AS pago_bcp,
		MONEY(16,2) AS pago_cp;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMes CHAR(2);
	DEFINE cDescMes CHAR(10);
	DEFINE cAnio CHAR(4);
	DEFINE cFechaMes CHAR(20);
	DEFINE cProveedor CHAR(40);
	DEFINE iNumOperaciones INTEGER;
	DEFINE dImporteTotal MONEY(16,2);
	DEFINE cPorcentaje CHAR(5);
	DEFINE dImporteSobre MONEY(16,2);
	DEFINE dPagoBcp MONEY(16,2);
	DEFINE dPagoCp MONEY(16,2);
	DEFINE cNumCategoria CHAR(2);
	DEFINE cNumConvenio CHAR(3);
	DEFINE cProvedor CHAR(50);
	
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMes = '';
	LET cDescMes = '';
	LET cAnio = '';
	LET cFechaMes = '';
	LET cProveedor = '';
	LET iNumOperaciones = 0;
	LET dImporteTotal = 0.00;
	LET cPorcentaje = '';
	LET dImporteSobre = 0.00;
	LET dPagoBcp = 0.00;
	LET dPagoCp = 0.00;
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cProvedor = '';
	
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_detrepoperaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		--VENTA DE TIEMPO AIRE
		IF pIdConsulta = '1' THEN
			
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT(proveedor),SUM(num_operaciones) AS num_operaciones,SUM(importe_total) AS importe_total,porcentaje,SUM(importe_sobre) AS importe_sobre,SUM(pago_bcp) AS pago_bcp,SUM(pago_cp) AS pago_cp,
				MONTH(MAX(fecha_mes)) AS mes, YEAR(MAX(fecha_mes)) AS anio
				INTO cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp, cMes, cAnio
				FROM "informix".sw_repdetalleoperaciones
				WHERE usuario_insert = pUsuario
				GROUP BY proveedor, porcentaje
				ORDER BY proveedor ASC
				
				IF cMes::INTEGER = 1 THEN
					LET cDescMes = 'ENERO';
				ELIF cMes::INTEGER = 2 THEN
					LET cDescMes = 'FEBRERO';
				ELIF cMes::INTEGER = 3 THEN
					LET cDescMes = 'MARZO';
				ELIF cMes::INTEGER = 4 THEN
					LET cDescMes = 'ABRIL';
				ELIF cMes::INTEGER = 5 THEN
					LET cDescMes = 'MAYO';
				ELIF cMes::INTEGER = 6 THEN
					LET cDescMes = 'JUNIO';
				ELIF cMes::INTEGER = 7 THEN
					LET cDescMes = 'JULIO';
				ELIF cMes::INTEGER = 8 THEN
					LET cDescMes = 'AGOSTO';
				ELIF cMes::INTEGER = 9 THEN
					LET cDescMes = 'SEPTIEMBRE';
				ELIF cMes::INTEGER = 10 THEN
					LET cDescMes = 'OCTUBRE';
				ELIF cMes::INTEGER = 11 THEN
					LET cDescMes = 'NOVIEMBRE';
				ELIF cMes::INTEGER = 12 THEN
					LET cDescMes = 'DICIEMBRE';
				END IF;
				
				LET cFechaMes = TRIM(cDescMes)||'-'||cAnio;
				
				LET iNumRegistros = iNumRegistros + 1;
				RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp WITH RESUME;
				
			END FOREACH;
			
		--ANTAD
		ELIF pIdConsulta = '2' THEN
			LET cNumCategoria = pNumCategoria;
			LET cNumConvenio = pNumConvenio;
			

			IF (cNumCategoria <> '') THEN
				SELECT provedor
				INTO cProvedor
				FROM bdisac:"informix".sac_porcentaje_repsoc
				WHERE numcategoria = cNumCategoria
				AND numconvenio = cNumConvenio;
			END IF;
			
			IF (cProvedor <> '') THEN
			
					FOREACH
					
						SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT(proveedor),SUM(num_operaciones) AS num_operaciones,SUM(importe_total) AS importe_total,porcentaje,SUM(importe_sobre) AS importe_sobre,SUM(pago_bcp) AS pago_bcp,SUM(pago_cp) AS pago_cp,
						MONTH(MAX(fecha_mes)) AS mes, YEAR(MAX(fecha_mes)) AS anio
						INTO cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp, cMes, cAnio
						FROM "informix".sw_repdetalleoperaciones
						WHERE usuario_insert = pUsuario
						AND proveedor = cProvedor
						GROUP BY proveedor, porcentaje
						ORDER BY proveedor ASC

						
						IF cMes::INTEGER = 1 THEN
							LET cDescMes = 'ENERO';
						ELIF cMes::INTEGER = 2 THEN
							LET cDescMes = 'FEBRERO';
						ELIF cMes::INTEGER = 3 THEN
							LET cDescMes = 'MARZO';
						ELIF cMes::INTEGER = 4 THEN
							LET cDescMes = 'ABRIL';
						ELIF cMes::INTEGER = 5 THEN
							LET cDescMes = 'MAYO';
						ELIF cMes::INTEGER = 6 THEN
							LET cDescMes = 'JUNIO';
						ELIF cMes::INTEGER = 7 THEN
							LET cDescMes = 'JULIO';
						ELIF cMes::INTEGER = 8 THEN
							LET cDescMes = 'AGOSTO';
						ELIF cMes::INTEGER = 9 THEN
							LET cDescMes = 'SEPTIEMBRE';
						ELIF cMes::INTEGER = 10 THEN
							LET cDescMes = 'OCTUBRE';
						ELIF cMes::INTEGER = 11 THEN
							LET cDescMes = 'NOVIEMBRE';
						ELIF cMes::INTEGER = 12 THEN
							LET cDescMes = 'DICIEMBRE';
						END IF;

						
						LET cFechaMes = TRIM(cDescMes)||'-'||cAnio;

						
						LET iNumRegistros = iNumRegistros + 1;
						RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp WITH RESUME;

						
					END FOREACH;
			ELSE

					FOREACH
					
						SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT(proveedor),SUM(num_operaciones) AS num_operaciones,SUM(importe_total) AS importe_total,porcentaje,SUM(importe_sobre) AS importe_sobre,SUM(pago_bcp) AS pago_bcp,SUM(pago_cp) AS pago_cp,
						MONTH(MAX(fecha_mes)) AS mes, YEAR(MAX(fecha_mes)) AS anio
						INTO cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp, cMes, cAnio
						FROM "informix".sw_repdetalleoperaciones
						WHERE usuario_insert = pUsuario
						GROUP BY proveedor, porcentaje
						ORDER BY proveedor ASC
						
						IF cMes::INTEGER = 1 THEN
							LET cDescMes = 'ENERO';
						ELIF cMes::INTEGER = 2 THEN
							LET cDescMes = 'FEBRERO';
						ELIF cMes::INTEGER = 3 THEN
							LET cDescMes = 'MARZO';
						ELIF cMes::INTEGER = 4 THEN
							LET cDescMes = 'ABRIL';
						ELIF cMes::INTEGER = 5 THEN
							LET cDescMes = 'MAYO';
						ELIF cMes::INTEGER = 6 THEN
							LET cDescMes = 'JUNIO';
						ELIF cMes::INTEGER = 7 THEN
							LET cDescMes = 'JULIO';
						ELIF cMes::INTEGER = 8 THEN
							LET cDescMes = 'AGOSTO';
						ELIF cMes::INTEGER = 9 THEN
							LET cDescMes = 'SEPTIEMBRE';
						ELIF cMes::INTEGER = 10 THEN
							LET cDescMes = 'OCTUBRE';
						ELIF cMes::INTEGER = 11 THEN
							LET cDescMes = 'NOVIEMBRE';
						ELIF cMes::INTEGER = 12 THEN
							LET cDescMes = 'DICIEMBRE';
						END IF;
						
						LET cFechaMes = TRIM(cDescMes)||'-'||cAnio;
						
						LET iNumRegistros = iNumRegistros + 1;
						RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp WITH RESUME;
						
					END FOREACH;
			END IF;
			
		END IF;
		
		IF iNumRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01101'; --NO EXISTE INFORMACIÃ?N CON LOS CRITERIOS DE BÃ?SQUEDA SELECCIONADOS
			RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
		ELIF iNumRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFechaMes, cProveedor, iNumOperaciones, dImporteTotal, cPorcentaje, dImporteSobre, dPagoBcp, dPagoCp;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 04/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle del reporte de operaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_totrepoperaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCategoria CHAR(2), pNumConvenio CHAR(3),
pIdProv CHAR(2), pDescProv CHAR(50), pIdConsulta CHAR(1), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
        MONEY(18,2) AS importe_total,
		MONEY(18,2) AS importe_sobre,
		MONEY(18,2) AS pago_bcp,
		MONEY(18,2) AS pago_cp;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMes CHAR(2);
	DEFINE cDescMes CHAR(10);
	DEFINE cAnio CHAR(4);
	DEFINE cFechaMes CHAR(20);
	DEFINE cProveedor CHAR(40);
	DEFINE iNumOperaciones INTEGER;
	DEFINE dImporteTotal MONEY(16,2);
	DEFINE cPorcentaje CHAR(5);
	DEFINE dImporteSobre MONEY(16,2);
	DEFINE dPagoBcp MONEY(16,2);
	DEFINE dPagoCp MONEY(16,2);
	
	DEFINE iTotImporteTotal MONEY(18,2);
	DEFINE iTotImporteSobre  MONEY(18,2);
	DEFINE iTotPagoBCp MONEY(18,2);
	DEFINE iTotPagoCp MONEY(18,2);
	DEFINE iNumRegistros INTEGER;
	DEFINE cNumCategoria CHAR(2);
	DEFINE cNumConvenio CHAR(3);
	DEFINE cProvedor CHAR(50);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMes = '';
	LET cDescMes = '';
	LET cAnio = '';
	LET cFechaMes = '';
	LET cProveedor = '';
	LET iNumOperaciones = 0;
	LET dImporteTotal = 0.00;
	LET cPorcentaje = '';
	LET dImporteSobre = 0.00;
	LET dPagoBcp = 0.00;
	LET dPagoCp = 0.00;
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cProvedor = '';
	
	LET iTotImporteTotal = 0.00;
	LET iTotImporteSobre = 0.00;
	LET iTotPagoBCp = 0.00;
	LET iTotPagoCp = 0.00;
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_repdetalleoperaciones
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_totrepoperaciones.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_repdetalleoperaciones WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_repdetalleoperaciones(usuario_insert,status,importe_total,importe_sobre,pago_bcp,pago_cp,error_proceso,error) VALUES(pUsuario,'I',0.00,0.00,0.00,0.00,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_repdetalleoperaciones
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_repdetalleoperaciones
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
		END IF;

		-- SE LIMPIA TABLA DE PASO
		DELETE FROM "informix".sw_repdetalleoperaciones WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		--VENTA DE TIEMPO AIRE
		IF pIdConsulta = '1' THEN
			
			--Consulta Hoy
			INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
			SELECT b.fecha_pago AS fecha_mes, b.referencia2 AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, a.porcentaje,
			((b.importe_pago * a.porcentaje)/100) AS importe_sobre, 
			(((b.importe_pago * a.porcentaje)/100) * 0.20) AS pago_bcp,
			(((b.importe_pago * a.porcentaje)/100) * 0.80) AS pago_cp,
			pUsuario, DATE(CURRENT)
			FROM bdisac:"informix".sac_porcentaje_repsoc AS a
			LEFT JOIN bdisac:"informix".sac_movimientos AS b ON UPPER(a.provedor) = UPPER(b.referencia2)
			WHERE UPPER(b.referencia2) = (CASE WHEN (pDescProv) = '' THEN UPPER(b.referencia2) ELSE UPPER(pDescProv) END)
			AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
			AND UPPER(a.provedor) NOT LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
			GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
			
			--Consulta Histórica
			INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
			SELECT b.fecha_pago AS fecha_mes, b.referencia2 AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, a.porcentaje,
			((b.importe_pago * a.porcentaje)/100) AS importe_sobre, 
			(((b.importe_pago * a.porcentaje)/100) * 0.20) AS pago_bcp,
			(((b.importe_pago * a.porcentaje)/100) * 0.80) AS pago_cp,
			pUsuario, DATE(CURRENT)
			FROM bdisac:"informix".sac_porcentaje_repsoc AS a
			LEFT JOIN bdisac:"informix".sac_movimientoshistorial AS b ON UPPER(a.provedor) = UPPER(b.referencia2)
			WHERE UPPER(b.referencia2) = (CASE WHEN (pDescProv) = '' THEN UPPER(b.referencia2) ELSE UPPER(pDescProv) END)
			AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
			AND UPPER(a.provedor) NOT LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
			GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
			
			SELECT COUNT(*), SUM(importe_total) AS importe_total,SUM(importe_sobre) AS importe_sobre,SUM(pago_bcp) AS pago_bcp,SUM(pago_cp) AS pago_cp
			INTO iNumRegistros, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp
			FROM "informix".sw_repdetalleoperaciones
			WHERE usuario_insert = pUsuario;

			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '01101'; --NO EXISTE INFORMACIÓN CON LOS CRITERIOS DE BÚSQUEDA SELECCIONADOS
				UPDATE "informix".status_repdetalleoperaciones
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
			END IF;
			
			UPDATE "informix".status_repdetalleoperaciones
			SET status = 'T', error_proceso = 'N', 
			importe_total = iTotImporteTotal, 
			importe_sobre = iTotImporteSobre, 
			pago_bcp = iTotPagoBCp, 
			pago_cp = iTotPagoCp WHERE usuario_insert = pUsuario;
			
		--ANTAD
		ELIF pIdConsulta = '2' THEN
			
			
			LET cNumCategoria = pNumCategoria;
			LET cNumConvenio = pNumConvenio;
			

			IF (cNumCategoria <> '') THEN
				SELECT provedor
				INTO cProvedor
				FROM bdisac:"informix".sac_porcentaje_repsoc
				WHERE numcategoria = cNumCategoria
				AND numconvenio = cNumConvenio;
			END IF;
			
			--Consulta Hoy
			IF (cProvedor = '') THEN
				INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
				SELECT b.fecha_pago AS fecha_mes, a.nomconvenio AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, c.porcentaje,
				((b.importe_pago * c.porcentaje)/100) AS importe_sobre, 
				(((b.importe_pago * c.porcentaje)/100) * 0.20) AS pago_bcp,
				(((b.importe_pago * c.porcentaje)/100) * 0.80) AS pago_cp,
				pUsuario, DATE(CURRENT)
				FROM bdisac:"informix".sac_convenios AS a
				LEFT JOIN bdisac:"informix".sac_movimientos AS b ON UPPER(a.numcategoria) = UPPER(b.numcategoria) AND UPPER(a.numconvenio) = UPPER(b.numconvenio)
				LEFT JOIN bdisac:"informix".sac_porcentaje_repsoc AS c ON UPPER(a.nomconvenio) = UPPER(c.provedor)
				WHERE UPPER(a.nomconvenio) = (CASE WHEN (pDescProv) = '' THEN UPPER(a.nomconvenio) ELSE UPPER(pDescProv) END)
				AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
				AND UPPER(c.provedor) LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
				GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
				
				--Consulta Histórica
				INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
				SELECT b.fecha_pago AS fecha_mes, a.nomconvenio AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, c.porcentaje,
				((b.importe_pago * c.porcentaje)/100) AS importe_sobre, 
				(((b.importe_pago * c.porcentaje)/100) * 0.20) AS pago_bcp,
				(((b.importe_pago * c.porcentaje)/100) * 0.80) AS pago_cp,
				pUsuario, DATE(CURRENT)
				FROM bdisac:"informix".sac_convenios AS a
				LEFT JOIN bdisac:"informix".sac_movimientoshistorial AS b ON UPPER(a.numcategoria) = UPPER(b.numcategoria) AND UPPER(a.numconvenio) = UPPER(b.numconvenio)
				LEFT JOIN bdisac:"informix".sac_porcentaje_repsoc AS c ON UPPER(a.nomconvenio) = UPPER(c.provedor)
				WHERE UPPER(a.nomconvenio) = (CASE WHEN (pDescProv) = '' THEN UPPER(a.nomconvenio) ELSE UPPER(pDescProv) END)
				AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
				AND UPPER(c.provedor) LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
				GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
			ELSE
				INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
				SELECT b.fecha_pago AS fecha_mes, a.nomconvenio AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, c.porcentaje,
				((b.importe_pago * c.porcentaje)/100) AS importe_sobre, 
				(((b.importe_pago * c.porcentaje)/100) * 0.20) AS pago_bcp,
				(((b.importe_pago * c.porcentaje)/100) * 0.80) AS pago_cp,
				pUsuario, DATE(CURRENT)
				FROM bdisac:"informix".sac_convenios AS a
				LEFT JOIN bdisac:"informix".sac_movimientos AS b ON UPPER(a.numcategoria) = UPPER(b.numcategoria) AND UPPER(a.numconvenio) = UPPER(b.numconvenio)
				LEFT JOIN bdisac:"informix".sac_porcentaje_repsoc AS c ON UPPER(a.nomconvenio) = UPPER(c.provedor)
				WHERE UPPER(a.nomconvenio) = (CASE WHEN (pDescProv) = '' THEN UPPER(a.nomconvenio) ELSE UPPER(pDescProv) END)
				AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
				AND UPPER(c.provedor) LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
				AND b.numcategoria = cNumCategoria AND b.numconvenio = cNumConvenio
				GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
				
				--Consulta Histórica
				INSERT INTO "informix".sw_repdetalleoperaciones(fecha_mes,proveedor,num_operaciones,importe_total,porcentaje,importe_sobre,pago_bcp,pago_cp,usuario_insert,fecha_insert)
				SELECT b.fecha_pago AS fecha_mes, a.nomconvenio AS proveedor, COUNT(*) AS num_operaciones, b.importe_pago AS importe_total, c.porcentaje,
				((b.importe_pago * c.porcentaje)/100) AS importe_sobre, 
				(((b.importe_pago * c.porcentaje)/100) * 0.20) AS pago_bcp,
				(((b.importe_pago * c.porcentaje)/100) * 0.80) AS pago_cp,
				pUsuario, DATE(CURRENT)
				FROM bdisac:"informix".sac_convenios AS a
				LEFT JOIN bdisac:"informix".sac_movimientoshistorial AS b ON UPPER(a.numcategoria) = UPPER(b.numcategoria) AND UPPER(a.numconvenio) = UPPER(b.numconvenio)
				LEFT JOIN bdisac:"informix".sac_porcentaje_repsoc AS c ON UPPER(a.nomconvenio) = UPPER(c.provedor)
				WHERE UPPER(a.nomconvenio) = (CASE WHEN (pDescProv) = '' THEN UPPER(a.nomconvenio) ELSE UPPER(pDescProv) END)
				AND b.fecha_pago BETWEEN pFechaInicio AND pFechaFin
				AND UPPER(c.provedor) LIKE '%ANTAD%' AND  b.status_cancelado = 'N'
				AND b.numcategoria = cNumCategoria AND b.numconvenio = cNumConvenio
				GROUP BY proveedor, importe_total, porcentaje, fecha_mes;
			END IF;
			
			SELECT COUNT(*), SUM(importe_total) AS importe_total,SUM(importe_sobre) AS importe_sobre,SUM(pago_bcp) AS pago_bcp,SUM(pago_cp) AS pago_cp
			INTO iNumRegistros, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp
			FROM "informix".sw_repdetalleoperaciones
			WHERE usuario_insert = pUsuario;

			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '01101'; --NO EXISTE INFORMACIÓN CON LOS CRITERIOS DE BÚSQUEDA SELECCIONADOS
				UPDATE "informix".status_repdetalleoperaciones
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
			END IF;
			
			UPDATE "informix".status_repdetalleoperaciones
			SET status = 'T', error_proceso = 'N', 
			importe_total = iTotImporteTotal, 
			importe_sobre = iTotImporteSobre, 
			pago_bcp = iTotPagoBCp, 
			pago_cp = iTotPagoCp WHERE usuario_insert = pUsuario;
			
		END IF;
		
		RETURN cCodRet, iTotImporteTotal, iTotImporteSobre, iTotPagoBCp, iTotPagoCp;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 04/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de consultar el detalle de los totales del reporte de operaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cs_verificastatusrepoperaciones(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		MONEY(18,2) AS importe_total,
		MONEY(18,2) AS importe_sobre,
		MONEY(18,2) AS pago_bcp,
		MONEY(18,2) AS pago_cp,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	DEFINE iTotImporteTotal MONEY(18,2);
	DEFINE iTotImporteSobre  MONEY(18,2);
	DEFINE iTotPagoBCp MONEY(18,2);
	DEFINE iTotPagoCp MONEY(18,2);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	LET iTotImporteTotal = 0.00;
	LET iTotImporteSobre = 0.00;
	LET iTotPagoBCp = 0.00;
	LET iTotPagoCp = 0.00;
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iTotImporteTotal,iTotImporteSobre,iTotPagoBCp,iTotPagoCp,cErrorProceso,cError;		
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cs_verificastatusrepoperaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotImporteTotal,iTotImporteSobre,iTotPagoBCp,iTotPagoCp,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotImporteTotal,iTotImporteSobre,iTotPagoBCp,iTotPagoCp,cErrorProceso,cError;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,importe_total,importe_sobre,pago_bcp,pago_cp,error_proceso,error
		INTO cStatus,iTotImporteTotal,iTotImporteSobre,iTotPagoBCp,iTotPagoCp,cErrorProceso,cError
		FROM "informix".status_repdetalleoperaciones WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iTotImporteTotal,iTotImporteSobre,iTotPagoBCp,iTotPagoCp,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 04/09/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: FACTOR DE COBRO DE SERVICIOS',
'DESCRIPCION: SPL encargado de verificar el status del detalle del reporte de operaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conscausaimpresionedocta (pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_motivo_impresion_cfdi,
				CHAR(150) AS desc_motivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdMotivo INTEGER;
	DEFINE cDescMotivo CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdMotivo = 0;
	LET cDescMotivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdMotivo, cDescMotivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conscausaimpresionedocta .out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdMotivo, cDescMotivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdMotivo, cDescMotivo;
		END IF;
		
		-- VALIDACIÓN DEL SISTEMA CUENTA
		IF pSistemaCuenta NOT IN ('01', '06') THEN 
			LET cCodRet = '00077';
			RETURN cCodRet, iIdMotivo, cDescMotivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH	SELECT id_motivo, d_motivo
			INTO iIdMotivo, cDescMotivo
			FROM bdicnweb:"informix".kw_cat_motivos_impresion_cfdi
			WHERE sistema_cuenta = pSistemaCuenta
			
			RETURN cCodRet, iIdMotivo, cDescMotivo WITH RESUME;
			
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdMotivo, cDescMotivo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los motivos de impresión de estado de cuenta de CFDI para el kiosko',
'FECHA: 28/10/2014',
'DESCRIPCION: Se agrega el sistema cuenta en los parametros de entrada para la consulta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoestado(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta SMALLINT, pConsulta CHAR(30))
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS cod_estado,
		CHAR(30) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdEstado CHAR(2);
	DEFINE cNombreEstado CHAR(30);
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdEstado = '';
	LET cNombreEstado = '';
	LET iExiste = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdEstado, cNombreEstado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoestado.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdEstado, cNombreEstado;
		END IF;
		
		-- VALIDACIÃN DEL TIPO DE BUSQUEDA
		IF pTipoConsulta NOT IN (1, 2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cIdEstado, cNombreEstado;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdEstado, cNombreEstado;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_estados;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdEstado, cNombreEstado;
		END IF;
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH
					SELECT {+INDEX (bdinteg:si_estados inx_estado)} estado, nombre INTO cIdEstado, cNombreEstado 
					FROM bdinteg:"informix".si_estados WHERE pais != '' AND estado != '' 
					ORDER BY nombre ASC     

					RETURN cCodRet, cIdEstado, cNombreEstado WITH RESUME;
			END FOREACH;
		ELIF pTipoConsulta = 2 THEN
			FOREACH
					SELECT {+INDEX (bdinteg:si_estados inx_estado)} estado, nombre INTO cIdEstado, cNombreEstado 
					FROM bdinteg:"informix".si_estados 
					WHERE pais != '' AND estado != '' AND nombre LIKE '%' || TRIM(pConsulta) || '%' 
					ORDER BY nombre ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cIdEstado, cNombreEstado WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdEstado, cNombreEstado;
			END IF;
		END IF;
	
	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de estados";

CREATE PROCEDURE "informix".sp_catalogoedificio(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pIdZona SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(30) AS nombre_domicilio,
		SMALLINT AS clave_complemento;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cNombreDomicilio CHAR(30);
	DEFINE iClaveComplemento SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET cNombreDomicilio = '';
	LET iClaveComplemento = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoedificio.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pIdZona IS NULL OR pTipoConsulta IS NULL OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catdomicilios;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
		END IF;
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH 
					SELECT SKIP pRegistros FIRST pRecuperacion nombredomicilio, complementoclave
					INTO cNombreDomicilio, iClaveComplemento 
					FROM bdinteg:"informix".si_catdomicilios 
					WHERE numerociudad = pIdCiudadCoppel AND numerocolonia = pIdZona AND clavedomicilio = 5 
					ORDER BY nombredomicilio ASC 

					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, cNombreDomicilio, iClaveComplemento WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH
					SELECT SKIP pRegistros FIRST pRecuperacion nombredomicilio, complementoclave 
					INTO cNombreDomicilio, iClaveComplemento 
					FROM bdinteg:"informix".si_catdomicilios 
					WHERE numerociudad = pIdCiudadCoppel AND numerocolonia = pIdZona
					AND clavedomicilio = 5 AND nombredomicilio LIKE '%' || TRIM(pConsulta) || '%' 
					ORDER BY nombredomicilio ASC 

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNombreDomicilio, iClaveComplemento WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNombreDomicilio, iClaveComplemento;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades";

CREATE PROCEDURE "informix".sp_sw_ro_consultapersonasencontradas(pUsuarioC CHAR(8), pFuncionC CHAR(10), pIdOficio INT,pIp CHAR(15), 
                                                                                                                pMacAddress CHAR(12), pNumRegistro INT, pNumRecuperaciON INT)
        RETURNING CHAR(5) AS codRet, 
                CHAR(20) AS numeroCliente, 
                CHAR(15) AS rfc,
                CHAR(26) AS nombre1, 
                CHAR(26) AS nombre2, 
                CHAR(26) AS apPaterno, 
                CHAR(26) AS apMaterno, 
                CHAR(60) AS razonSocial,
                CHAR(20) AS noCuenta,
                CHAR(20) AS noTarjeta,
                CHAR(2) AS tipoPersona, 
                CHAR(1) AS tipoCliente, 
                INT AS status, 
                CHAR(20) AS descStatusBusqueda,
                CHAR(1) AS ind_omitido,
                CHAR(1) AS ind_bloqueocta,
                CHAR(1) AS ind_terminado,
                INT AS id_busqueda,
                INT AS id_rescte, 
                CHAR(2) AS tipocuenta,
                CHAR(1) AS ind_rfc,
                CHAR(1) AS ind_dir_empleo,
                CHAR(1) AS ind_domicilio,
                CHAR(1) AS ind_nacionalidad;
				
        DEFINE iSqlErr INT;
        DEFINE cCodRet CHAR(5);
        DEFINE cNumCliente CHAR(20);
        DEFINE cRfc CHAR(15);
        DEFINE cNombre1 CHAR(26);
        DEFINE cNombre2 CHAR(26);
        DEFINE cApPaterno CHAR(26);
        DEFINE cApMaterno CHAR(26);
        DEFINE cRazonSocial CHAR(60);
        DEFINE cNumCuenta CHAR(20);
        DEFINE cNumTarjeta CHAR(20);
        DEFINE cTipoPersona CHAR(2);
        DEFINE cTipoCliente CHAR(1);
        DEFINE cStatusBusq INT;
        DEFINE cDescStatusBusqueda CHAR(20);
        DEFINE iIdEncontrado INT;
        DEFINE iIdCte INT;
        DEFINE iRegistros INT;
        DEFINE cOmitido CHAR(1);
        DEFINE cBloqueado CHAR(1);
        DEFINE cTerminado CHAR(1);
        DEFINE cTipoCuenta CHAR(2);
        DEFINE cIndRfc CHAR(1);
        DEFINE cIndEmpleo CHAR(1);
        DEFINE cIndDomicilio CHAR(1);
        DEFINE cIndNacionalidad CHAR(1);
		
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cNumCliente = '';
        LET cRfc = '';
        LET cNombre1 = '';
        LET cNombre2 = '';
        LET cApPaterno = '';
        LET cApMaterno = '';
        LET cRazonSocial = '';
        LET cNumCuenta = '';
        LET cNumTarjeta = '';
        LET cTipoPersona = '';
        LET cTipoCliente = '';
        LET cStatusBusq = 0;
        LET cDescStatusBusqueda = '';
        LET iIdEncontrado = 0;
        LET iRegistros = 0;
        LET cOmitido = '';
        LET cBloqueado = '';
        LET cTerminado = '';
        LET iIdCte = 0;
        LET cTipoCuenta = '';
        LET cIndRfc = '';
        LET cIndEmpleo = '';
        LET cIndDomicilio = '';
        LET cIndNacionalidad = '';

        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                                cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                                cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                                cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                                cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                                cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                        END IF;
                END EXCEPTION;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                END IF;
                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                FOREACH
                        SELECT skip pNumRegistro FIRST pNumRecuperacion
                                        rp.numcte, rp.rfc, rp.nombre1, rp.nombre2, rp.apell_paterno, rp.apell_materno, rp.razon_social, rp.cuenta, rp.num_tarjeta, 
                                        rp.tipo_cliente, rp.status_busqueda, rp.ind_omitir, 
                                        nvl(rc.bloqueo_cuentas,'0'), 
                                        nvl(rc.ind_terminado,'0'), rp.id_busqueda, 
                                        nvl(rc.id_resulcte, 0),rp.tipo_cuenta, 
                                        nvl(rc.ind_rfc, '0'), 
                                        nvl(rc.ind_empleo, '0'), 
                                        nvl(rc.ind_domicilio, '0'),
                                        nvl(rc.ind_nacionalidad, '0')
                        INTO cNumCliente, cRfc, cNombre1, cNombre2, 
                                        cApPaterno, cApMaterno, cRazonSocial, cNumCuenta, 
                                        cNumTarjeta,cTipoCliente, cStatusBusq, cOmitido, 
                                        cBloqueado, cTerminado, iIdEncontrado, iIdCte, 
                                        cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad
                        FROM sw_ro_resulper rp LEFT JOIN sw_ro_resulcte rc 
                                        ON rc.id_busqueda = rp.id_busqueda 
                        WHERE rp.id_oficio = pIdOficio 
                        ORDER BY rp.id_resulper
            LET cTipoPersona = '';
            IF cTipoCliente in ('1', '2') THEN
                IF cRazonSocial = '' THEN
                    LET cTipoPersona = '01';
                ELSE
                    LET cTipoPersona = '02';
                END IF;
            END IF;
                        LET cDescStatusBusqueda = '';
                        IF cStatusBusq = 0 THEN
                                LET cDescStatusBusqueda = 'NO LOCALIZADO';
                        ELIF cStatusBusq = 1 THEN
                                LET cDescStatusBusqueda = 'LOCALIZADO';
                        ELIF cStatusBusq = 2 THEN
                                LET cDescStatusBusqueda = 'HOMONIMO';
                        END IF;
            RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
                                WITH resume;
                        LET iRegistros = iRegistros + 1;
                END FOREACH;
                IF iRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cNumCliente, cRfc, cNombre1, 
                                        cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
                                        cNumCuenta, cNumTarjeta, cTipoPersona, cTipoCliente, 
                                        cStatusBusq, cDescStatusBusqueda, cOmitido, cBloqueado, 
                                        cTerminado, iIdEncontrado, iIdCte, cTipoCuenta, 
                                        cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
                END IF; 
        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/10/2014',
'DESCRIPCION: Busqueda de un oficio, se elimina la busqueda de oficios por mac e ip';

create procedure "informix".sp_sw_ro_consnotas(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int)
	returning
		char(5) as codret,
		int as secuencia,
		char(255) as nota
	
	define cCodRet char(5);
	define iSqlErr int;
	define iNoRegistros int;
	define iSecuenciaNota int;
	define cNota char(255);
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iSecuenciaNota = 0;
	let cNota = '';
	let iNoRegistros = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iSecuenciaNota, cNota;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' then
			let cCodRet = '00003';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		foreach
			select id_notascte, nota
			into iSecuenciaNota, cNota
			from sw_ro_notascte
			where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and id_oficio = pIdOficio
			order by id_notascte
			
			let iNoRegistros = iNoRegistros + 1;
		
			return cCodRet, iSecuenciaNota, cNota with resume;
			
		end foreach;
		
		if iNoRegistros = 0 then
			let cCodRet = '01001';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
	end;
end procedure;