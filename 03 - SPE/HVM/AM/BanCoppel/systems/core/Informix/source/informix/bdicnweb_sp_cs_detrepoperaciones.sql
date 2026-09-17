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