CREATE PROCEDURE "informix".sp_gs_busquedasolicitudes(pUsuario CHAR(8),pIdFuncion CHAR(10), pTipoGestor CHAR(1),pFechaDesde DATE, pFechaHasta DATE,
													  pTipoCta CHAR(2), pSolicitud INTEGER, pAreaResSol INTEGER, pUsuarioResSol CHAR(8), pStatus INTEGER,
													  pCliente CHAR(20),pCuenta CHAR(20),pIsArea CHAR(1),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idRegistroSolicitud,
			  DATE AS fechaSolicitud,
			  DATE AS fechaAtencion,
			  CHAR(20) AS folioSolicitud,
			  CHAR(2) AS idSistemaCuenta,
			  CHAR(10) AS idFuncionSolicitud,
			  CHAR(50) AS descripcionSolicitud,
			  CHAR(20) AS cliente, 
			  CHAR(20) AS cuenta,
			  CHAR(50) AS descripcionArea,
			  CHAR(8) AS numUsuario,
			  CHAR(45) AS nombre,
			  CHAR(50) AS descStatusSolicitud,
			  CHAR(50) AS descripcionMotivo,
			  INTEGER AS IdStatusSolicitud,
			  INTEGER AS idSolicitud,
			  CHAR(120) AS nombreCliente,
			  DECIMAL(16,2) AS monto,
			  CHAR(16) AS folioTransaccion,
			  CHAR(5) AS codError,
			  CHAR(100) AS descError,
			  CHAR(1) AS abreReporte,
			  CHAR(80) AS nombreReporte,
			  CHAR(8) AS numUsuarioRS,
			  CHAR(45) AS nombreRS;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistroSolicitud INTEGER;
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaAtencion DATE;
	DEFINE iFolioSolicitud CHAR(20);
	DEFINE cIdSistemaCuenta CHAR(2);
	DEFINE iIdFuncionSolicitud CHAR(10);
	DEFINE cDescripcionSolicitud CHAR(50);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cDescripcionArea CHAR(50);
	DEFINE cNumUsuario CHAR(8);
	DEFINE cNombre CHAR(45);
	DEFINE cDescStatusSolicitud CHAR(50);
	DEFINE cDescripcionMotivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdStatusSolicitud INTEGER;
	DEFINE iArea INTEGER;
	DEFINE iIdSolicitud INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cCmd2 CHAR(2500);
	DEFINE cNombreCliente CHAR(120);
	DEFINE dMonto DECIMAL(16,2);
	DEFINE cFolioTransaccion CHAR(16);
	DEFINE cCodError CHAR(5);
	DEFINE cDescError CHAR(100);
	DEFINE bAbreReporte CHAR(1);
	DEFINE cNombreReporte CHAR(80);
	DEFINE cNumUsuarioRS CHAR(8);
	DEFINE cNombreRS CHAR(45);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistroSolicitud = 0;
	LET dFechaSolicitud = NULL;
	LET dFechaAtencion = NULL;
	LET iFolioSolicitud = '';
	LET cIdSistemaCuenta = '';
	LET iIdFuncionSolicitud = '';
	LET cDescripcionSolicitud = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cDescripcionArea = '';
	LET cNumUsuario = '';
	LET cNombre = '';
	LET cDescStatusSolicitud = '';
	LET cDescripcionMotivo = '';
	LET iNoRegistros = 0;
	LET iIdStatusSolicitud = 0;
	LET iArea = 0;
	LET iIdSolicitud = 0;
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cNombreCliente = '';
	LET dMonto = 0;
	LET cFolioTransaccion = '';
	LET cCodError = '';
	LET cDescError = '';
	LET bAbreReporte = '';
	LET cNombreReporte = '';
	LET cNumUsuarioRS = '';
	LET cNombreRS = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,
				   bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_busquedasolicitudes.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoGestor = '' OR pFechaDesde = '' OR pFechaHasta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,
				   bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,
				   bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,
				   bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
		END IF;
				
		IF pTipoGestor = 'S' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:"informix".sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_solicitante = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_solicitante = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_responsable = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_responsable = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" id_registro_solicitud, fecha_solicitud, fecha_atencion, folio_solicitud, id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||" id_funcion,descripcion_solicitud, cliente, cuenta, descripcion_area, ejecutivo, nombre,";
			LET cCmd1=""||TRIM(cCmd1)||" desc_status_solicitud, descripcion_motivo, id_status_solicitud, id_solicitud, nombre_cliente, importe, folio_transaccion, cod_error, desc_error,";
			LET cCmd1=""||TRIM(cCmd1)||" abreReporte, nombre_reporte";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||"  c.id_funcion,c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo, a.id_status_solicitud,";
			LET cCmd1=""||TRIM(cCmd1)||"  a.id_solicitud, TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente, a.importe, a.folio_transaccion, ";
			LET cCmd1=""||TRIM(cCmd1)||"  a.cod_error, a.desc_error, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte ";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:'informix'.sw_gs_registrosolicitud a LEFT JOIN bdicnweb:'informix'.sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_cliente g ON g.numcte=a.cliente ";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||"  c.id_funcion,c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo, a.id_status_solicitud,";
			LET cCmd1=""||TRIM(cCmd1)||"  a.id_solicitud, TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente, a.importe, a.folio_transaccion, ";
			LET cCmd1=""||TRIM(cCmd1)||"  a.cod_error, a.desc_error, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte ";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:'informix'.sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:'informix'.sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_cliente g ON g.numcte=a.cliente ";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||") ORDER BY 1 DESC";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte;
			WHILE(SQLCODE == 0)	
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion, LPAD(TRIM(iFolioSolicitud),13, '0'),cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				       cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS  WITH RESUME;
					   	LET iNoRegistros = iNoRegistros + 1;
				FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
										iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
										iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte;
			END WHILE;
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				       cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,
					   cNumUsuarioRS,cNombreRS;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,
				   cNumUsuarioRS,cNombreRS;
		END IF;
				
		END IF;
	
		IF pTipoGestor = 'R' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:'informix'.sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_responsable = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_responsable = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_solicitante = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_solicitante = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" id_registro_solicitud, fecha_solicitud, fecha_atencion, folio_solicitud, id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||" id_funcion,descripcion_solicitud, cliente, cuenta, descripcion_area, ejecutivo, nombre,";
			LET cCmd1=""||TRIM(cCmd1)||" desc_status_solicitud, descripcion_motivo, id_status_solicitud, id_solicitud, nombre_cliente, importe, folio_transaccion, cod_error, desc_error,";
			LET cCmd1=""||TRIM(cCmd1)||" abreReporte, nombre_reporte, ejecutivoRS, nombreEjecutivoRS ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||"  c.id_funcion,c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo, a.id_status_solicitud,";
			LET cCmd1=""||TRIM(cCmd1)||"  a.id_solicitud, TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente, a.importe, a.folio_transaccion, ";
			LET cCmd1=""||TRIM(cCmd1)||"  a.cod_error, a.desc_error, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte,h.ejecutivo as ejecutivoRS, h.nombre as nombreEjecutivoRS ";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM ((((((bdicnweb:'informix'.sw_gs_registrosolicitud a LEFT JOIN bdicnweb:'informix'.sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_cliente g ON g.numcte=a.cliente)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut h ON h.ejecutivo=a.usuario_responsable ";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||"  c.id_funcion,c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo, a.id_status_solicitud,";
			LET cCmd1=""||TRIM(cCmd1)||"  a.id_solicitud, TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente, a.importe, a.folio_transaccion, ";
			LET cCmd1=""||TRIM(cCmd1)||"  a.cod_error, a.desc_error, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte,h.ejecutivo as ejecutivoRS, h.nombre as nombreEjecutivoRS ";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM ((((((bdicnweb:'informix'.sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:'informix'.sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:'informix'.sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_cliente g ON g.numcte=a.cliente)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:'informix'.si_ejecut h ON h.ejecutivo=a.usuario_responsable ";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||") ORDER BY 1 DESC";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
			WHILE(SQLCODE == 0)	
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,LPAD(TRIM(iFolioSolicitud),13, '0'),cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				       cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS WITH RESUME;
					   	LET iNoRegistros = iNoRegistros + 1;
				FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
										iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
										iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,cNumUsuarioRS,cNombreRS;
			END WHILE;
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				       cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,
					   cNumUsuarioRS,cNombreRS;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,dMonto,cFolioTransaccion,cCodError,cDescError,bAbreReporte,cNombreReporte,
				   cNumUsuarioRS,cNombreRS;
		END IF;
				
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 09/06/2014',
'DESCRIPCION: busqueda de solicitudes para gestor de operaciones en SOCWEB ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cuentadoctosfusioncte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroCliente CHAR(20),pTipo_cte SMALLINT)
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS cDescripcion;
	--DECLARACION DE VARIABLES	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	DEFINE isam_err  INT;
	DEFINE cDescripcion  CHAR(100);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET isam_err="0";
	LET cDescripcion="";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cuentadoctosfusioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNumeroCliente = '' OR pTipo_cte IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescripcion;
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescripcion;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cuentadoctos(pNumeroCliente, pTipo_cte)
		INTO cCodRetSp, isam_err, cDescripcion;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cuentadoctos';
		ELIF iCodRetSp = 100 THEN --CLIENTE PERSONA MORAL
			LET cCodRet = '00354';
			RETURN cCodRet, cDescripcion;
		ELIF iCodRetSp = 200 THEN --CLIENTE CON ADEUDO EN IDE, IMPOSIBLE REALIZAR TRASPASO DE CUENTAS
			LET cCodRet = '00355';
			RETURN cCodRet, cDescripcion;
		ELIF iCodRetSp = 300 THEN
			LET cCodRet = '00356'; --CLIENTE CON BANCA ELECTRONICA AVANZADA
			RETURN cCodRet, cDescripcion;
		ELIF iCodRetSp = 400 THEN
			LET cCodRet = '00357';  --CLIENTE FUSIONADO
			RETURN cCodRet, cDescripcion;
		END IF;
		
		RETURN cCodRet, cDescripcion;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 15/07/2014',
'DESCRIPCION: validacion cliente: persona moral, adeudo en ide, banca electronica avanzada, cliente fusionado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dgconsultapendientesenvio(pEmpresa CHAR(3),pCtlProcesado CHAR(1),pCtlLigado CHAR(1),pMacaddressLocal CHAR(17),pNumRegistro INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(6),INTEGER,CHAR(20),CHAR(20),CHAR(4),CHAR(4),INTEGER,CHAR(40),CHAR(25),CHAR(50),CHAR(1),CHAR(1),CHAR(1),
	          CHAR(150),CHAR(8),CHAR(35),CHAR(30);

	--DECLARACION DE VARIABLES
		DEFINE cEmpresa		    	CHAR(3);
		DEFINE iSqlErr              INTEGER;
		DEFINE cCodRet              CHAR(6);
		DEFINE iIdControl       	INTEGER ;
		DEFINE cCliente    			CHAR(20);
		DEFINE cCuenta 				CHAR(20);
		DEFINE cProducto 			CHAR(4);
		DEFINE cCodDocto 			CHAR(4);
		DEFINE iSecuencia 			INTEGER;
		DEFINE cProdNombre 			CHAR(40);
		DEFINE vCtlArchivoLocal 	CHAR(25);
		DEFINE vCtlArchivoZip 		CHAR(50);
		DEFINE cCtlImgEnviada 		CHAR(1);
		DEFINE cCtlProcesado 		CHAR(1);
		DEFINE cCtlLigado 			CHAR(1);
		DEFINE vCtlArchivoLocalRuta CHAR(150);
		DEFINE cUsuarioAlta  		CHAR(8);
		DEFINE vDescripcion 		CHAR(35);
		DEFINE cDescrip2 			CHAR(30);

	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/SP_dgConsultaPendientesEnvio.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
		LET	iIdControl= 0;
		LET	cCliente= '';
		LET	cCuenta= '';
		LET	cProducto= '';
		LET	cCodDocto= '';
		LET	iSecuencia= 0;
		LET	cProdNombre= '';
		LET	vCtlArchivoLocal= '';
		LET	vCtlArchivoZip= '';
		LET	cCtlImgEnviada= '';
		LET	cCtlProcesado= '';
		LET	cCtlLigado= '';
		LET	vCtlArchivoLocalRuta= '';
		LET	cUsuarioAlta= '';
		LET	vDescripcion= '';
		LET	cDescrip2= '';

	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
			END IF;
		END EXCEPTION;

        set isolation to dirty read;
		
        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

        IF pCtlProcesado = '' THEN
            LET cCodRet = '000002'; -- PARAMETRO CTL_PROCESADO VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

		IF pCtlLigado = '' THEN
            LET cCodRet = '000003'; -- PARAMETRO CTL_LIGADO VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

		IF pMacaddressLocal = '' THEN
            LET cCodRet = '000004'; -- PARAMETRO MACADDRESS_LOCAL VIENE VACIO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;


        IF pCtlProcesado <> 1 AND pCtlProcesado <> 0 THEN
            LET cCodRet = '000005'; -- PARAMETRO CTL_PROCESADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

		IF pCtlLigado <> 1 AND pCtlLigado <> 0 THEN
            LET cCodRet = '000006'; -- PARAMETRO CTL_LIGADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

        IF LENGTH(pCtlProcesado) <> 1 THEN
            LET cCodRet = '000007'; -- PARAMETRO CTL_PROCESADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

		IF LENGTH(pCtlLigado) <> 1 THEN
            LET cCodRet = '000008'; -- PARAMETRO CTL_LIGADO NO VALIDO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

		IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;			
		ELSE
			IF pRecuperacion<=0 THEN
			   LET cCodRet='00098';
			   RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
			END IF;
		END IF;       


        SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;

        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000009'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
        END IF;

        --OBTENGO LOS DOCUMENTOS PENDIENTES DE ENVIAR
	    FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion d.id_control,d.cliente,d.cuenta,d.producto,d.cod_docto,d.secuencia,d.prod_nombre,
					d.ctl_archivo_local,d.ctl_archivo_zip,d.ctl_img_enviada,d.ctl_procesado,d.ctl_ligado,
					d.ctl_archivo_local_ruta,d.usuario_alta,t.descripcion,d.descrip2
			INTO iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
					vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,
					vDescripcion,cDescrip2
			FROM BDIDIGITAL:dg_expediente_envio d INNER JOIN BDIDIGITAL@COPPELIMG_TCP:dg_tipodocumento t ON (d.cod_docto = t.cod_docto)
			WHERE d.empresa = pEmpresa
				AND  d.ctl_procesado = pCtlProcesado
				AND d.ctl_ligado = pCtlLigado
				AND d.macaddress_local = pMacaddressLocal --'" & strMacLocal & "'
			ORDER BY 1

           RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,
					   vDescripcion,cDescrip2 WITH resume;
		END FOREACH

		IF iIdControl='' OR iIdControl IS NULL THEN
	            LET cCodRet = '000010';				RETURN cCodRet,iIdControl,cCliente,cCuenta,cProducto,cCodDocto,iSecuencia,cProdNombre,vCtlArchivoLocal,
				       vCtlArchivoZip,cCtlImgEnviada,cCtlProcesado,cCtlLigado,vCtlArchivoLocalRuta,cUsuarioAlta,vDescripcion,cDescrip2;
	    END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas dg_expediente_envio,dg_tipodocumento',
'tomando como parametro o dato de entrada, la Empresa, CtlProcesado, CtlLigado y MacaddressLocal',
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2010',
'VERSION: 201004',
'BD: BDIDIGITAL';

CREATE PROCEDURE "informix".sp_gs_consultasolicitudusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdAreaUsuario INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area_solicitud,
				CHAR(2) AS sistema_suenta,
				CHAR(30) AS desc_sistema_cuenta,
				INTEGER AS id_solicitud,
				CHAR(50) AS desc_solicitud,
				CHAR(1) AS ind_responsable,
				CHAR(1) AS ind_solicitante;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdAreaSolicitud INTEGER;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescSistemaCuenta CHAR(30);
	DEFINE iIdSolicitud INTEGER;
	DEFINE cDescSolicitud CHAR(50);
	DEFINE cIndResponsable CHAR(1);
	DEFINE cIndSolicitante CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdAreaSolicitud = 0;
	LET cSistemaCuenta = '';
	LET cDescSistemaCuenta = '';
	LET iIdSolicitud = '';
	LET cDescSolicitud = '';
	LET cIndResponsable = '';
	LET cIndSolicitante = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultasolicitudusuarioarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdAreaUsuario IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area_solicitud, c.id_sistema_cuenta, c.descripcion_sistema_cuenta, b.id_solicitud, b.descripcion_solicitud,
				DECODE(a.ind_responsable, 'f', '0', 't', '1', '0') as es_responsable, DECODE(a.ind_solicitante, 'f', '0', 't', '1', '0') as es_solicitante
			INTO iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante
			FROM "informix".sw_gs_area_solicitudes a, "informix".sw_gs_solicitudes b, "informix".sw_gs_sistema_cuenta c
			WHERE id_area_usuario = pIdAreaUsuario and a.status = 't'
				AND b.id_solicitud = a.id_solicitud
				AND c.id_sistema_cuenta = b.id_sistema_cuenta
			
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante WITH RESUME;			
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/05/2014',
'DESCRIPCION: Consulta el detalle de area/solicitud asiganada a un usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pIdx INTEGER, pIdUsuarioC CHAR(8), pIdArea INTEGER, pJefeArea CHAR(1), pStatus CHAR(1), pIpUsuario CHAR(15), pMacUsuario CHAR(12))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS registro_afectados;
				  
	DEFINE cCodRet CHAR(5);
	DEFINE registro_afectados INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE iIdx INTEGER;
	
	LET cCodRet = '00000';
	LET registro_afectados = 0;
	LET iSqlErr = 0;
	LET iIdx = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, registro_afectados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_gs_area_usuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pIdUsuarioC = '' OR pIdArea IS NULL OR pJefeArea = '' OR pStatus = '' OR pIpUsuario = '' OR pMacUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		IF pTipoOperacion = 2 AND pIdx IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, registro_afectados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pTipoOperacion = 1 THEN
			IF EXISTS (SELECT id_area FROM bdicnweb:"informix".sw_gs_area_usuario WHERE id_usuario = pIdUsuarioC) THEN
				LET cCodRet = '00004';
				RETURN cCodRet, registro_afectados;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_gs_area_usuario(id_usuario, id_area, jefe_area, status, user_insert, ip_insert, mac_insert)
				VALUES(pIdUsuarioC, pIdArea, DECODE(pJefeArea, '0', 'f', '1', 't', 'f'), DECODE(pStatus, '0', 'f', '1', 't', 'f'), pUsuario, pIpUsuario, pMacUsuario);
				
				LET registro_afectados = DBINFO('sqlca.sqlerrd2');
				IF registro_afectados = 1 THEN
					LET iIdx = DBINFO('sqlca.sqlerrd1');
				END IF;
				
				RETURN cCodRet, iIdx;

			END IF;
		END IF;
		
		IF pTipoOperacion = 2 THEN
		
			IF NOT EXISTS (SELECT id_area_usuario FROM bdicnweb:"informix".sw_gs_area_usuario WHERE id_area_usuario = pIdx) THEN
				LET cCodRet = '00001';
				RETURN cCodRet, registro_afectados;
			ELSE
				UPDATE bdicnweb:"informix".sw_gs_area_usuario
				SET id_usuario = pIdUsuarioC, 
					id_area = pIdArea, 
					jefe_area = DECODE(pJefeArea, '0', 'f', '1', 't', 'f'),
					status = DECODE(pStatus, '0', 'f', '1', 't', 'f'),
					user_update= pUsuario,
					ip_update= pIpUsuario,
					mac_update = pMacUsuario
				WHERE id_area_usuario = pIdx;
				--WHERE id_usuario = pIdUsuarioC 
				--  AND id_area = pIdArea;	
				
				LET registro_afectados = DBINFO('sqlca.sqlerrd2');
				RETURN cCodRet, registro_afectados;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 16/05/2014',
'DESCRIPCION: inserta o actualiza el area de usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_evc_borra_repetidosexcluir(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))

RETURNING CHAR(5) AS codret;
-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);
DEFINE iSqlErr INT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "00000";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";
LET iSqlErr = 0;

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

	IF trim(cCodRet) <> "00000" THEN
		RETURN trim(cCodRet);
	END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

----SET DEBUG FILE TO "/informix/marcov/sp_evc_borra_repetidosexcluir.out";
----TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	IF (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} 
		COUNT(*)
		from bdicnweb:"informix".sw_evc_excluidos
		where id_registro 
		not in (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)}  max(id_registro)
						from bdicnweb:"informix".sw_evc_excluidos group by cuenta) 
		and status <> 'P')
		>= 1 THEN

		DELETE {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)}
		FROM bdicnweb:"informix".sw_evc_excluidos
		WHERE id_registro
		NOT IN(SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)} MAX(id_registro)
						FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta)
		AND status <> 'P';
	END IF;
 
RETURN trim(cCodRet);
END;
 
END PROCEDURE;