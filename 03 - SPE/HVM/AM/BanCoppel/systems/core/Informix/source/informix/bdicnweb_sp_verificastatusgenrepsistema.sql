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