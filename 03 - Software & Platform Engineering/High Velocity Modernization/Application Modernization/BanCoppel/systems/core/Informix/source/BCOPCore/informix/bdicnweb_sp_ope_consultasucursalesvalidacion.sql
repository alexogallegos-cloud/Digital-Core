CREATE PROCEDURE "informix".sp_ope_consultasucursalesvalidacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFuncionalidad CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(4) AS sucursal;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSucursal = '001';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultasucursalesvalidacion.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFuncionalidad= '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;

			FOREACH		
				SELECT SKIP pRegistros FIRST pRecuperacion numsucursal
				INTO cSucursal
				FROM "informix".sw_ope_validacionsucursalmeta
				WHERE usuario = pUsuario
				AND funcionalidad = pFuncionalidad
		
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cSucursal WITH RESUME;
			END FOREACH;
		
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, cSucursal;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cSucursal;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que recupera las sucursales que no existen en la tabla mi_sucursalesinfo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultatiposucursalmetas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(5) AS tipo_sucursal;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE ctipoSucursal CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET ctipoSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, ctipoSucursal;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultatiposucursalmetas.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, ctipoSucursal;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, ctipoSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, ctipoSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		
		FOREACH		
				SELECT SKIP pRegistros FIRST pRecuperacion tipo_sucursal
				INTO ctipoSucursal
				FROM bdmis:"informix".mi_tiposuc_mis WHERE empresa = cEmpresa
				ORDER BY 1 ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, ctipoSucursal WITH RESUME;
				
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, ctipoSucursal;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, ctipoSucursal;
		END IF;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 10/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Metas Productos',
'DESCRIPCION: Procedimiento que obtiene la informacion para realizar el llenado del combo tipo sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_eliminamovimientosmetas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegElim CHAR(500))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdConRegistro INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdConRegistro = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_eliminamovimientosmetas.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegElim = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pRegElim, '|')
				INTO iIdConRegistro
				
				DELETE FROM bdmis:"informix".mi_movimientosmetas WHERE id = iIdConRegistro;
		END FOREACH;
		
		RETURN cCodRet;		
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Consulta Movimientos',
'DESCRIPCION: Procedimiento que elimina los datos de la funcionalidad Consulta Movimientos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_guardametaproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSuc INTEGER , pMeta DECIMAL(16,2), pAnioMes CHAR(6), pProducto CHAR(4),pDescripcion CHAR(40))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(45);
	DEFINE iNoRegistroBitacora INTEGER;
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCambio CHAR(500);
	DEFINE cMovimiento CHAR(500);
	DEFINE cCambioBitacora CHAR(500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET iNoRegistroBitacora = 0;
	LET iIdRegistroBitacora = 0;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	LET cCambio = "";
	LET cMovimiento = "";
	LET cCambioBitacora = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_guardametaproducto.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSuc IS NULL OR pMeta IS NULL  OR pAnioMes = '' OR pProducto = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(*) 
		INTO iNoRegistros
		FROM bdmis:"informix".mi_movimientosmetas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistro
			FROM bdmis:"informix".mi_movimientosmetas;
			
			LET iIdRegistro = iIdRegistro + 1;
		END IF;
		
		
		SELECT COUNT(*) 
		INTO iNoRegistroBitacora
		FROM bdmis:"informix".mi_bitacora_metas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
			
			LET iIdRegistroBitacora = iIdRegistroBitacora + 1;
		END IF;		
		
		SELECT nombre
		INTO cNombre
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo= pUsuario;
		
		SET LOCK MODE TO WAIT 3;
		
		LET cCambio = "Actividad realizada: update  bdmis:mi_metasprod set metanum = *" || pMeta || "* where id_tiposuc = *" || pTipoSuc || "* and producto = *" || pProducto || "* and aniomes = *" || pAnioMes || "*";
		LET cMovimiento = "Actualización de Meta, Modulo Metas Mantenimiento, Producto: " || pDescripcion || ", Meta: " || pMeta || ", Año/Mes: " || pAnioMes || ", Tipo de Sucursal = " || pTipoSuc;
		LET cCambioBitacora = "Actividad realizada: update bdmis:mi_metasprod set metanum = " || pMeta ||  " where id_tiposuc = " || pTipoSuc || " and producto = " || pProducto || " and aniomes = " || pAnioMes;
		IF EXISTS (SELECT * FROM bdmis:"informix".mi_movimientosmetas WHERE cambio = cCambio) THEN
			LET cCodRet = "00980";
		ELSE
		
		INSERT INTO bdmis:"informix".mi_movimientosmetas(id, empleado, nombre, fecha, hora, cambio, movimiento) 
		VALUES(iIdRegistro, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambio, cMovimiento);
		
		INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
		VALUES(iIdRegistroBitacora, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
		
		END IF;
		 
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Metas Productos',
'DESCRIPCION: Procedimiento que almacena los cambios generados en la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_guardatiposucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSuc INTEGER, pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombre CHAR(45);
	DEFINE iNoRegistroBitacora INTEGER;
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCambio CHAR(500);
	DEFINE cMovimiento CHAR(500);
	DEFINE cCambioBitacora CHAR(500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET iNoRegistroBitacora = 0;
	LET iIdRegistroBitacora = 0;
	LET iNoRegistros = 0;
	LET iIdRegistro = 0;
	LET cCambio = "";
	LET cMovimiento = "";
	LET cCambioBitacora = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_guardatiposucursal.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pTipoSuc IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(*) 
		INTO iNoRegistros
		FROM bdmis:"informix".mi_movimientosmetas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistro
			FROM bdmis:"informix".mi_movimientosmetas;
			
			LET iIdRegistro = iIdRegistro + 1;
		END IF;
		
		
		SELECT COUNT(*) 
		INTO iNoRegistroBitacora
		FROM bdmis:"informix".mi_bitacora_metas;
		
		IF iNoRegistros = 0 THEN
			LET iIdRegistro = 1;
		ELSE
			SELECT MAX(id) 
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
			
			LET iIdRegistroBitacora = iIdRegistroBitacora + 1;
		END IF;		
		
		SELECT nombre
		INTO cNombre
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo= pUsuario;
		
		SET LOCK MODE TO WAIT 3;
		
		LET cCambio = "Actividad realizada: update bdmis:mi_sucursalesinfo set tipo_suc = *" || pTipoSuc || "* where num_sucursal = *" || pSucursal || "*";
		LET cMovimiento = "Actualización Modulo Mantenimiento Tipo Sucursal, Sucursal: " || pSucursal || ", Tipo de Sucursal = " || pTipoSuc;
		LET cCambioBitacora = "Actividad realizada: update bdmis:mi_sucursalesinfo set tipo_suc = " || pTipoSuc || " where num_sucursal = " || pSucursal;
		IF EXISTS (SELECT * FROM bdmis:"informix".mi_movimientosmetas WHERE cambio = cCambio) THEN
			LET cCodRet = "00980";
		ELSE
		
		INSERT INTO bdmis:"informix".mi_movimientosmetas(id, empleado, nombre, fecha, hora, cambio, movimiento) 
		VALUES(iIdRegistro, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambio, cMovimiento);
		
		INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
		VALUES(iIdRegistroBitacora, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
		
		END IF;
		 
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que realiza el cambio a las sucursales ',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 20/06/2017',
'DESCRIPCION: Se corrige el codigo de retorno del spl cuando el valor ya fue asignado con anterioridad ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_insertasolicitudtdcmasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArch CHAR(100))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE dMeta_Diaria DECIMAL(3,2);
	DEFINE cNombre CHAR(45);
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE cCambioBitacora CHAR(500);
	DEFINE cNombreSucursal CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSucursal = '';
	LET dMeta_Diaria = 0.0;
	LET cNombre = '';
	LET iIdRegistroBitacora = 0;
	LET cCambioBitacora = "";
	LET cNombreSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_insertasolicitudtdcmasivo.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArch = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".sw_ope_bitacoraerrorescargarchivo WHERE noejecutivo = pUsuario AND funcionalidad	= 'Solicitud TDC';
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
		
			SELECT numsucursal, nomsucursal, meta
			INTO cSucursal, cNombreSucursal, dMeta_Diaria
			FROM "informix".sw_ope_cargarchivosolicitudtdc
			WHERE noejecutivo = pUsuario
			
			
			SELECT NVL(MAX(id),0)  + 1
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
					
		
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo= pUsuario;
		
			
		
			LET cCambioBitacora = "Actividad realizada: insert into bdmis:mi_metascoppel (fecha, sucursal, producto, meta_diaria, usuario) values (" || TO_CHAR(CURRENT, '%m/%d/%Y') || ", " || cSucursal || ", 6500, " || dMeta_Diaria||", " || pUsuario || ")";
			IF (SELECT COUNT(*) FROM bdmis:"informix".mi_metascoppel WHERE fecha = TODAY AND sucursal = cSucursal AND producto = '6500') > 0 THEN

				UPDATE bdmis:"informix".mi_metascoppel SET
				meta_diaria = dMeta_Diaria,
				usuario = pUsuario
				WHERE fecha = TODAY AND sucursal = cSucursal AND producto = '6500'; 
				
				INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
				VALUES(iIdRegistroBitacora, pUsuario, cNombre, TODAY, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
				
			ELSE
		
				INSERT INTO bdmis:"informix".mi_metascoppel(fecha, sucursal, producto, meta_diaria, usuario) 
				VALUES(TODAY, cSucursal, '6500',dMeta_Diaria, pUsuario);
		
				INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
				VALUES(iIdRegistroBitacora, pUsuario, cNombre, TODAY, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
				
			END IF;

		END FOREACH;
		
		IF (SELECT COUNT(*) FROM "informix".sw_ope_nombrearchivosmetasolicitudtdc WHERE fechacarga = TODAY AND nombrearchivo = pNombreArch) = 0 THEN
			INSERT INTO "informix".sw_ope_nombrearchivosmetasolicitudtdc(fechacarga, nombrearchivo) 
			VALUES(TODAY, pNombreArch);
		END IF;
		
		RETURN cCodRet;		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Meta Solicitud TDC',
'DESCRIPCION: Procedimiento que realiza el guardado de la informacion en la tabla meta coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_insertatiposucursalmasivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cTipoSuc CHAR(2);
	DEFINE cNombre CHAR(45);
	DEFINE iIdRegistroBitacora INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cCambio CHAR(500);
	DEFINE cMovimiento CHAR(500);
	DEFINE cCambioBitacora CHAR(500);
	DEFINE cNombreSucursal CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSucursal = '';
	LET cTipoSuc = '';
	LET cNombre = '';
	LET iIdRegistroBitacora = 0;
	LET iIdRegistro = 0;
	LET cCambio = "";
	LET cMovimiento = "";
	LET cCambioBitacora = "";
	LET cNombreSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_insertatiposucursalmasivo.out';
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
		
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".sw_ope_bitacoraerrorescargarchivo WHERE noejecutivo = pUsuario AND funcionalidad	= 'Tipo Sucursal';
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH 
			SELECT numsucursal, nomsucursal, tiposucursal
			INTO cSucursal, cNombreSucursal, cTipoSuc
			FROM "informix".sw_ope_cargarchivotiopsolicitud
			WHERE noejecutivo = pUsuario

			SELECT NVL(MAX(id),0) + 1 
			INTO iIdRegistro
			FROM bdmis:"informix".mi_movimientosmetas;
			
			SELECT NVL(MAX(id),0) + 1
			INTO iIdRegistroBitacora
			FROM bdmis:"informix".mi_bitacora_metas;
		
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo= pUsuario;
		
			
		
			LET cCambio = "Actividad realizada: update bdmis:mi_sucursalesinfo set tipo_suc = *" || cTipoSuc || "* where num_sucursal = *" || cSucursal || "*";
			LET cMovimiento = "Actualización Modulo Mantenimiento Tipo Sucursal, Sucursal: " || cSucursal || ", Tipo de Sucursal = " || cTipoSuc;
			LET cCambioBitacora = "Actividad realizada: update bdmis:mi_sucursalesinfo set tipo_suc = " || cTipoSuc || " where num_sucursal = " || cSucursal;
			IF (SELECT COUNT(*) FROM bdmis:"informix".mi_movimientosmetas WHERE cambio = cCambio) > 0 THEN
				INSERT INTO "informix".sw_ope_bitacoraerrorescargarchivo(numsucursal, nomsucursal, descmensaje, noejecutivo, funcionalidad) 
				VALUES(cSucursal,cNombreSucursal, 'El valor asignado ya fue programado anteriormente', pUsuario, 'Tipo Sucursal');
			ELSE
		
				INSERT INTO bdmis:"informix".mi_movimientosmetas(id, empleado, nombre, fecha, hora, cambio, movimiento) 
				VALUES(iIdRegistro, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambio, cMovimiento);
		
				INSERT INTO bdmis:"informix".mi_bitacora_metas(id, empleado, nombre, fecha, hora, cambio) 
				VALUES(iIdRegistroBitacora, pUsuario, cNombre, CURRENT, TO_CHAR(CURRENT, '%H:%M:%S'), cCambioBitacora);
			END IF;
			
		END FOREACH;

		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que realiza la inserción masiva de Tipo de Sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_obtienefuncionalidadesmetas(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER   AS id_catalogo,
				CHAR(10)  AS funcion,
				CHAR(100)  AS catalogo,
				INTEGER   AS submodulo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdCatalogo INTEGER;
	DEFINE idFuncion CHAR(10);
	DEFINE cDescCatalogo CHAR(100);
	DEFINE idSubmodulo INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdCatalogo = 0;
	LET cDescCatalogo = '';
	LET iNoRegistros = 0;
	LET idFuncion = '';
	LET idSubmodulo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienefuncionalidadesmetas.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH 
			SELECT a.id_operacion, a.id_funcion,a.funcionalidad,b.id_submodulo
			INTO iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo
			FROM bdicnweb:"informix".sw_ope_catalogometafunciones AS a
			INNER JOIN bdinteg:"informix".si_seg_funciones AS b ON a.id_funcion= b.id_funcion
			WHERE a.id_funcion IN (
								SELECT a.id_funcion
								FROM bdinteg:"informix".si_seg_usuarios_funciones a, bdinteg:"informix".si_seg_funciones b
								WHERE id_usuario = pUsuario
								AND a.id_funcion[1, 3] =  'MET'
								AND a.status = '1'
								AND b.id_funcion = a.id_funcion
								AND b.id_submodulo = 54)
			ORDER BY a.id_operacion ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00749';
			RETURN cCodRet, iIdCatalogo, idFuncion, cDescCatalogo, idSubmodulo;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 08/05/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Contenedor Metas',
'DESCRIPCION: Consulta las funcionalidades a las que tiene permiso el usuario, y realiza el llenado del combo para seleccionar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cargarchivosolicitudtdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistrosMas CHAR(500), pIteracion CHAR(1))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMeta_Diaria DECIMAL(3,2);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE cRegistro LVARCHAR;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iInicioReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cMeta_Diaria = 0.0;
	LET cSucursal = '';
	LET cNombreSucursal = '';
	LET cRegistro = '';
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iInicioReg = 1;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cargarchivosolicitudtdc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistrosMas = '' OR pIteracion = '' THEN
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
		
		IF pIteracion = '0' THEN
			DELETE FROM "informix".sw_ope_cargarchivosolicitudtdc 
			WHERE noejecutivo = pUsuario;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pRegistrosMas, '|')
			INTO cRegistro
			
			LET iTamReg = LENGTH(TRIM(cRegistro));
			LET iPosCaracter = INSTR(cRegistro, ",");
			LET cSucursal = SUBSTR(TRIM(cRegistro), iInicioReg, (iPosCaracter - 1));
			LET cMeta_Diaria = SUBSTR(TRIM(cRegistro), (iPosCaracter + 1), (iTamReg - iPosCaracter));
		
			SELECT nombre
			INTO cNombreSucursal
			FROM bdmis:"informix".mi_sucursalesinfo
			WHERE num_sucursal = cSucursal;
			
			INSERT INTO "informix".sw_ope_cargarchivosolicitudtdc(numsucursal, nomsucursal, meta, noejecutivo) 
			VALUES(cSucursal, cNombreSucursal, cMeta_Diaria, pUsuario);

		END FOREACH;
	
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Meta Solicitud TDC',
'DESCRIPCION: Procedimiento que realiza la inserción masiva de metas Solicitud TDC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cargarchivotiposucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistrosMas CHAR(350), pIteracion CHAR(1))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipoSucursal CHAR(2);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE cRegistro LVARCHAR;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iInicioReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipoSucursal = '';
	LET cSucursal = '';
	LET cNombreSucursal = '';
	LET cRegistro = '';
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iInicioReg = 1;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cargarchivotiposucursal.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistrosMas = '' OR pIteracion = '' THEN
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
		
		IF pIteracion = '0' THEN
			DELETE FROM "informix".sw_ope_cargarchivotiopsolicitud WHERE noejecutivo = pUsuario;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pRegistrosMas, '|')
			INTO cRegistro
			
			LET iTamReg = LENGTH(TRIM(cRegistro));
			LET iPosCaracter = INSTR(cRegistro, ",");
			LET cSucursal = SUBSTR(TRIM(cRegistro), iInicioReg, (iPosCaracter - 1));
			LET cTipoSucursal = SUBSTR(TRIM(cRegistro), (iPosCaracter + 1), (iTamReg - iPosCaracter));
		
			SELECT nombre
			INTO cNombreSucursal
			FROM bdmis:"informix".mi_sucursalesinfo
			WHERE num_sucursal = cSucursal;
			
			INSERT INTO "informix".sw_ope_cargarchivotiopsolicitud(numsucursal, nomsucursal, tiposucursal, noejecutivo) 
			VALUES(cSucursal, cNombreSucursal, cTipoSucursal, pUsuario);

		END FOREACH;
	
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 18/05/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Mantenimiento Tipo Sucursal',
'DESCRIPCION: Procedimiento que realiza la insercion del archivo que se carga',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatalogorigenaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS origen,
			CHAR(40) AS desc_origen;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cOrigen CHAR(2);
	DEFINE cDescOrigen CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET cOrigen = '';
	LET cDescOrigen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cOrigen, cDescOrigen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogorigenaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cOrigen, cDescOrigen;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cOrigen, cDescOrigen;
		END IF;	
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultar_origen_aumlincred() 
			INTO  cCodRetSp, cMensajeRetorno, cOrigen, cDescOrigen
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultar_origen_aumlincred';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cOrigen, cDescOrigen;
			END IF;
			
			RETURN cCodRet, cOrigen, UPPER(cDescOrigen) WITH RESUME;
			
		END FOREACH;
	
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/03/2014',
'DESCRIPCION: Consulta el catalogo de origenes de los incrementos para aumento y disminucion de lineas de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogostatusaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
                  CHAR(2) AS status,
                  CHAR(40) AS descripcionStatus; 
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE mensajeRetorno CHAR(80);
	DEFINE status CHAR(2);
	DEFINE cDescripcionStatus CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET mensajeRetorno = '';
	LET status = '';
	LET cDescripcionStatus = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, status, cDescripcionStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/rptLineas/sp_catalogostatusaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, status, cDescripcionStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, status, cDescripcionStatus;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultar_status_aumlincred()
			INTO cCodRetSp, mensajeRetorno, status, cDescripcionStatus
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultar_status_aumlincred';
			END IF;
			
			RETURN cCodRet, status, cDescripcionStatus  WITH RESUME; 
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2')= 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, status, cDescripcionStatus; 
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/09/2014',
'DESCRIPCION: Llena el combo estatus para los reportes de incrementos de lineas de crÃ©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoexcepcionesaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(4) AS cClaveExcepcion,
				  CHAR(80) AS cDescripcionExcepcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cClaveExcepcion CHAR(4);
	DEFINE cDescripcionExcepcion CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET cClaveExcepcion = '';
	LET cDescripcionExcepcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveExcepcion, cDescripcionExcepcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoexcepcionesaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveExcepcion, cDescripcionExcepcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveExcepcion, cDescripcionExcepcion;
		END IF;
		
		FOREACH	EXECUTE PROCEDURE bdicred:'informix'.sp_consultar_excepciones_aumlincred()
			INTO cCodRetSp, cMensajeRetorno, cClaveExcepcion, cDescripcionExcepcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultar_excepciones_aumlincred';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00017';
			END IF;
			RETURN cCodRet, cClaveExcepcion, cDescripcionExcepcion WITH RESUME;
		END FOREACH;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/09/2014',
'DESCRIPCION: Llenado de combo de Excepciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".eliminasolicusuariomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(10))
RETURNING
        CHAR(5) AS COD_RET,
        CHAR(80) AS DESCRIPCION; 
    
        ---DECLARACIONES
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cErrorInfo   CHAR(80);
    DEFINE cCodRet      CHAR(6);
    DEFINE cMensajeRet  CHAR(80);
        ---INICIALIZACIONES
    LET iSqlErr       = 0;
    LET iIsamErr      = 0;
    LET cErrorInfo    = '';
    LET cCodRet       = '00000';
    LET cMensajeRet   = '';
BEGIN

   ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cMensajeRet;
        END EXCEPTION;
        
    IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cMensajeRet;
        END IF;   
        
        EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cMensajeRet;
        END IF;
        
        DELETE FROM  bdisolic:"informix".ss_cte_procesando WHERE usuario = pEjecutivo;
         
        LET cMensajeRet = 'Proceso Exitoso';                                    
        RETURN cCodRet, cMensajeRet;
END
END PROCEDURE

DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 11/09/2015',
'DESCRIPCION: procedimiento para desbloquear las solicitudes en proceso de analisis por un ejecutivo de mesa de control',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_asigna_aut_solicitud_mc(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2))
		RETURNING CHAR(5) AS codret,
				  CHAR(21) AS numSolicitud,
				  CHAR(21) AS numCliente;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumSolicitud CHAR(21);
	DEFINE cNumCliente CHAR(21);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumSolicitud = '';
	LET cNumCliente = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumSolicitud,cNumCliente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_asigna_aut_solicitud_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumSolicitud,cNumCliente;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumSolicitud,cNumCliente;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_asigna_solicitud_mc(cEmpresa, pStatus, pUsuario)
		INTO cCodRetSp, cNumSolicitud, cNumCliente;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00717';		END IF;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "00017"; --NO EXISTEN REGISTROS
		END IF;
		
		RETURN cCodRet,cNumSolicitud,cNumCliente;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 12/11/2015',
'DESCRIPCION: Procedimientointermedio para asignar un cliente al analista de MC de manera automatica',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatalogocausastatusaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2))
	RETURNING CHAR(5) AS codret,
			CHAR(3) AS causa_status,
			CHAR(100) AS desc_causa;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeError CHAR(80);
	DEFINE cCausaStatus CHAR(3);
	DEFINE cDescCausaStatus CHAR(100);
	DEFINE iNoRegistros INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeError = '';
	LET cCausaStatus = '';
	LET cDescCausaStatus = '';
	LET iNoRegistros = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCausaStatus, cDescCausaStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogocausastatusaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCausaStatus, cDescCausaStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCausaStatus, cDescCausaStatus;
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_obtencausastatusaumlincred(cEmpresa, pStatus) 
				INTO cCodRetSp, cMensajeError, cCausaStatus, cDescCausaStatus
				
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_obtencausastatusaumlincred';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCausaStatus, cDescCausaStatus;
			ELIF iCodRetSp = 3 THEN -- ESTATUS NO ES VALIDO PARA EL CATALOGO DE STATUS DE INCREMENTO DE LINEA
				LET cCodRet = '00258';
				RETURN cCodRet, cCausaStatus, cDescCausaStatus;
			ELIF iCodRetSp = 4 THEN -- NO HAY REGISTROS PARA EL ESTATUS EN EL CATALOGO DE CAUSAS DE INCREMENTO DE LINEA
				LET cCodRet = '00259';
				RETURN cCodRet, cCausaStatus, cDescCausaStatus;
			END IF;
			
			RETURN cCodRet, cCausaStatus, UPPER(cDescCausaStatus) WITH RESUME;
				
		END FOREACH;
				
	END;
	
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/03/2014',
'DESCRIPCION: Procedimiento para obtener las causas pertenecientes a los status de aumento de linea de credito',
'BD: bdicnweb;';

CREATE PROCEDURE "informix".sp_observacionespreviasaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pFechaOrigenIncremento DATE)
	RETURNING CHAR(5) AS codret,
		CHAR(208) AS justificacion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cMensajeRetorno CHAR(107);
	DEFINE cJustificacion CHAR(208);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cMensajeRetorno = '';
	LET cJustificacion = NULL;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cJustificacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_observacionespreviasaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pFechaOrigenIncremento = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cJustificacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cJustificacion;
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_observprevias(cEmpresa, pNumSolicitud, pFechaOrigenIncremento)    
				INTO cCodRetSp, cMensajeRetorno, cJustificacion
			RETURN cCodRet, cJustificacion WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cJustificacion;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/03/2014',
'DESCRIPCION: Consulta las observaciones previas que ha tenido una solicitud de aumento/dosminuciÃ³n de linea de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtenerexcepcionescacaumlincred(pUsuario CHAR(20), pIdFuncion CHAR(10), pNumCredito CHAR(20), pFecha DATE)
	RETURNING CHAR(5) AS codret,
			CHAR(3) AS cve_excepcion,
			CHAR(100) AS desc_excepcion; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescripcion CHAR(80);
	DEFINE cCveExcepcion CHAR(3);
	DEFINE cDescExcepcion CHAR(100);
	DEFINE iNoRegistros INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescripcion = '';
	LET cCveExcepcion = '';
	LET cDescExcepcion = '';
	LET iNoRegistros = 0;
	LET cEmpresa = '001';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveExcepcion, cDescExcepcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerexcepcionescacaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveExcepcion, cDescExcepcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCveExcepcion, cDescExcepcion;
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_obtenerexcepcionescac(cEmpresa, pNumCredito, pFecha)
				INTO cCodRetSp, cDescripcion, cCveExcepcion, cDescExcepcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtenerexcepcionescac';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveExcepcion, cDescExcepcion;
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveExcepcion, cDescExcepcion;
			ELIF iCodRetSp = 2 THEN -- NO EXISTEN EXCEPCIONES PARA ESTE CREDITO
				LET cCodRet = '00264';
				RETURN cCodRet, cCveExcepcion, cDescExcepcion;
			ELIF iCodRetSp = 0 THEN
				RETURN cCodRet, cCveExcepcion, UPPER(cDescExcepcion) WITH RESUME;
			END IF;	
		
		END FOREACH;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/03/2014',
'DECRIPCION: Procedimiento para obtener la clave y la descripcion de las excepciones que tiene una solicitud de crÃ©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cacgrabanalisisdeteraumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pLineaSugerida DECIMAL(18,2),
								pMontoIncremento DECIMAL(18,2), pStatus CHAR(2), pCausaStatus CHAR(3), pJustificacion CHAR(200), pMismoEjecutivo CHAR(1),
								pIngresoMC DECIMAL(18,2), pOtrosComp DECIMAL(18,2), pNuevoEstatus CHAR(2), pCausa CHAR(3))
		RETURNING CHAR(5) AS codret;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET cMensajeRetorno = '';
	LET cEmpresa = '001';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cacgrabanalisisdeteraumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pLineaSugerida IS NULL OR pStatus = '' OR pJustificacion = '' OR pNuevoEstatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumSolicitud, '06', '1') INTO cCodRet;
		--EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_cac_grabanalisisydeterlincred(cEmpresa, pUsuario, pNumSolicitud, pLineaSugerida, pMontoIncremento,
							pStatus, pCausaStatus, pJustificacion, pMismoEjecutivo, pIngresoMC, pOtrosComp, pNuevoEstatus, pCausa) INTO cCodRetSp, cMensajeRetorno;
		LET iCodRet = cCodRetSp::INTEGER;
		
		IF iCodRet < 0 THEN
			RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_grabanalisisydeterlincred';
		ELIF iCodRet = 1 THEN	
			LET cCodRet = '00003';
		ELIF iCodRet = 2 THEN	
			RAISE EXCEPTION iCodRet, 0, cMensajeRetorno;
		ELIF iCodRet = 3 THEN	-- NIVEL DE EJECUTIVO NO PUEDE SER MAYOR A NIVEL DE RANGO DE AUTORIZACION
			LET cCodRet = '00265'; 
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/03/2014',
'DESCRIPCION: Permite  actualizar las revisiones a las que se somete la solicitud de aumento de linea de credito para pasar al siguiente nivel hasta llegar a status final',
'DB: bdicnweb';

CREATE PROCEDURE "informix".sp_restablecerevisionsoliaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pMismoUsuario CHAR(1))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET cEmpresa = '001	';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_restablecerevisionsoliaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pMismoUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumSolicitud, '06', '1') INTO cCodRet;
		--EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_restablecerrevisionsolicitud(cEmpresa, pNumSolicitud, pUsuario, pMismoUsuario) INTO cCodRetSp, cMensajeRetorno;
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_restablecerrevisionsolicitud';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/03/2014',
'DESCRIPCION: Procedimiento para la deasignaciÃ³n de solicitudes de incremento de lÃ­neas de crÃ©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_asignasolanalistaaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20), pMonto DECIMAL(18,2))
	RETURNING CHAR(5) AS codret,
			CHAR(107) AS mensaje_retorno;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE cMensajeRetorno CHAR(107);
	DEFINE cEmpresa CHAR(3);
	DEFINE iGuardoHistorica INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET cMensajeRetorno = '';
	LET cEmpresa = '001';
	LET iGuardoHistorica = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRetorno;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_asignasolanalistaaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRetorno;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRetorno;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_cac_asignasolanalista(cEmpresa, pNumCredito, pUsuario, pMonto) INTO cCodRetSp, cMensajeRetorno, iGuardoHistorica;
		LET iCodRet = cCodRetSp::INTEGER;
		
		IF iCodRet < 0 THEN
			RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_asignasolanalista';
		ELIF iCodRet = 1 THEN -- FALTAN PARAMETROS DE ENTRADA
			LET cCodRet = '00003';
		ELIF iCodRet = 7 THEN -- EL ESTATUS DE LA SOLICITUD CAMBIÃ FAVOR DE VERIFICAR
			LET cCodRet = '00253';
		ELIF iCodRet = 2 THEN -- SOLICITUD ESTÃ SIENDO ATENDIDA POR XXXXXX XXXXXX XXXXX XXXXX
			LET cCodRet = '90000'; 
		ELIF iCodRet = 6 THEN -- MISMO USUARIO ATENDIENDO LA SOLICITUD PERO YA PASO DE REVISION
			LET cCodRet = '00254';
		ELIF iCodRet = 4 THEN -- MISMO USUARIO ATENDIENDO LA SOLICITUD (CASOS DE ERROR)
			LET cCodRet = '00255';
		ELIF iCodRet = 5 THEN -- MISMO USUARIO QUE ATENDIO LA SOLICITUD
			LET cCodRet = '00256';
		ELIF iCodRet = 3 THEN -- LA AUTORIZACIÃN NO CORRESPONDE A ESE NIVEL, FAVOR DE VALIDAR
			LET cCodRet = '00257';
		END IF;
		
		RETURN cCodRet, cMensajeRetorno;
	
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/03/2014',
'DESCRIPCION: Realiza la asignacion de solicitudes de incremento de lÃ­neas de crÃ©dito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_calculalinsugcteaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pCompIngreso CHAR(1), pIngresoMens DECIMAL(18,2), pOtrosComp DECIMAL(18,2))
		RETURNING CHAR(5) AS codret,
				DECIMAL(18,2) AS linea_sugerida,
                DECIMAL(18,2) AS monto_increm,
                DECIMAL(4,2) AS razon_increm,
                DECIMAL(5,2) AS tasainteres_anual_increm;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE dLineaSugerida DECIMAL(18,2);
	DEFINE dMontoIncremento DECIMAL(18,2);
	DEFINE dRazonIncremento DECIMAL(4,2);
	DEFINE dTasaInteresAnualIncremento DECIMAL(5,2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeRetorno = '';
	LET dLineaSugerida = 0;
	LET dMontoIncremento = 0;
	LET dRazonIncremento = 0;
	LET dTasaInteresAnualIncremento = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTasaInteresAnualIncremento;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_calculalinsugcteaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pCompIngreso = '' OR pIngresoMens IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTasaInteresAnualIncremento;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTasaInteresAnualIncremento;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_cac_calculalinsugcte(cEmpresa, pNumSolicitud, pCompIngreso, pIngresoMens, pOtrosComp)
		INTO cCodRetSp, cMensajeRetorno, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTasaInteresAnualIncremento;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_calculalinsugcte';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN -- ERROR AL OBTENER PORCENTAJE DE INCREMENTO PARA SALARIOS MINIMOS MENORES A 1.27
			LET cCodRet = '00266';
		ELIF iCodRetSp = 3 THEN -- ERROR AL OBTENER PORCENTAJE DE INCREMENTO PARA SALARIOS MINIMOS MAYORES A 1.27
			LET cCodRet = '00267';
		ELIF iCodRetSp = 4 THEN -- ERROR AL OBTENER LA LINEA DE CREDITO A COMPARAR PARA INCREMENTOS DE LINEA
			LET cCodRet = '00268';
		ELIF iCodRetSp = 5 THEN -- NO EXISTEN DATOS DE AUMENTO DE LINEA DE CREDITO PARA ESTA SOLICITUD
			LET cCodRet = '00269';
		ELIF iCodRetSp = 7 THEN -- ERROR AL OBTENER EL PARAMETRO DE PORCENTAJE DE FACTOR PARA CAPACIDAD DE PAGO
			LET cCodRet = '00270';
		ELIF iCodRetSp = 8 THEN -- SE RECHAZA EL CALCULO DE LA LINEA SUGERIDA POR CAPACIDAD DE PAGO SATURADA
			LET cCodRet = '00271';
		ELIF iCodRetSp = 9 THEN -- ERROR AL OBTENER EL PARÃMETRO DE LA TASA DE INTERÃS DEL PERIODO
			LET cCodRet = '00272';
		ELIF iCodRetSp = 10 THEN
			LET cCodRet = '00273';
		END IF;
		
		RETURN cCodRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTasaInteresAnualIncremento;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/03/2014',
'DESCRIPCION: Procedimiento para hacer el recalculo de la linea sugerida para sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obteninforepnivelautorizacionaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20), pCompIngreso CHAR(1), pFechaInc CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(107) AS nombrecte,
				CHAR(13) AS rfc,
				CHAR(20) AS fechanac,
				CHAR(13) AS estadocivil,
				CHAR(13) AS teldomicilio,
				CHAR(13) AS telmovil,
				CHAR(13) AS teltrabajo,
				CHAR(30) AS calle,
				INTEGER AS numero,
				CHAR(32) AS colonia,
				CHAR(20) AS delomunicipio,
				CHAR(30) AS nomestado,
				CHAR(5) AS cp,
				CHAR(50) AS nombresuc,
				CHAR(20) AS numerocuenta,
				CHAR(4) AS sucursal,
				CHAR(1) AS incremento,
				CHAR(1) AS creditofuncionario,
				CHAR(1) AS obligadosolidario,
				CHAR(80) AS nombrepromotor,
				DECIMAL(18,2) AS linactual,
				DECIMAL(18,2) AS nuevalin,
				DECIMAL(18,2) AS montoincre,
				INTEGER AS iaumento,
				CHAR(50) AS nomobligado,
				CHAR(10) AS fechanacobligado,
				CHAR(20) AS rfcobligado,
				CHAR(10) AS telcasa,
				CHAR(50) AS relacioncte,
				SMALLINT AS meseshist,
				DECIMAL(18,2) AS ingresos,
				CHAR(1) AS burocredito,
				CHAR(1) AS circulocredito,
				CHAR(1) AS coppel,
				CHAR(40) AS tipocomprobante,
				CHAR(2) AS nivelautorizacion,
				CHAR(45) AS nomnivel1,
				CHAR(45) AS nomnivel2,
				CHAR(45) AS nomnivel3,
				CHAR(45) AS nomnivel4,
				CHAR(2) AS rangoautorizacion,
				CHAR(10) AS fechamax,
				CHAR(203) AS observ1,
				CHAR(203) AS observ2,
				CHAR(203) AS observ3,
				CHAR(203) AS observ4;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNombreCte CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE cFechaNac CHAR(20);
	DEFINE cEstadoCivil CHAR(13);
	DEFINE cTelDomicilio CHAR(13);
	DEFINE cTelMovil CHAR(13);
	DEFINE cTelTrabajo CHAR(13);
	DEFINE cCalle CHAR(30);
	DEFINE iNumero INTEGER;
	DEFINE cColonia CHAR(32);
	DEFINE cDelMunicipio CHAR(20);
	DEFINE cNombreEstado CHAR(30);
	DEFINE cCp CHAR(5);
	DEFINE cNombreSucursal CHAR(50);
	DEFINE cNumeroCuenta CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cIncremento CHAR(1);
	DEFINE cCreditoFuncionario CHAR(1);
	DEFINE cObligadoSolidario CHAR(1);
	DEFINE cNombrePromotor CHAR(80);
	DEFINE dLineaActual DECIMAL(18,2);
	DEFINE dNuevaLinea DECIMAL(18,2);
	DEFINE dMontoIncremento DECIMAL(18,2);
	DEFINE iAumento INTEGER;
	DEFINE cNomObligado CHAR(50);
	DEFINE cFechaNacObligado CHAR(10);
	DEFINE cRfcObligado CHAR(20);
	DEFINE cTelCasa CHAR(10);
	DEFINE cRelacionCte CHAR(50);
	DEFINE iMesesHist SMALLINT;
	DEFINE dIngresos DECIMAL(18,2);
	DEFINE cBuroCredito CHAR(1);
	DEFINE cCirculoCredito CHAR(1);
	DEFINE cCoppel CHAR(1);
	DEFINE cTipoComprobante CHAR(40);
	DEFINE cNivelAutorizacion CHAR(2);
	DEFINE cNomNivel1 CHAR(45);
	DEFINE cNomNivel2 CHAR(45);
	DEFINE cNomNivel3 CHAR(45);
	DEFINE cNomNivel4 CHAR(45);
	DEFINE cRangoAutorizacion CHAR(2);
	DEFINE cFechaMax CHAR(10);
	DEFINE cObserv1 CHAR(203);
	DEFINE cObserv2 CHAR(203);
	DEFINE cObserv3 CHAR(203);
	DEFINE cObserv4 CHAR(203);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeRetorno = '';
	LET cNombreCte = '';
	LET cRfc = '';
	LET cFechaNac = '';
	LET cEstadoCivil = '';
	LET cTelDomicilio = '';
	LET cTelMovil = '';
	LET cTelTrabajo = '';
	LET cCalle = '';
	LET iNumero = 0;
	LET cColonia = '';
	LET cDelMunicipio = '';
	LET cNombreEstado = '';
	LET cCp = '';
	LET cNombreSucursal = '';
	LET cNumeroCuenta = '';
	LET cSucursal = '';
	LET cIncremento = '';
	LET cCreditoFuncionario = '';
	LET cObligadoSolidario = '';
	LET cNombrePromotor = '';
	LET dLineaActual = NULL;
	LET dNuevaLinea = NULL;
	LET dMontoIncremento = NULL;
	LET iAumento = 0;
	LET cNomObligado = '';
	LET cFechaNacObligado = '';
	LET cRfcObligado = '';
	LET cTelCasa = '';
	LET cRelacionCte = '';
	LET iMesesHist = 0;
	LET dIngresos = NULL;
	LET cBuroCredito = '';
	LET cCirculoCredito = '';
	LET cCoppel = '';
	LET cTipoComprobante = '';
	LET cNivelAutorizacion = '';
	LET cNomNivel1 = '';
	LET cNomNivel2 = '';
	LET cNomNivel3 = '';
	LET cNomNivel4 = '';
	LET cRangoAutorizacion = '';
	LET cFechaMax = '';
	LET cObserv1 = '';
	LET cObserv2 = '';
	LET cObserv3 = '';
	LET cObserv4 = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreCte, cRfc, cFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumero, cColonia, cDelMunicipio, 
					cNombreEstado, cCp, cNombreSucursal, cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario, cNombrePromotor, 
					dLineaActual, dNuevaLinea, dMontoIncremento, iAumento, cNomObligado, cFechaNacObligado, cRfcObligado, cTelCasa, cRelacionCte, iMesesHist, 
					dIngresos, cBuroCredito, cCirculoCredito, cCoppel, cTipoComprobante, cNivelAutorizacion, cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, 
					cRangoAutorizacion, cFechaMax, cObserv1, cObserv2, cObserv3, cObserv4;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obteninforepnivelautorizacionaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pCompIngreso = '' OR pFechaInc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreCte, cRfc, cFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumero, cColonia, cDelMunicipio, 
					cNombreEstado, cCp, cNombreSucursal, cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario, cNombrePromotor, 
					dLineaActual, dNuevaLinea, dMontoIncremento, iAumento, cNomObligado, cFechaNacObligado, cRfcObligado, cTelCasa, cRelacionCte, iMesesHist, 
					dIngresos, cBuroCredito, cCirculoCredito, cCoppel, cTipoComprobante, cNivelAutorizacion, cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, 
					cRangoAutorizacion, cFechaMax, cObserv1, cObserv2, cObserv3, cObserv4;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreCte, cRfc, cFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumero, cColonia, cDelMunicipio, 
					cNombreEstado, cCp, cNombreSucursal, cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario, cNombrePromotor, 
					dLineaActual, dNuevaLinea, dMontoIncremento, iAumento, cNomObligado, cFechaNacObligado, cRfcObligado, cTelCasa, cRelacionCte, iMesesHist, 
					dIngresos, cBuroCredito, cCirculoCredito, cCoppel, cTipoComprobante, cNivelAutorizacion, cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, 
					cRangoAutorizacion, cFechaMax, cObserv1, cObserv2, cObserv3, cObserv4;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_cac_obteninforepnivelautorizacion(cEmpresa, pNumCredito, pUsuario, pCompIngreso, pFechaInc)
		INTO cCodRetSp, cMensajeRetorno, cNombreCte, cRfc, cFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumero, cColonia, 
			cDelMunicipio, cNombreEstado, cCp, cNombreSucursal, cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario, cNombrePromotor, 
			dLineaActual, dNuevaLinea, dMontoIncremento, iAumento, cNomObligado, cFechaNacObligado, cRfcObligado, cTelCasa, cRelacionCte, iMesesHist, dIngresos, 
			cBuroCredito, cCirculoCredito, cCoppel, cTipoComprobante, cNivelAutorizacion, cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, cRangoAutorizacion, cFechaMax, 
			cObserv1, cObserv2, cObserv3, cObserv4;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_obteninforepnivelautorizacion';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN -- EL CRÃDITO AUN NO HA SIDO AUTORIZADO
			LET cCodRet = '00274';
		END IF;
		
		RETURN cCodRet, cNombreCte, cRfc, cFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumero, cColonia, cDelMunicipio, 
					cNombreEstado, cCp, cNombreSucursal, cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario, cNombrePromotor, 
					dLineaActual, dNuevaLinea, dMontoIncremento, iAumento, cNomObligado, cFechaNacObligado, cRfcObligado, cTelCasa, cRelacionCte, iMesesHist, 
					dIngresos, cBuroCredito, cCirculoCredito, cCoppel, cTipoComprobante, cNivelAutorizacion, cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, 
					cRangoAutorizacion, cFechaMax, cObserv1, cObserv2, cObserv3, cObserv4;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/03/2014',
'DESCRIPCION: Obtiene datos generales del cliente, estado  y antecedentes del crÃ©dito e informacion del incremento',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_catalogoclasificacion(pUsuario CHAR(8), pIdFuncion CHAR(10)) 
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS clasificacion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE cClasificacion CHAR(1);
	DEFINE iNoRegistros INTEGER;
	DEFINE iSqlErr INTEGER;
 
	LET cCodRet = '00000';
	LET cClasificacion = '';
	LET iNoRegistros = 0;
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClasificacion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catalogoclasificacion.out';
		--TRACE ON;
		
		IF  pUsuario = '' OR  pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClasificacion;	
		END IF;
		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClasificacion;	
		END IF;
		
		FOREACH
			SELECT  
			DISTINCT clasificacion 
			INTO cClasificacion
			FROM bdinteg:"informix".si_clase_tc
			ORDER BY 1 ASC
			
			LET iNoRegistros = iNoRegistros + 1;							
			RETURN cCodRet, cClasificacion WITH RESUME;
		
		END FOREACH;
		
		IF NVL(iNoRegistros,0) = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClasificacion;	
		END IF;
	END;	
	END PROCEDURE
	
DOCUMENT 'AUTOR: MIGUEL MADRID CORONA',
'FECHA: 06/04/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATALOGO DE CLASES TIPOS DE CAMBIO', 
'DESCRIPCION: SPL que obtiene los datos el campo clasificacion de la tabla si_clase_tc para el llenado del combobox "Clasificacion" ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_clasetipocambioaltas(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),pClase_TpCambio CHAR(1),pDesc_ClaseTc CHAR(40),pClasificacion CHAR(1))
RETURNING CHAR(5) AS codret;    		

	DEFINE cCodRet CHAR(5);
	DEFINE iNoRegistros INTEGER;
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iNoRegistros = 0;
	LET iSqlErr = 0;
	
	
	BEGIN	
		
		ON EXCEPTION SET iSqlErr
			
			LET cCodRet = iSqlErr;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_clasetipocambioaltas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR  pTipoOperacion = '' OR   pClase_TpCambio = '' THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		
		IF pTipoOperacion = '1' THEN
		
			IF pDesc_ClaseTc = '' OR  pClasificacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		
			SELECT COUNT(*) 
			INTO iNoRegistros
			FROM bdinteg:"informix".si_clase_tc 
			WHERE clase_tpcambio = pClase_TpCambio;
			
			IF  NVL(iNoRegistros,0) > 0 THEN
				
				UPDATE bdinteg:"informix".si_clase_tc   
				SET  desc_clase_tc = pDesc_ClaseTc, clasificacion = pClasificacion 
				WHERE clase_tpcambio = pClase_TpCambio;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
					LET cCodRet = '00283';
				END IF;
				
			ELSE
				INSERT INTO bdinteg:"informix".si_clase_tc (clase_tpcambio,desc_clase_tc,clasificacion,user_insert,fecha_insert)
				VALUES(pClase_TpCambio,pDesc_ClaseTc,pClasificacion,pUsuario,CURRENT); 
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
					LET cCodRet = '00282';			
				END IF;				
				
			END IF;
		ELIF pTipoOperacion = '2' THEN
			
			DELETE FROM bdinteg:"informix".si_clase_tc  WHERE clase_tpcambio = pClase_TpCambio;	
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCodRet = '00862';						
			END IF;	
				
		END IF;
		RETURN cCodRet;
	END;	
END PROCEDURE	
DOCUMENT 'AUTOR: MIGUEL MADRID CORONA',
'FECHA: 06/04/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATALOGO DE CLASES TIPOS DE CAMBIO', 
'DESCRIPCION: SPL que se encarga de eliminar, insertar y modificar registros de la tabla si_clase_tc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_detalleclasetipocambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),pClase_TpCambio CHAR(1)) 
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS codTpCambio,
		CHAR(40) AS descripcion,
		CHAR(1) AS clasificacion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cCodTpCambio CHAR(1);
	DEFINE cDescripcion CHAR(40);
    DEFINE cClasificacion CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	
 
	LET cCodRet = '00000';
	LET cCodTpCambio = '';
	LET cDescripcion = '';
	LET cClasificacion = '';
	LET iNoRegistros = 0;
	LET iSqlErr = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_detalleclasetipocambio.out';
		--TRACE ON;
		
		IF  pUsuario = '' OR  pIdFuncion = '' OR  pTipoOperacion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;	
		END IF;
				
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;	
		END IF;
		
		IF pTipoOperacion = '1' THEN
			FOREACH
				SELECT  clase_tpcambio,desc_clase_tc,clasificacion 
				INTO cCodTpCambio, cDescripcion, cClasificacion
				FROM bdinteg:"informix".si_clase_tc 
				ORDER BY 1 ASC
				
				LET iNoRegistros = iNoRegistros + 1;	
				RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion WITH RESUME;	
			END FOREACH;
			
			IF  NVL(iNoRegistros,0) = 0  THEN
				LET cCodRet = '00017';	
				RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;	
			END IF;	
			
		ELSE
		
			IF pClase_TpCambio=''  THEN
			
				LET cCodRet = '00003';
				RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;	
			
			ELSE 
				SELECT  clase_tpcambio,desc_clase_tc,clasificacion 
				INTO cCodTpCambio, cDescripcion, cClasificacion 
				FROM bdinteg:"informix".si_clase_tc 			
				WHERE clase_tpcambio = pClase_TpCambio; 
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
					LET cCodRet = '00017';							
				END IF;	
				RETURN cCodRet, cCodTpCambio, cDescripcion, cClasificacion;					
					
			END IF;			
			
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: MIGUEL MADRID CORONA',
'FECHA: 03/04/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATALOGO DE CLASES TIPOS DE CAMBIO',
'DESCRIPCION: SPL que se encarga de consultar todos los datos de la tabla para el llenado del grid',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consultatotalmovtosdiarioscta(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pReversado CHAR(1))
				returning CHAR(5)  AS Cod_Retorno,
						  INTEGER AS numero_registros;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
DEFINE iKiosko			INT;
--inicializando variables
LET  iexiste = 0;
LET  iExisteCta = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET iKiosko               =0;

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet, iCont;
          END IF;
     END EXCEPTION;

  SET ISOLATION TO DIRTY READ ;
  SET LOCK MODE TO WAIT 3 ;
                
	--SET DEBUG FILE TO "/informix/VH/sif/sp_cnsif_consultatotalmovtosdiarioscta.out";
	--TRACE ON;
                  
	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	END IF;
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		SELECT valor
		INTO cconsmovhisold2
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld2';

		SELECT valor
		INTO cconsmovhisold3
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'vfechconmovhisold3';

		SELECT valor
		INTO cconsmovhisold4
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld4';
		
		IF dPERIODOF = TODAY THEN
			SELECT NVL(COUNT(MO.cuenta),0) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movdia MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = iexiste;
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SELECT NVL(COUNT(MO.cuenta),0) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
  
			LET iCont = iCont + iexiste;
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SELECT NVL(COUNT(MO.cuenta),0) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = iCont + iexiste;
		END IF;
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SELECT {+INDEX (bdicheq:sc_movhis_old2 idx_movhis_old2)} NVL(COUNT(MO.cuenta),0) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old2 MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

			LET iCont = iCont + iexiste;
		END IF;
		
			SELECT {+INDEX (bdicheq:sc_maechq idx_sc_maechq)} NVL(COUNT(cuenta),0) 
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		IF iExisteCta = 0 OR cID_FUNCIONC = 'ROA200' THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SELECT {+INDEX (bdicheq:sc_movhis_old3 idx_movhis_old3)} NVL(COUNT(MO.cuenta),0) 
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old3 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

				LET iCont = iCont + iexiste;

			END IF;

			IF  (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SELECT {+INDEX (bdicheq:sc_movhis_old4 idx_movhis_old4)} NVL(COUNT(MO.cuenta),0) 
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old4 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 
			
				LET iCont = iCont + iexiste;
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SELECT {+INDEX (bditransfer:tf_success_transac idx_tf_success_transac2)} NVL(COUNT(cuenta),0) 
			INTO iexiste
			FROM bditransfer:"informix".tf_success_transac
			WHERE fecha_alt < to_date('20/03/2015','%d/%m/%Y') 
			AND fecha_alt BETWEEN dPERIODOI AND dPERIODOF AND cuenta  = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END; 

			LET iCont = iCont + iexiste;
		END IF;
		
		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		IF iCont>=1001 THEN
			RETURN "00958", 0;
		ELSE
			RETURN cCodRet, iCont;
		END IF;

	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SELECT NVL(COUNT(num_credito),0) 
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;
		
		IF iExisteCta > 0 THEN
			SELECT {+INDEX (bdicred:sd_movdia mov4)} NVL(COUNT(num_credito),0) 
			INTO iexiste
			FROM bdicred:sd_movdia MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
			WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			IF iexiste  = 0 THEN
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} NVL(COUNT(num_credito),0) 
				INTO iexiste
				FROM bdicred:sd_movhis MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				IF iexiste  = 0 THEN
					SELECT {+INDEX (bdicred:sd_movhis_new inx_movhis4_new)} NVL(COUNT(num_credito),0) 
					INTO iexiste
					FROM bdicred:sd_movhis_new MO
					LEFT JOIN bdicred:sd_transfun TR
					ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
					RIGHT JOIN bdinteg:si_transacc TS
					ON TS.empresa = '001'
					AND TS.numero = TR.transacc
					AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
					WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
					AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
					AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
					AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				END IF;
			END IF;
		ELSE
			SELECT NVL(COUNT(num_credito),0) 
			INTO iexiste
			FROM bdicred:sd_movdiacrd
			WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
			AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
			AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;
			IF iexiste  = 0 THEN
				SELECT NVL(COUNT(num_credito),0) 
				INTO iexiste
				FROM bdicred:sd_movhiscrd
				WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
				AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
				AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
				AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;     
			END IF;
		END IF;

		IF iexiste  = 0 THEN
		   LET cCodRet = "00039";
		   RETURN cCodRet, iCont;
		END IF;
		
		IF iExisteCta > 0 THEN
			FOREACH
				SELECT {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			UNION
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			UNION 
				SELECT {+INDEX (bdicred:sd_movhis_new inx_movhis4_new)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhis_new  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			ORDER BY MO.secuencia DESC

			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			END IF;

			END FOREACH;

			IF iCont>=1001 THEN
				RETURN "00958", 0;
			ELSE
				RETURN cCodRet, iCont;
			END IF;

			--RETURN cCodRet, iCont;
		
		ELSE
			FOREACH
				SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			ORDER BY MO.secuencia DESC

			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			END IF;

			END FOREACH;

			--RETURN cCodRet, iCont;
			IF iCont>=1001 THEN
				RETURN "00958", 0;
			ELSE
				RETURN cCodRet, iCont;
			END IF;
		END IF;
		
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
		SELECT NVL(COUNT(cuenta),0)
		INTO iexiste
		FROM bdinvers:sv_movdia
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
		AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
		AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;

		LET iCont = iexiste;

		SELECT NVL(COUNT(cuenta),0) 
		INTO iexiste
		FROM bdinvers:sv_movhis
		WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
		AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
		AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;

		LET iCont = iCont + iexiste;

		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		IF iCont>=1001 THEN
			RETURN "00958", 0;
		ELSE
			RETURN cCodRet, iCont;
		END IF;
		--RETURN cCodRet, iCont;

	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Oscar Flores Conde",
"FUNCIONAMIENTO: Este sp realizara la consulta de numero de registros que regresara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 0-0-2012",
"BD    : bdicnweb",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_catalogotasasaltas(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1), pTasa CHAR(8), pFecha DATE, pValor CHAR(15), pPorcentaje CHAR(15), pPuntos CHAR(15), pPromedio CHAR(15), pFechaRecalculo DATE, pValorBaseRef CHAR(15))
		RETURNING CHAR(5) AS codret		    		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipotasa CHAR(8);
	DEFINE cDescripcion CHAR(30);
	DEFINE iNoRegistros INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipotasa = 0;
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotasasaltas.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pTasa = '' OR pFecha IS NULL or pValor = '' THEN
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
				
		IF pTipoOperacion = '1' THEN
		
			--CONSULTA PARA VERIFICAR SI YA EXISTE LA TASA CON LA MISMA FECHA
			SELECT COUNT(*) 
			INTO iNoRegistros
			FROM bdinteg:"informix".si_fechavalor 
			WHERE tasa = pTasa 
			AND fecha = pFecha;
			
			IF NVL(iNoRegistros,0) > 0 THEN
				LET cCodRet = '00922'; --âEl valor de la tasa para esta fecha ya estÃ¡ registrado, verifique.â
				RETURN cCodRet;
			ELIF NVL(iNoRegistros,0) = 0 THEN
				--REALIZA EL ALTA DE TASAS
				INSERT INTO bdinteg:"informix".si_fechavalor (empresa, tasa, fecha, valor, promedio, valor_base_ref, porcentaje, puntos, fecha_recalculo, user_insert, fecha_insert)
				VALUES(cEmpresa, pTasa, pFecha, pValor, pPromedio, pValorBaseRef, pPorcentaje, pPuntos, pFechaRecalculo, pUsuario, CURRENT);
				RETURN cCodRet;
			END IF;
			
		ELIF pTipoOperacion = '2' THEN
		
			SELECT fecha_hoy INTO dFecha FROM bdinteg:"informix".si_fechas;
			
			IF pFecha <> dFecha THEN
			
				--CONSULTA PARA VERIFICAR SI YA EXISTE LA TASA CON LA MISMA FECHA
				SELECT COUNT(*) 
				INTO iNoRegistros
				FROM bdinteg:"informix".si_fechavalor 
				WHERE tasa = pTasa 
				AND fecha = dFecha;
			
				IF NVL(iNoRegistros,0) > 0 THEN
					LET cCodRet = '01019'; --YA EXISTE UN REGISTRO DE LA TASA CON LA FECHA DE HOY, VERIFIQUE
					RETURN cCodRet;
				END IF;
			
			END IF;
			
			--REALIZA ACTUALIZACION DE TASAS
			UPDATE bdinteg:"informix".si_fechavalor  SET fecha_recalculo = pFechaRecalculo, puntos = pPuntos, porcentaje = pPorcentaje,
			valor = pValor, promedio = pPromedio ,valor_base_ref = pValorBaseRef, fecha = dFecha WHERE empresa = cEmpresa AND tasa = pTasa AND fecha = pFecha;
			RETURN cCodRet;
				
		END IF;
		
		IF pTipoOperacion = '3' THEN
			--ELIMINA REGISTRO DE TASAS
			DELETE FROM bdinteg:"informix".si_fechavalor WHERE tasa = pTasa AND fecha = pFecha;
			RETURN cCodRet;									
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA',
'DESCRIPCION: SPL que realiza Alta, Modificacion y Eliminacion de registros',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 18/05/2017',
'DESCRIPCION: Se modifica SPL para hacer el update de la fecha en la tabla si_fechavalor',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/11/2017',
'DESCRIPCION: Se modifica SPL para permitir la actualizaciÃ³n de registros mÃ¡s de una vez durante el dÃ­a.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotasasfecha(pUsuario CHAR(8), pIdFuncion CHAR(10), pTasa CHAR(8), pFecha DATE, pValor CHAR(15), pPorcentaje CHAR(15), pPuntos CHAR(15), pPromedio CHAR(15), pFechaRecalculo DATE, pValorBaseRef CHAR(15), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS tasa,
			CHAR(30) AS pDescripcion,
			DATE AS fecha,
			DECIMAL(9,6) AS valor,
			DECIMAL(9,6) AS promedio,
			DECIMAL(9,6) AS valor_base_ref,
			DECIMAL(9,6) AS porcentaje,
			DECIMAL(9,6) AS puntos,
			DATE AS fecha_recalculo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTasa CHAR(8);
	DEFINE cDescripcion CHAR(30);
	DEFINE dFecha DATE;
	DEFINE dValor DECIMAL(9,6);
	DEFINE dPromedio DECIMAL(9,6);
	DEFINE dValorBaseRef DECIMAL(9,6);
	DEFINE dPorcentaje DECIMAL(9,6);
	DEFINE dPuntos DECIMAL(9,6);
	DEFINE dFechaRecalculo DATE;
	DEFINE iNumRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;	
	DEFINE dValorChr DECIMAL(9,6);
	DEFINE dPromedioChr DECIMAL(9,6);
	DEFINE dVBaseRefChr DECIMAL(9,6);
	DEFINE dPorcentajeChr DECIMAL(9,6);
	DEFINE dPuntosChr DECIMAL(9,6);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTasa = '';
	LET cDescripcion = '';
	LET dFecha = '';
	LET dValor = 0;
	LET dPromedio = 0;
	LET dValorBaseRef = 0;
	LET dPorcentaje = 0;
	LET dPuntos = 0;
	LET dFechaRecalculo = '';
	LET iNumRegistros = 0;
	LET iRecuperacion = 0;
	LET dValorChr = 0;	
	LET dPromedioChr = 0;	
	LET dVBaseRefChr = 0;	
	LET dPorcentajeChr = 0;	
	LET dPuntosChr = 0;	

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotasasfecha.out';
		--TRACE ON;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pValor,'') <> '' THEN
			LET dValorChr = pValor;
		END IF;
		
		IF NVL(pPromedio,'') <> '' THEN
			LET dPromedioChr = pPromedio;
		END IF;
		
		IF NVL(pValorBaseRef,'') <> '' THEN
			LET dVBaseRefChr = pValorBaseRef;
		END IF;
		
		IF NVL(pPorcentaje,'') <> '' THEN
			LET dPorcentajeChr = pPorcentaje;
		END IF;
		
		IF NVL(pPuntos,'') <> '' THEN
			LET dPuntosChr = pPuntos;
		END IF;

   	    FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion a.tasa, b.descripcion, a.fecha, a.valor, a.promedio,a.valor_base_ref, a.porcentaje, a.puntos, a.fecha_recalculo
				INTO cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo
				FROM bdinteg:"informix".si_fechavalor a
				INNER JOIN bdinteg:"informix".si_tiptasa b ON a.tasa = b.tasa
				WHERE  a.empresa = cEmpresa
				AND NVL(a.tasa,'') = (CASE WHEN pTasa <> '' THEN pTasa ELSE nvl(a.tasa,'') END)
				AND NVL(a.fecha,'') = (CASE WHEN pFecha IS NOT NULL THEN CAST(pFecha AS CHAR(10)) ELSE NVL(a.fecha,'') END)
				AND NVL(a.valor,'') =  (CASE WHEN dValorChr > 0 THEN NVL(dValorChr,'')  ELSE NVL(a.valor,'') END)
				AND NVL(a.promedio,'') = (CASE WHEN dPromedioChr > 0 THEN NVL(dPromedioChr,'') ELSE NVL(a.promedio,'') END)
				AND NVL(a.valor_base_ref,'') = (CASE WHEN dVBaseRefChr > 0 THEN NVL(dVBaseRefChr,'') ELSE NVL(a.valor_base_ref,'') END)
				AND NVL(a.porcentaje,'') = (CASE WHEN dPorcentajeChr > 0 THEN NVL(dPorcentajeChr,'') ELSE NVL(a.porcentaje,'') END)
				AND NVL(a.puntos,'') = (CASE WHEN dPuntosChr > 0 THEN NVL(dPuntosChr,'') ELSE NVL(a.puntos,'') END)
				AND nvl(a.fecha_recalculo,'') = (CASE WHEN pFechaRecalculo IS NOT NULL THEN CAST(pFechaRecalculo AS CHAR(10)) ELSE nvl(a.fecha_recalculo,'') END)
				ORDER BY  a.tasa, a.fecha

				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo WITH RESUME;
		END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTasa, cDescripcion, dFecha, dValor, dPromedio, dValorBaseRef, dPorcentaje, dPuntos, dFechaRecalculo;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA',
'DESCRIPCION: SPL que se encarga de consultar Catalogo Tasa por Fecha.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotasasrecalculo(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    CHAR(8)  AS  clave_tasa, 
			CHAR(8) AS tasa_ref,
			DECIMAL(9,6) AS valor_base,
			DECIMAL(9,6) AS porcentaje,
			DECIMAL(9,6) AS puntos_adic,
			DECIMAL(9,6) AS valor_calculado,
			INTEGER AS total_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cClaveTasa CHAR(8);
	DEFINE cTasaReferen CHAR(8);
	DEFINE dValorBase DECIMAL(9,6);
	DEFINE dPorcentaje DECIMAL(9,6);
	DEFINE dPuntosAdic DECIMAL(9,6);
	DEFINE dValorCalc DECIMAL(9,6);
	DEFINE fechaMax DATE;
	DEFINE iNoRegistros INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cClaveTasa = '';
	LET cTasaReferen = '';
	LET dValorBase = 0;
	LET dPorcentaje = 0;
	LET dPuntosAdic = 0;
	LET dValorCalc = 0;
	LET fechaMax = '';
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveTasa, cTasaReferen, dValorBase, dPorcentaje, dPuntosAdic, dValorCalc, iNoRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotasasrecalculo.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveTasa, cTasaReferen, dValorBase, dPorcentaje, dPuntosAdic, dValorCalc, iNoRegistros;
		END IF;								
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveTasa, cTasaReferen, dValorBase, dPorcentaje, dPuntosAdic, dValorCalc, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		SELECT MAX(a.fecha)  
		INTO fechaMax
		FROM bdinteg:"informix".si_fechavalor a
		INNER JOIN bdinteg:"informix".si_tiptasa c 
		ON a.tasa = c.tasa
		WHERE c.maneja_tasa_ref='S';
		
		IF(fechaMax is null) THEN
			LET fechaMax = '01/01/0001';
		END IF;
		
		FOREACH 
				
				SELECT a.tasa,a.valor,a.porcentaje, a.puntos, c.tasareferen
				INTO cClaveTasa, dValorBase, dPorcentaje, dPuntosAdic, cTasaReferen
				FROM bdinteg:"informix".si_fechavalor a
				INNER JOIN bdinteg:"informix".si_tiptasa c ON a.tasa = c.tasa
				WHERE c.maneja_tasa_ref='S' AND a.fecha= fechaMax
				--Reliza operacion de recalculo
				LET dValorCalc = (dValorBase * dPorcentaje) / (100 + dPuntosAdic);
				--Actualiza tabla con nuevos valores de acuerdo al recalculo
				UPDATE bdinteg:"informix".si_fechavalor SET valor = dValorCalc, valor_base_ref = dValorBase, fecha_recalculo = CURRENT
				WHERE tasa = cClaveTasa AND fecha= fechaMax;
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cClaveTasa, cTasaReferen, dValorBase, dPorcentaje, dPuntosAdic, dValorCalc, iNoRegistros WITH RESUME;
		
		END FOREACH;				
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00000';
            RETURN cCodRet, cClaveTasa, cTasaReferen, dValorBase, dPorcentaje, dPuntosAdic, dValorCalc, iNoRegistros;
        END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA',
'DESCRIPCION: SPL que realiza el Recalculo de Tasas por Fecha',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotipotasa(pUsuario CHAR(8), pIdFuncion CHAR(10))							
		RETURNING CHAR(5) AS codret,
		    CHAR(8)  AS  clave_tasa, 
			CHAR(60) AS desc_tasa;					
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cClaveTasa CHAR(8);
	DEFINE cDescripcion CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClaveTasa = '';
	LET cEmpresa = '001';
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveTasa, cDescripcion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotipotasa.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveTasa, cDescripcion;
		END IF;								
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveTasa, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;                
		
		FOREACH 
			SELECT tasa, descripcion
			INTO cClaveTasa, cDescripcion
			FROM bdinteg:"informix".si_tiptasa
			where  empresa = cEmpresa 
			AND	rangofecha = 'F'
			ORDER BY descripcion
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cClaveTasa, UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH;
	
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cClaveTasa, cDescripcion;
         END IF;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA',
'DESCRIPCION: SPL que consulta el tipo de tasas para realizar llenado de combo',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constasareferencia(pUsuario CHAR(8), pIdFuncion CHAR(10), pTasa CHAR(8))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS tasa,
			CHAR(30) AS descripcion,
			CHAR(1) AS rango_fecha,
			CHAR(1) AS aplica_promedio,
			CHAR(8) AS tasa_ref,
			CHAR(1) AS maneja_tasa_ref;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTasa CHAR(8);
	DEFINE cDescripcion CHAR(30);
	DEFINE cRangoFecha CHAR(1);
	DEFINE cAplicaPromedio CHAR(1);
	DEFINE cTasaReferen CHAR(8);
	DEFINE cManejaTasaReferen CHAR(1); 
	DEFINE iNumRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTasa = '';
	LET cDescripcion = '';
	LET cRangoFecha = '';
	LET cAplicaPromedio = '';
	LET cTasaReferen = '';
	LET cManejaTasaReferen = ''; 
	LET iNumRegistros = 0;
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constasareferencia.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pTasa = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
   	    FOREACH 
			SELECT tasa, descripcion, rangofecha, aplica_promedio, tasareferen, maneja_tasa_ref
			INTO cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen
			FROM bdinteg:"informix".si_tiptasa
			WHERE  empresa = cEmpresa 	
			AND tasa = pTasa

			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet, cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen WITH RESUME;
		END FOREACH;
			
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cTasa, cDescripcion, cRangoFecha, cAplicaPromedio, cTasaReferen, cManejaTasaReferen;
		END IF;						
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA', 
'DESCRIPCION: SPL que realiza la consulta de Tasa Referenciada ',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constasatabular(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS tasa,
			CHAR(30) AS descripcion,
			DATE AS fecha,
			DECIMAL(9,6) AS valor,
			DECIMAL(9,6) AS promedio;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTasa CHAR(8);
	DEFINE cDescripcion CHAR(30);
	DEFINE cFecha DATE;
	DEFINE cValor DECIMAL(9,6);
	DEFINE cPromedio DECIMAL(9,6);	
	DEFINE iNumRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cDesConsulta CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTasa = '';
	LET cDescripcion = '';
	LET cFecha = '';
	LET cValor = 0;
	LET cPromedio = 0;	
	LET iNumRegistros = 0;
	LET iRecuperacion = 0;	
	LET cDesConsulta = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constasatabular.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		LET cDesConsulta = "%" || TRIM(pDescripcion) || "%";
		
   	    FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion a.tasa, a.descripcion, b.fecha, b.valor, b.promedio
			INTO cTasa, cDescripcion, cFecha, cValor, cPromedio
			FROM bdinteg:"informix".si_tiptasa a 
			INNER JOIN bdinteg:"informix".si_fechavalor b
			ON a.tasa = b.tasa
			WHERE  a.empresa = cEmpresa 	
			AND a.descripcion LIKE cDesConsulta
	
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cTasa, cDescripcion, cFecha, cValor, cPromedio;
		END IF;							
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA', 
'DESCRIPCION: SPL que realiza la consulta para llenado de pantalla: Consulta Tasas por Fecha (Tabular)',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constasatabular_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30))
		RETURNING CHAR(5) AS codret,
			INTEGER AS totalregistros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	DEFINE cDesConsulta CHAR(30);		
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	LET cDesConsulta = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constasatabular_totales.out';
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
		
		LET cDesConsulta = "%" || TRIM(pDescripcion) || "%";
		
   	    SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdinteg:"informix".si_tiptasa a 
		INNER JOIN bdinteg:"informix".si_fechavalor b
		ON a.tasa = b.tasa
		WHERE  a.empresa = cEmpresa 	
		AND a.descripcion like cDesConsulta;

		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		RETURN cCodRet, iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo ',
'FECHA: 10/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CATÃLOGO DE TASAS POR FECHA', 
'DESCRIPCION: SPL que realiza la consulta del total de registros de pantalla Consulta Tasas por Fecha (Tabular)',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/12/2017',
'DESCRIPCION: Se realiza el cambio de base de las estructuras utilizadas de bdicont a bdinteg y se agrega la capa de seguridad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalctasmontobeneficencia( pUsuario      CHAR(8), 
                                                           pIdFuncion    CHAR(10), 
                                                           pNumDiasSMVDF SMALLINT)
RETURNING CHAR(5)        AS codret,
          INTEGER        AS total_cuentas,
          DECIMAL(14, 2) AS total_saldo_concentrado;
    
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE dValorSM DECIMAL(14,2);
    DEFINE iTotalCuentas INTEGER;
    DEFINE dTotalSaldo DECIMAL(14,2);
    DEFINE iNoAnios SMALLINT;
    
    LET cCodRet = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
    LET dValorSM = 0.0;
    LET iTotalCuentas = 0;
    LET dTotalSaldo = 0.0;
    LET iNoAnios = 3;
    
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/sp_totalctasmontobeneficencia.err';
        TRACE ON;
        LET cCodRet = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet, iTotalCuentas, dTotalSaldo;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/sp_totalctasmontobeneficencia.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pUsuario = '' OR pIdFuncion = '' OR pNumDiasSMVDF IS NULL THEN
        LET cCodRet = '00003';
        RETURN cCodRet, iTotalCuentas, dTotalSaldo;
    END IF;
    
    -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
    EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, iTotalCuentas, dTotalSaldo;
    END IF;
    
    SELECT valor * pNumDiasSMVDF
      INTO dValorSM
      FROM bdicheq:sc_param
     WHERE codparam = 'smdf';
    
    -- CONSULTA DE TOTAL DE CUENTAS Y TOTAL DE SALDO CONCENTRADO
    SELECT COUNT(con.cuenta), SUM(con.sdo_concentrado)
      INTO iTotalCuentas, dTotalSaldo
      FROM bdicheq:sc_cuentas_concentradas con, 
           bdicheq:sc_maechq mae,
           bdicheq:sc_fechas fec
    --- WHERE DATE(con.fecha_concentra) <= DATE(CURRENT) - (365 * iNoAnios)
     WHERE DATE(con.fecha_concentra) <= DATE((fec.pri_dia_mes - 1 UNITS DAY)) - (365 * iNoAnios)
       AND con.cuenta = mae.cuenta
       AND mae.status_cta = 6
       AND (con.sdo_concentrado >= 0 AND con.sdo_concentrado <= dValorSM)
       AND fec.empresa = mae.empresa;
        
    IF iTotalCuentas = 0 THEN
        LET cCodRet = '00429';
    END IF;
        
    RETURN cCodRet, iTotalCuentas, dTotalSaldo;
    
	END;
	
END PROCEDURE
    
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2014',
'DESCRIPCION: Consulta el total de cuentas y total de saldos que seran traspasados a la cuenta de beneficiencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacentrocostosatms(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(4) AS id_CentroCostos;		
		
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSp 		CHAR(6);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cMensaje         CHAR(30);
	DEFINE cIdCentroCostos 	CHAR(4);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iRecuperacion    INTEGER;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '000000';
	LET iCodRetSp 		= 0;
	LET cMensaje 		= '';
	LET cIdCentroCostos = 0;
	LET iNoRegistros 	= 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdCentroCostos;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacentrocostosatms.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCentroCostos;
		END IF;
		
		 -- VALIDACION DE LA PAGINACION
        IF pRegistros < 0 OR pRecuperacion < 0 THEN
            LET cCodRet = '00098';
			RETURN cCodRet, cIdCentroCostos;
        END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCentroCostos;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE bdisuc:"informix".sp_soc_combocc_atm2(pRegistros,pRecuperacion)
			INTO cCodRetSp, cMensaje, cIdCentroCostos
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisuc.sp_soc_combocc_atm2";
			END IF;
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cIdCentroCostos WITH RESUME;		
		END FOREACH;
		
		 IF iRecuperacion = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cIdCentroCostos;
        ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
           LET cCodRet = '1001';
			RETURN cCodRet, cIdCentroCostos;
        END IF;
    END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Hernández Pérez',
'FECHA: 19/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Catalogo de ATM´S',
'DESCRIPCION: SPL que consulta los id de centro de costos para el catálogo de  atm´s ',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 18/SEP/2017',
'DESCRIPCION: Se agrega parametros de paginado',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 19/12/2017',
'DESCRIPCION: Se Modifican variables de paginado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cattipofechas(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		SMALLINT AS id_tipo,
		CHAR(35) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdTipo SMALLINT;
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdTipo = 0;
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdTipo, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cattipofechas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdTipo, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdTipo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_tipo, descripcion
			INTO iIdTipo, cDescripcion
			FROM bdicnweb:"informix".sw_tipos_fechas ORDER BY id_tipo ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdTipo, TRIM(cDescripcion) WITH RESUME;	
		END FOREACH;
	
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdTipo, cDescripcion;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 18/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el detalle del catálogo tipo de fechas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallefacturacionos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCte CHAR(9), 
pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoFecha SMALLINT, pTipoConsulta SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS sucursal,
			INTEGER AS total_enviadas,
			INTEGER AS impresas_n, 
			DECIMAL(5,2) AS impresas_p,
			INTEGER AS no_impresas_n, 
			DECIMAL(5,2) AS no_impresas_p,
			INTEGER AS statusA_n, 
			DECIMAL(5,2) AS statusA_p,
			INTEGER AS statusR_n, 
			DECIMAL(5,2) AS statusR_p,
			INTEGER AS statusD_n, 
			DECIMAL(5,2) AS statusD_p,
			INTEGER AS statusS_n, 
			DECIMAL(5,2) AS statusS_p,
			INTEGER AS bancoppel, 
			INTEGER AS coppel,
			INTEGER AS mixta, 
			INTEGER AS total;	
	
	DEFINE cCodRet 		  CHAR(5);
	DEFINE iSqlErr 		  INTEGER;
	DEFINE cCodRetSp 	  CHAR(6);
	DEFINE cDesCodRetSp   CHAR(50);
	DEFINE cEmpresa 	  CHAR(3);
	DEFINE cSucursal      CHAR (4);
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iImpresas      INTEGER;
	DEFINE dImpresasPor   DECIMAL(5,2);
	DEFINE iNoImpresas    INTEGER;
	DEFINE dNoImpresasPor DECIMAL(5,2);
	DEFINE iStatusA       INTEGER;
	DEFINE dStatusAPor    DECIMAL(5,2);
	DEFINE iStatusR       INTEGER;
	DEFINE dStatusRPor    DECIMAL(5,2);
	DEFINE iStatusD       INTEGER;
	DEFINE dStatusDPor    DECIMAL(5,2);
	DEFINE iStatusS       INTEGER;
	DEFINE dStatusSPor    DECIMAL(5,2);
	DEFINE iBancoppel     INTEGER;
	DEFINE iCoppel        INTEGER;
	DEFINE iMixta         INTEGER;
	DEFINE iTotal         INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet 		  = '00000';
	LET iSqlErr           = 0;
	LET cCodRetSp 		  = '';
	LET cDesCodRetSp 	  = '';
	LET cEmpresa 		  = '001';
	LET cSucursal         = '';
	LET iTotalEnviadas    = 0;
	LET iImpresas         = 0;
	LET dImpresasPor      = 0;
	LET iNoImpresas       = 0;
	LET dNoImpresasPor    = 0;
	LET iStatusA          = 0;
	LET dStatusAPor       = 0;
	LET iStatusR          = 0;
	LET dStatusRPor       = 0;
	LET iStatusD          = 0;
	LET dStatusDPor       = 0;
	LET iStatusS          = 0;
	LET dStatusSPor       = 0;
	LET iBancoppel        = 0;
	LET iCoppel           = 0;
	LET iMixta            = 0;
	LET iTotal            = 0;
	LET iRecuperacion     = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallefacturacionos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pTipoFecha IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion
			sucursal,total_enviadas,impresas_n,impresas_p,no_impresas_n,no_impresas_p,
			statusA_n,statusA_p,statusR_n,statusR_p,statusD_n,statusD_p,statusS_n,statusS_p,bancoppel,coppel,mixta,total
			INTO cSucursal, iTotalEnviadas, iImpresas, dImpresasPor, iNoImpresas, dNoImpresasPor, iStatusA, dStatusAPor, 
			iStatusR, dStatusRPor, iStatusD, dStatusDPor, iStatusS, dStatusSPor, iBancoppel, iCoppel, iMixta, iTotal
			FROM bdicnweb:"informix".sw_facturacion_os
			WHERE usuario_insert = pUsuario ORDER BY sucursal ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, NVL(cSucursal,''), NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 20/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el detalle de las facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consnomcliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pCliente CHAR(20))
    RETURNING CHAR(5) AS codRet,
		CHAR(107) AS nombre_cte;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreCte CHAR(107);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreCte = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreCte;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consnomcliente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreCte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreCte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		 
		SELECT TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2)
		INTO cNombreCte 
		FROM bdinteg:"informix".si_cliente 
		WHERE empresa = cEmpresa AND numcte = pCliente;
		
		IF NVL(cNombreCte,'') = '' THEN
			LET cCodRet = '00088';
		END IF;
		
		RETURN cCodRet,TRIM(UPPER(cNombreCte));
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 18/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el nombre de la sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consnomsucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSuc CHAR(40);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSuc = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consnomsucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT nombre 
		INTO cNombreSuc 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF NVL(cNombreSuc,'') = '' THEN
			LET cCodRet = '00833';
		END IF;
		
		RETURN cCodRet,TRIM(UPPER(cNombreSuc));
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 18/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el nombre de la sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesfacturacionos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCte CHAR(9), 
pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoFecha SMALLINT, pTipoConsulta SMALLINT)
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_enviadas,
			INTEGER AS impresas_n, 
			DECIMAL(10,2) AS impresas_p,
			INTEGER AS no_impresas_n, 
			DECIMAL(10,2) AS no_impresas_p,
			INTEGER AS statusA_n, 
			DECIMAL(10,2) AS statusA_p,
			INTEGER AS statusR_n, 
			DECIMAL(10,2) AS statusR_p,
			INTEGER AS statusD_n, 
			DECIMAL(10,2) AS statusD_p,
			INTEGER AS statusS_n, 
			DECIMAL(10,2) AS statusS_p,
			INTEGER AS bancoppel, 
			INTEGER AS coppel,
			INTEGER AS mixta, 
			INTEGER AS total;	
	
	DEFINE cCodRet 		  CHAR(5);
	DEFINE iSqlErr 		  INTEGER;
	DEFINE cCodRetSp 	  CHAR(6);
	DEFINE cDesCodRetSp   CHAR(50);
	DEFINE cEmpresa 	  CHAR(3);
	DEFINE cSucursal      CHAR (4);
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iImpresas      INTEGER;
	DEFINE dImpresasPor   DECIMAL(10,2);
	DEFINE iNoImpresas    INTEGER;
	DEFINE dNoImpresasPor DECIMAL(10,2);
	DEFINE iStatusA       INTEGER;
	DEFINE dStatusAPor    DECIMAL(10,2);
	DEFINE iStatusR       INTEGER;
	DEFINE dStatusRPor    DECIMAL(10,2);
	DEFINE iStatusD       INTEGER;
	DEFINE dStatusDPor    DECIMAL(10,2);
	DEFINE iStatusS       INTEGER;
	DEFINE dStatusSPor    DECIMAL(10,2);
	DEFINE iBancoppel     INTEGER;
	DEFINE iCoppel        INTEGER;
	DEFINE iMixta         INTEGER;
	DEFINE iTotal         INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet 		  = '00000';
	LET iSqlErr           = 0;
	LET cCodRetSp 		  = '';
	LET cDesCodRetSp 	  = '';
	LET cEmpresa 		  = '001';
	LET cSucursal         = '';
	LET iTotalEnviadas    = 0;
	LET iImpresas         = 0;
	LET dImpresasPor      = 0;
	LET iNoImpresas       = 0;
	LET dNoImpresasPor    = 0;
	LET iStatusA          = 0;
	LET dStatusAPor       = 0;
	LET iStatusR          = 0;
	LET dStatusRPor       = 0;
	LET iStatusD          = 0;
	LET dStatusDPor       = 0;
	LET iStatusS          = 0;
	LET dStatusSPor       = 0;
	LET iBancoppel        = 0;
	LET iCoppel           = 0;
	LET iMixta            = 0;
	LET iTotal            = 0;
	LET iRecuperacion     = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesfacturacionos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pTipoFecha IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
			NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT NVL(SUM(total_enviadas),0),NVL(SUM(impresas_n),0),NVL(SUM(impresas_p),0),NVL(SUM(no_impresas_n),0),NVL(SUM(no_impresas_p),0),
		NVL(SUM(statusA_n),0),NVL(SUM(statusA_p),0),NVL(SUM(statusR_n),0),NVL(SUM(statusR_p),0),NVL(SUM(statusD_n),0),NVL(SUM(statusD_p),0),
		NVL(SUM(statusS_n),0),NVL(SUM(statusS_p),0),NVL(SUM(bancoppel),0),NVL(SUM(coppel),0),NVL(SUM(mixta),0),NVL(SUM(total),0)
		INTO iTotalEnviadas, iImpresas, dImpresasPor, iNoImpresas, dNoImpresasPor, iStatusA, dStatusAPor, iStatusR, dStatusRPor, 
		iStatusD, dStatusDPor, iStatusS, dStatusSPor, iBancoppel, iCoppel, iMixta, iTotal
		FROM bdicnweb:"informix".sw_facturacion_os
		WHERE usuario_insert = pUsuario;
		
		RETURN cCodRet, NVL(iTotalEnviadas,0), NVL(iImpresas,0), NVL(dImpresasPor,0), NVL(iNoImpresas,0), NVL(dNoImpresasPor,0), NVL(iStatusA,0), NVL(dStatusAPor,0), 
		NVL(iStatusR,0), NVL(dStatusRPor,0), NVL(iStatusD,0), NVL(dStatusDPor,0), NVL(iStatusS,0), NVL(dStatusSPor,0), NVL(iBancoppel,0), NVL(iCoppel,0), NVL(iMixta,0), NVL(iTotal,0);
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 21/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el total general de las facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusfacturacionos(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusfacturacionos.out';
		--TRACE ON;
		
		--VALIDACION DE CAMPOS REQUERIDOS
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
		FROM bdicnweb:"informix".sw_statusproceso_os 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 21/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de verificar el status de la consulta de facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catstatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		CHAR(1) AS status,
		CHAR(35) AS desc_status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cStatus = '';
	LET cDescStatus = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cStatus, cDescStatus;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catstatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cDescStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			SELECT status, desc_status 
			INTO cStatus, cDescStatus
			FROM bdicnweb:"informix".sw_cat_status 
			ORDER BY id ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, TRIM(cStatus), TRIM(cDescStatus) WITH RESUME;		
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cStatus, cDescStatus;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 28/09/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE CUENTAS',
'DESCRIPCION: Spl encargado de consultar el detalle del catálogo estatus.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactualizaparamlimctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pCodParam CHAR(20), pValor CHAR(60))
    RETURNING CHAR(5) AS codRet,
		CHAR(60) AS valor_param;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValorParam CHAR(60);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cValorParam = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cValorParam;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultactualizaparamlimctas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pCodParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParam;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Consulta
		IF pIdEjecucion = '1' THEN
		
			SELECT valor INTO cValorParam
			FROM bdicheq:"informix".sc_param WHERE empresa = cEmpresa AND codparam = TRIM(pCodParam);
			
			IF NVL(cValorParam,'') = '' THEN
				LET cCodRet = '00017';
			END IF;
		
		-- Actualiza
		ELIF pIdEjecucion = '2' THEN
		
			IF pValor = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cValorParam;
			END IF;
		
			UPDATE bdicheq:"informix".sc_param SET valor = TRIM(pValor)
			WHERE empresa = cEmpresa AND codparam = TRIM(pCodParam);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, TRIM(cValorParam);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 28/09/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE CUENTAS',
'DESCRIPCION: Spl encargado de consultar/actualizar el límite máximo de cuentas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactualizastatuscliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pCliente CHAR(20), pStatus CHAR(1))
    RETURNING CHAR(5) AS codRet,
		CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cStatus CHAR(1);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cStatus = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cStatus;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultactualizastatuscliente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Consulta
		IF pIdEjecucion = '1' THEN
		
			SELECT status INTO cStatus
			FROM bdicheq:"informix".sc_limite_cuentas WHERE numero_cliente = TRIM(pCliente);
			
			IF NVL(cStatus,'') = '' THEN
				LET cCodRet = '90000'; --EL CLIENTE NO ESTÁ EXCENTO DEL LÍMITE DE CUENTAS, ¿DESEA DARLO DE ALTA?
			END IF;
		
		-- Inserta
		ELIF pIdEjecucion = '2' THEN
			
			INSERT INTO bdicheq:"informix".sc_limite_cuentas(numero_cliente,status,usuario,fecha)
			VALUES(TRIM(pCliente),'1',pUsuario,DATE(CURRENT));
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
		
		-- Actualiza
		ELIF pIdEjecucion = '3' THEN
			
			IF pStatus = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cStatus;
			END IF;
		
			UPDATE bdicheq:"informix".sc_limite_cuentas 
			SET status = TRIM(pStatus), usuario = pUsuario, fecha = DATE(CURRENT)
			WHERE numero_cliente = TRIM(pCliente);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, TRIM(cStatus);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 28/09/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE CUENTAS',
'DESCRIPCION: Spl encargado de consultar/insertar/actualizar la vigencia del cliente.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_limpiatablas(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pDireccionMac CHAR(12), pNombreArchivo CHAR(35), pIdEjecucion CHAR(1))
	RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_limpiatablas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' OR pIdEjecucion = '' THEN
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
		
		-- Limpia Tabla Nomenclatura Archivo
		IF pIdEjecucion = '1' THEN
		
			IF EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_cp_nomarchivotdc WHERE nombre_archivo = pNombreArchivo) THEN 
				DELETE FROM bdicnweb:"informix".sw_cp_nomarchivotdc WHERE nombre_archivo = pNombreArchivo;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00540'; --ERROR AL LIMPIAR LA INFORMACIÓN EN LAS TABLAS DE PASO
				END IF;
			END IF;
			
		-- Limpia Tabla Bitácora Errores Carga
		ELIF pIdEjecucion = '2' THEN
		
			IF EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc WHERE nombre_archivo = pNombreArchivo) THEN 
				DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc WHERE nombre_archivo = pNombreArchivo;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00540'; --ERROR AL LIMPIAR LA INFORMACIÓN EN LAS TABLAS DE PASO
				END IF;
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/05/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de limpiar tablas que fueron utilizadas para el tratado de información al momento de',
'hacer el cambio de producto Op. Masiva.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_graba_prod_upgrade(pUsuario CHAR(8), pIdFuncion CHAR(10), pCredito CHAR(20), pNumCte CHAR(20), pNumTarjeta CHAR(20),pTit CHAR(3), pNombre CHAR(107),
pEmbozado CHAR(21), pMaster CHAR(1), pTipoDomicilio CHAR(1), pTipoProceso CHAR(1), pNombreArchivo CHAR(100), pProdUpgrade CHAR(4))																				--1 Manual 2 Masivo 3 Sucursal
	RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescripcion CHAR(100);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cDescripcion = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_graba_prod_upgrade.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoProceso = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_graba_prod_upgrade(cEmpresa, pCredito, pNumCte, pNumTarjeta, pTit, pNombre, 
		pEmbozado, pMaster, pTipoDomicilio, pUsuario, pTipoProceso, pNombreArchivo, pProdUpgrade)		
		INTO cCodRetSp, cDescripcion;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP: bdicred:sp_graba_prod_upgrade";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00972';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO QUE GRABA LA INFORMACION DE LAS TARJETAS ORO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consulta_saldos_general(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(20)      AS numero_credito,
		CHAR(2)       AS codigo_tipcred,
		DATE          AS fecha_origen,
		DATE          AS fecha_prox_pago,
		DECIMAL(18,2) AS pago_minimo,
		DATE          AS fecha_ult_pago,
		INTEGER       AS plazo,
		INTEGER       AS pagos_realizados,
		DECIMAL(18,2) AS linea_otorgada,
		DECIMAL(9,6)  AS tasa_interes,
		DECIMAL(9,6)  AS tasa_moratorios,
		DECIMAL(14,2) AS monto_sbc,
		DECIMAL(18,2) AS cap_vig,
		DECIMAL(18,2) AS cap_trans,
		DECIMAL(18,2) AS cap_vdo_exig,
		DECIMAL(18,2) AS cap_vdo_no_exig,
		DECIMAL(18,2) AS sdo_act_total_cap,
		DECIMAL(18,2) AS int_vig,
		DECIMAL(18,2) AS int_vdo,
		DECIMAL(18,2) AS int_moratorios,
		DECIMAL(18,2) AS int_mes,
		DECIMAL(18,2) AS sdo_act_total_int,
		DECIMAL(18,2) AS iva_int_vig,
		DECIMAL(18,2) AS iva_int_vdo,
		DECIMAL(18,2) AS iva_int_moratorios,
		DECIMAL(18,2) AS iva_int_mes,
		DECIMAL(18,2) AS sdo_act_total_iva,
		DECIMAL(18,2) AS com_pend,
		DECIMAL(18,2) AS iva_com,
		DECIMAL(18,2) AS sdo_retenido,
		DECIMAL(18,2) AS total_liquidacion,
		DECIMAL(18,2) AS int_devengado,
		DECIMAL(18,2) AS iva_int_devengado,
		DECIMAL(18,2) AS linea_disponible,
		DECIMAL(18,2) AS pagos_vdos,
		CHAR(60)      AS desc_status_cred,
		INTEGER       AS id_bloqueo_cred,
		CHAR(60)      AS bloqueo_cta,
		CHAR(3)       AS id_causa_bloqueo_cred,
		CHAR(50)      AS causa_bloqueo_cta,
		CHAR(1)       AS id_sit_esp_cte,
		INTEGER       AS id_causa_esp_cte,
		CHAR(75)      AS sit_esp_cte,
		CHAR(1)       AS id_sit_esp_cred,
		INTEGER       AS id_causa_esp_cred,
		CHAR(75)      AS sit_esp_cred;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRet       CHAR(80);         
	DEFINE cNumCredito       CHAR(20);         
	DEFINE cCodTipCred       CHAR(2);          
	DEFINE dtFechaOrigen     DATE;             
	DEFINE dtFechaProxPago   DATE;             
	DEFINE dPagoMinimo       DECIMAL(18,2);    
	DEFINE dtFechaUltPago    DATE;             
	DEFINE iPlazo            INTEGER;          
	DEFINE iPagosRealizados  INTEGER;          
	DEFINE dLineaOtorgada    DECIMAL(18,2);    
	DEFINE dTasaInteres      DECIMAL(9,6);     
	DEFINE dTasaMoratorios   DECIMAL(9,6);     
	DEFINE dMontoSBC         DECIMAL(14,2);    
	DEFINE dCapVig           DECIMAL(18,2);    
	DEFINE dCapTrans         DECIMAL(18,2);    
	DEFINE dCapVdoExig       DECIMAL(18,2);    
	DEFINE dCapVdoNoExig     DECIMAL(18,2);    
	DEFINE dSdoActCap        DECIMAL(18,2);    
	DEFINE dIntVig           DECIMAL(18,2);    
	DEFINE dIntVdo           DECIMAL(18,2);    
	DEFINE dIntMoratorio     DECIMAL(18,2);    
	DEFINE dIntMes           DECIMAL(18,2);    
	DEFINE dSdoActInt        DECIMAL(18,2);    
	DEFINE dIvaIntVig        DECIMAL(18,2);    
	DEFINE dIvaIntVdo        DECIMAL(18,2);    
	DEFINE dIvaIntMoratorio  DECIMAL(18,2);    
	DEFINE dIvaIntMes        DECIMAL(18,2);    
	DEFINE dSdoActIvaInt     DECIMAL(18,2);    
	DEFINE dComPend          DECIMAL(18,2);    
	DEFINE dIvaCom           DECIMAL(18,2);    
	DEFINE dSdoRetenido      DECIMAL(18,2);    
	DEFINE dSdoTotalLiq      DECIMAL(18,2);    
	DEFINE dIntDevengado     DECIMAL(18,2);
	DEFINE dIvaIntDevengado  DECIMAL(18,2);
	DEFINE dLineaDisponible  DECIMAL(18,2);
	DEFINE dPagosVdos        DECIMAL(18,2);
	DEFINE cDescStatusCred   CHAR(60);         
	DEFINE iIdUnidadProd     INTEGER;          
	DEFINE cDescBloqueoCta   CHAR(60);     
	DEFINE cCodCaract2       CHAR(3);          
	DEFINE cDescCausaBloqueoCta CHAR(50);     
	DEFINE cSitCte           CHAR(1);      
	DEFINE cCausaCte         INTEGER;      
	DEFINE cDescSitEspCte    CHAR(75);     
	DEFINE cSitCred          CHAR(1);      
	DEFINE cCausaCred        INTEGER;      
	DEFINE cDescSitEspCred   CHAR(75); 	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp  = '';
	LET cEmpresa = '001';
	LET cMensajeRet      = '';
	LET cNumCredito      = '';
	LET cCodTipCred      = '';
	LET dtFechaOrigen    = DATE(1);
	LET dtFechaProxPago  = DATE(1);
	LET dPagoMinimo      = 0;
	LET dtFechaUltPago   = DATE(1);
	LET iPlazo           = 0;
	LET iPagosRealizados = 0;
	LET dLineaOtorgada   = 0;	
	LET dTasaInteres     = 0;
	LET dTasaMoratorios  = 0;
	LET dMontoSBC        = 0;              
	LET dCapVig          = 0;
	LET dCapTrans        = 0;
	LET dCapVdoExig      = 0;
	LET dCapVdoNoExig    = 0;
	LET dSdoActCap       = 0;              
	LET dIntVig          = 0;
	LET dIntVdo          = 0;
	LET dIntMoratorio    = 0;
	LET dIntMes          = 0;
	LET dSdoActInt       = 0;              
	LET dIvaIntVig       = 0;
	LET dIvaIntVdo       = 0;
	LET dIvaIntMoratorio = 0;
	LET dIvaIntMes       = 0;
	LET dSdoActIvaInt    = 0;              
	LET dComPend         = 0;
	LET dIvaCom          = 0;
	LET dSdoRetenido     = 0;
	LET dSdoTotalLiq     = 0;
	LET dIntDevengado    = 0;
	LET dIvaIntDevengado = 0;
	LET dLineaDisponible = 0;
	LET dPagosVdos       = 0;
	LET cDescStatusCred  = '';              
	LET iIdUnidadProd    = 0;
	LET cDescBloqueoCta  = '';
	LET cCodCaract2      = '';
	LET cDescCausaBloqueoCta  = '';
	LET cSitCte          = '';
	LET cCausaCte        = 0;
	LET cDescSitEspCte   = '';
	LET cSitCred         = '';
	LET cCausaCred       = 0;
	LET cDescSitEspCred  = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCredito, cCodTipCred,dtFechaOrigen, dtFechaProxPago,
				   dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
				   dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
				   dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
				   dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
				   dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
				   dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,
				   cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
				   cCausaCred, cDescSitEspCred;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consulta_saldos_general.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCredito, cCodTipCred,dtFechaOrigen, dtFechaProxPago,
				   dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
				   dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
				   dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
				   dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
				   dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
				   dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,
				   cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
				   cCausaCred, cDescSitEspCred;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCredito, cCodTipCred,dtFechaOrigen, dtFechaProxPago,
				   dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
				   dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
				   dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
				   dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
				   dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
				   dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,
				   cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
				   cCausaCred, cDescSitEspCred;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, pNumCredito)
		INTO cCodRetSp, cDescCodRetSp, cNumCredito, cCodTipCred,dtFechaOrigen, dtFechaProxPago,
			 dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados, dLineaOtorgada,
			 dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig,
			 dCapVdoNoExig, dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes,
			 dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio, dIvaIntMes, dSdoActIvaInt,
			 dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, dLineaDisponible,
			 dPagosVdos, cDescStatusCred, iIdUnidadProd, cDescBloqueoCta, cCodCaract2,
			 cDescCausaBloqueoCta, cSitCte, cCausaCte, cDescSitEspCte, cSitCred,
			 cCausaCred, cDescSitEspCred;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:dbicred:sp_consulta_saldos_general";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';			
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00046';				
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00046';		
		ELIF iCodRetSp = 5 THEN	
			LET cCodRet = '00208';
		ELIF iCodRetSp = 7 THEN
			LET cCodRet = '00889';
		ELIF iCodRetSp = 8 THEN		 
			LET cCodRet = '00889';
		END IF;
		
		RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
			   NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
			   NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
			   NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
			   NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
			   NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
			   NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
			   NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
			   NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');

	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECTA UN SP PRODUCTIVO QUE HACE EL LLENADO VALIDACION DE LA CUENTA SI SE ENCUENTRA ACTIVA O NO ESTA VENCIDA',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultaproductos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSiglaProd CHAR(2) ,pSiglaProdUp CHAR(2))
		RETURNING CHAR(5) AS codret,		
	    CHAR(4) AS numero_producto,
		CHAR(100) AS nombre_producto;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumProducto  CHAR(4);
	DEFINE vNomProducto  CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDescCodRetSp  = '';
	LET iCodRetSp = 0;
	LET cNumProducto  = '';
	LET vNomProducto  = '';
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, vNomProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultaproductos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSiglaProd = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, vNomProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumProducto, vNomProducto;
		END IF;
		
		FOREACH		
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_prod_upgrade(cEmpresa, pSiglaProd ,pSiglaProdUp)
			INTO cCodRetSp, cDescCodRetSp, vNomProducto, cNumProducto
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_consulta_prod_upgrade";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, NVL(cNumProducto,''), NVL(UPPER(vNomProducto),'') WITH RESUME;
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, NVL(cNumProducto,''), NVL(UPPER(vNomProducto),'');
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO QUE HACE EL LLENADO DEL COMBO PRODUCTO ORO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadomicilios(pUsuario CHAR(8), pIdFuncion CHAR(10),pTpoEjec CHAR(1))
		RETURNING CHAR(5) AS codret,	
                  CHAR(4) AS tipo_dir,
                  CHAR(40) AS desc_tipo_dir;		
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoDir     CHAR(4);
	DEFINE cDescTipoDir CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoDir     = "";
	LET cDescTipoDir = "";
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoDir, cDescTipoDir;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadomicilios.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTpoEjec = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoDir, cDescTipoDir;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoDir, cDescTipoDir;
		END IF;	
	
		FOREACH	-- pTpoEjec = 1 Domicilios  OR  pTpoEjec = 2 Sucursales
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_dom_upgrade(pTpoEjec)
			INTO cCodRetSp, cTipoDir, cDescTipoDir 
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_consulta_prod_upgrade";		
			ELIF iCodRetSp = 1 OR iCodRetSp = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, NVL(cTipoDir,''), NVL(UPPER(cDescTipoDir),'');
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, NVL(cTipoDir,''), NVL(UPPER(cDescTipoDir),'') WITH RESUME;
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, NVL(cTipoDir,''), NVL(UPPER(cDescTipoDir),'');
		END IF;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO QUE HACE EL LLENADO DEL CATALOGO DE DOMICILIO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadeterrores_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadeterrores_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' THEN
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

		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = TRIM(pNombreArchivo);

		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;

		RETURN cCodRet,iNumRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA',
'DESCRIPCION: SPL encargado de consultar el número total de los errores encontrados en el archivo seleccionado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadeterrores(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS linea,
		CHAR(35) AS campo,
		CHAR(120) AS mensaje_error;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDescMensaje CHAR(120);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDescMensaje = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadeterrores.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion linea, campo, mensaje_error
			INTO iLinea, cCampo, cDescMensaje
			FROM bdicnweb:"informix".sw_cp_bitacoraerrortdc 
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = TRIM(pNombreArchivo)
			ORDER BY id_serial ASC

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,NVL(iLinea,''),NVL(TRIM(cCampo),''),NVL(UPPER(TRIM(cDescMensaje)),'') WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,iLinea,cCampo,cDescMensaje;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar el detalle de los errores encontrados en el archivo seleccionado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_obtensolicitudmaquilatdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20), 
pTipoEnvio CHAR (1), pSucursal CHAR(5), pTpoMaquila CHAR(1),    pTpoEjecucion CHAR(1), pEjecutivo CHAR(10))	
	RETURNING CHAR(5) AS codret,
		 CHAR(1) AS tpoenvio ,
		 CHAR(5) AS sucursal,
		 CHAR(1) AS tpomaquila,
		 CHAR(20) AS numcte,
		 CHAR(20) AS num_credito,
		 CHAR(20) AS nomcliente1,
		 CHAR(20) AS nomcliente2,
		 CHAR(20) AS apellpatcliente,
		 CHAR(20) AS apellmatcliente,
		 CHAR(30) AS dir_calle1  ,
		 CHAR(30) AS dir_calle2,
		 CHAR(50) AS dir_colonia,
		 CHAR(15) AS dir_municipio,
		 CHAR(13) AS dir_estado,
		 CHAR(5) AS dir_cp,
		 CHAR(2) AS tipotarjeta,
		 CHAR(6) AS bintarjeta,
         CHAR(3) AS codproducto,
		 CHAR(1) AS fimagen,
		 CHAR(5) AS idimagen,
		 CHAR(1) AS fmaster,
		 CHAR(1) AS ftitular,
		 CHAR(1) AS femision,
		 CHAR(2) AS membersince,
		 CHAR(1) AS welcomekit,
		 CHAR(5) AS cat,
		 CHAR(5) AS inanuord,
		 CHAR(5) AS inanumor,
		 CHAR(6) AS lineacredito,
		 CHAR(5) AS cant_solicitadas,
		 CHAR(19) AS fecha_sol,
		 CHAR(9) AS num_empleado,
		 CHAR(1) AS enviasms,
		 CHAR(16) AS numtarjeta,
		 CHAR(30) AS canal,
		 CHAR(4) AS producto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE ctpoenvio CHAR(1);                                 
	DEFINE csucursal CHAR(5);                                 
	DEFINE ctpomaquila CHAR(1);                               
	DEFINE cnumcte CHAR(20);                                  
	DEFINE cnum_credito CHAR(20);                                             
	DEFINE cnomcliente1 CHAR(20);                             
	DEFINE cnomcliente2 CHAR(20);                             
	DEFINE capellpatcliente CHAR(20);                         
	DEFINE capellmatcliente CHAR(20);                         
	DEFINE cnombre_embosado CHAR(21);                         
	DEFINE cdir_calle1 CHAR(30);                              
	DEFINE cdir_calle2 CHAR(30);                              
	DEFINE cdir_colonia CHAR(50);                             
	DEFINE cdir_municipio CHAR(15);                           
	DEFINE cdir_estado CHAR(13);                              
	DEFINE cdir_cp CHAR(5);                                   
	DEFINE ctipotarjeta CHAR(2);                              
	DEFINE cbintarjeta CHAR(6);                               
	DEFINE ccodproducto CHAR(3);                              
	DEFINE cfimagen CHAR(1);                                  
	DEFINE cidimagen CHAR(5);                                 
	DEFINE cfmaster CHAR(1);                                  
	DEFINE cftitular CHAR(1);                                 
	DEFINE cfemision CHAR(1);                                 
	DEFINE cmembersince CHAR(2);                              
	DEFINE cwelcomekit  CHAR(1);                              
	DEFINE ccat  CHAR(5);                                     
	DEFINE cinanuord CHAR(5);                                 
	DEFINE cinanumor CHAR(5);                                 
	DEFINE clineacredito CHAR(6);                             
	DEFINE ccant_solicitadas CHAR(5);                         
	DEFINE cfecha_sol CHAR(19);                               
	DEFINE cnum_empleado CHAR(9);                             
	DEFINE cenviasms CHAR(1);                                 
	DEFINE cnumtarjeta CHAR(16);                              
	DEFINE ccanal CHAR(30);                                   
	DEFINE cuser_insert CHAR(8);                              
	DEFINE dfecha_insert DATETIME YEAR to FRACTION(3);        
	DEFINE cnum_producto    CHAR(4);                          
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET ctpoenvio = ptipoenvio;
	LET csucursal = '';
	LET ctpomaquila = ptpomaquila;
	LET cnumcte = '';
	LET cnum_credito = '';	
	LET cnomcliente1 = '';
	LET cnomcliente2 = '';
	LET capellpatcliente = '';
	LET capellmatcliente = '';
	LET cnombre_embosado = '';
	LET cdir_calle1 = '';
	LET cdir_calle2 = '';
	LET cdir_colonia = '';
	LET cdir_municipio = '';
	LET cdir_estado = '';
	LET cdir_cp = '';
	LET ctipotarjeta = '';
	LET cbintarjeta = '';
	LET ccodproducto = '';
	LET cfimagen = 'F';
	LET cidimagen = '';
	LET cfmaster = 'V';
	LET cftitular = '';
	LET cfemision = '';
	LET cmembersince = '';
	LET cwelcomekit  = 'V';
	LET ccat  = '';
	LET cinanuord = '';
	LET cinanumor = '';
	LET clineacredito = '';
	LET ccant_solicitadas = '1';
	LET cfecha_sol = CURRENT YEAR TO SECOND;
	LET cnum_empleado = pejecutivo;
	LET cenviasms = 'F';
	LET cnumtarjeta = '';
	LET ccanal = '';
	LET cuser_insert = user;
	LET dfecha_insert = CURRENT YEAR TO SECOND;
	LET cnum_producto = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,ctpoenvio,csucursal,ctpomaquila,cnumcte,cnum_credito,cnomcliente1,cnomcliente2,capellpatcliente,
				   capellmatcliente,cdir_calle1,cdir_calle2,cdir_colonia,cdir_municipio,cdir_estado,cdir_cp,ctipotarjeta,cbintarjeta,
				   ccodproducto,cfimagen,cidimagen,cfmaster,cftitular,cfemision,cmembersince,cwelcomekit,ccat,cinanuord,cinanumor,
				   clineacredito,ccant_solicitadas,cfecha_sol,cnum_empleado,cenviasms,cnumtarjeta,ccanal,cnum_producto;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_obtensolicitudmaquilatdc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNumCte = '' OR pNumCredito = '' OR pNumTarjeta = '' OR pTipoEnvio = '' OR (pTipoEnvio = 'S' AND pSucursal = '') OR  
		pTpoMaquila  = '' OR pTpoEjecucion  = '' OR pEjecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,ctpoenvio,csucursal,ctpomaquila,cnumcte,cnum_credito,cnomcliente1,cnomcliente2,capellpatcliente,
				   capellmatcliente,cdir_calle1,cdir_calle2,cdir_colonia,cdir_municipio,cdir_estado,cdir_cp,ctipotarjeta,cbintarjeta,
				   ccodproducto,cfimagen,cidimagen,cfmaster,cftitular,cfemision,cmembersince,cwelcomekit,ccat,cinanuord,cinanumor,
				   clineacredito,ccant_solicitadas,cfecha_sol,cnum_empleado,cenviasms,cnumtarjeta,ccanal,cnum_producto;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,ctpoenvio,csucursal,ctpomaquila,cnumcte,cnum_credito,cnomcliente1,cnomcliente2,capellpatcliente,
				   capellmatcliente,cdir_calle1,cdir_calle2,cdir_colonia,cdir_municipio,cdir_estado,cdir_cp,ctipotarjeta,cbintarjeta,
				   ccodproducto,cfimagen,cidimagen,cfmaster,cftitular,cfemision,cmembersince,cwelcomekit,ccat,cinanuord,cinanumor,
				   clineacredito,ccant_solicitadas,cfecha_sol,cnum_empleado,cenviasms,cnumtarjeta,ccanal,cnum_producto;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtensolicitudmaquilatdc(cEmpresa, pNumCte, pNumCredito, pNumTarjeta, pTipoEnvio, 
		pSucursal, pTpoMaquila, pTpoEjecucion, pEjecutivo)
		INTO cCodRetSp,ctpoenvio,csucursal,ctpomaquila,cnumcte,cnum_credito,cnomcliente1,cnomcliente2,capellpatcliente,
		     capellmatcliente,cdir_calle1,cdir_calle2,cdir_colonia,cdir_municipio,cdir_estado,cdir_cp,ctipotarjeta,cbintarjeta,
		     ccodproducto,cfimagen,cidimagen,cfmaster,cftitular,cfemision,cmembersince,cwelcomekit,ccat,cinanuord,cinanumor,
		     clineacredito,ccant_solicitadas,cfecha_sol,cnum_empleado,cenviasms,cnumtarjeta,ccanal,cnum_producto;
			 
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP: bdisolic:sp_obtensolicitudmaquilatdc";		
		END IF;
		
		RETURN cCodRet,ctpoenvio,csucursal,ctpomaquila,cnumcte,cnum_credito,cnomcliente1,cnomcliente2,capellpatcliente,
				   capellmatcliente,cdir_calle1,cdir_calle2,cdir_colonia,cdir_municipio,cdir_estado,cdir_cp,ctipotarjeta,cbintarjeta,
				   ccodproducto,cfimagen,cidimagen,cfmaster,cftitular,cfemision,cmembersince,cwelcomekit,ccat,cinanuord,cinanumor,
				   clineacredito,ccant_solicitadas,cfecha_sol,cnum_empleado,cenviasms,cnumtarjeta,ccanal,cnum_producto;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO QUE GUARDA Y REGRESA INFORMACION PARA LA TRANSACCION',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_verificastatusupdate(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS bandera_det_error,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusupdate.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,error_proceso,error
		INTO cStatus,cBanDetError,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		WHERE usuario = TRIM(pUsuario) AND nombre_archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','';			
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación inicio/fin para el proceso que se encarga de integrar el detalle',
'completo de todas las cuentas titulares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_validaconsecutivonomarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pConsecutivo CHAR(5))
	RETURNING CHAR(5) AS codret,
		INTEGER AS cons_disponible,
		CHAR(1) AS cons_invalido;		

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNomArchivo CHAR(35);
	DEFINE dFecha DATE;
	DEFINE iConsDisponible INTEGER;
	DEFINE cConsInvalido CHAR(1);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNomArchivo = '';
	LET dFecha = '';
	LET iConsDisponible = 0;
	LET cConsInvalido = 'F';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iConsDisponible,cConsInvalido;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_validaconsecutivonomarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pConsecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iConsDisponible,cConsInvalido;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iConsDisponible,cConsInvalido;
		END IF;
		
		LET cNomArchivo = 'CAMBIOPRODTDC_'||TRIM(pFecha)||'_'||TRIM(pConsecutivo)||'.txt';
		LET dFecha = SUBSTRING(TRIM(pFecha) FROM 5 FOR 2)||'/'||SUBSTRING(TRIM(pFecha) FROM 7 FOR 2) ||'/'||SUBSTRING(TRIM(pFecha) FROM 1 FOR 4);

		SELECT NVL(MAX((consecutivo::INTEGER)),0) + 1
		INTO iConsDisponible 
		FROM bdicnweb:"informix".sw_cp_nomarchivotdc 
		WHERE fecha = dFecha;
		
		IF pConsecutivo::INTEGER = iConsDisponible THEN
			
			INSERT INTO bdicnweb:"informix".sw_cp_nomarchivotdc (nombre_archivo,fecha,consecutivo,usuario)
			VALUES (TRIM(cNomArchivo),dFecha,TRIM(pConsecutivo),pUsuario);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCodRet = '00282';
				RETURN cCodRet,NVL(iConsDisponible,0),cConsInvalido;
			END IF;
			
			RETURN cCodRet,NVL(iConsDisponible,0) + 1,cConsInvalido;
			
		ELIF pConsecutivo::INTEGER <> iConsDisponible THEN
			LET cConsInvalido = 'T';
			RETURN cCodRet,NVL(iConsDisponible,0),cConsInvalido;
		END IF;			
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/05/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación del consecutivo del archivo a importar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_validacaractertdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pCadena CHAR(500), pTipoCompara CHAR(1))
		RETURNING CHAR(5) AS codret,                       
			CHAR(1) AS caracter_invalido;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTamCadena CHAR(500);
	DEFINE iPos INTEGER;
	DEFINE cComparaCadena CHAR(65);
	DEFINE cCaracter CHAR(1);
	DEFINE cCaracterInvalido CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTamCadena = '';
	LET iPos = 0;
	LET cComparaCadena = '';
	LET cCaracter = '';
	LET cCaracterInvalido = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCaracterInvalido;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_validacaractertdc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCadena = '' OR pTipoCompara = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCaracterInvalido;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCaracterInvalido;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CARACTERES INVALIDOS
		LET cTamCadena = LENGTH(pCadena);
		LET iPos = 1;
		
		IF UPPER(pTipoCompara) = 'N' THEN
			LET cComparaCadena = '0123456789';
		ELIF UPPER(pTipoCompara) = 'L' THEN
			LET cComparaCadena = ' !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\_ÁÉÍÓÚÑ¿¡';
		END IF;
		
		WHILE (iPos <= cTamCadena::INTEGER) LOOP
			
			LET cCaracter = UPPER(SUBSTR(TRIM(pCadena),iPos,1));
			
			IF INSTR(TRIM(cComparaCadena),REPLACE(cCaracter," ","*")) = 0 THEN
				LET cCaracterInvalido = 't';
				EXIT;
			END IF;
			
			LET iPos = iPos + 1;
			
		END LOOP;
		
		RETURN cCodRet, cCaracterInvalido;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 12/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación de caracteres para la carga de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_statuscredito(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoCredito CHAR(20))
	RETURNING CHAR(5) AS codret,
			  CHAR(2) AS status,
			  CHAR(2) AS siglas;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cStatus CHAR(2);
	DEFINE cSiglas CHAR(2);	
	--DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cStatus = '';
	LET cSiglas = '';
	--LET iRegistros = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cSiglas;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_statuscredito.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cSiglas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cSiglas;
		END IF;
		
		SELECT e.status_cred, c.siglas
		INTO cStatus, cSiglas
		FROM bdicred:"informix".sd_maecred a,
		bdicred:"informix".sd_definicion c,				  
		bdicred:"informix".sd_tipocartera e
		WHERE c.num_producto = a.num_producto
		AND c.empresa      = a.empresa		  
		AND e.status_cred  = a.status_cred
		AND a.num_credito  = pNoCredito
		AND a.empresa      = cEmpresa;		
		
		RETURN cCodRet, cStatus, cSiglas;		
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UNA CONSULTA QUE OBTIENE ESTATUS DEL CREDITO Y LAS SIGLAS DEL PRODUCTO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_rep_status_upgrade(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER    AS num_parametro,
		CHAR(100)  AS estatus;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumParametro INTEGER;
	DEFINE ccStatus  CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumParametro = 0;
	LET ccStatus  = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumParametro, ccStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_rep_status_upgrade.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumParametro, ccStatus;
		END IF;		
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumParametro, ccStatus;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rep_status_upgrade()
			INTO cCodRetSp, iNumParametro, ccStatus
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_rep_status_upgrade";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iNumParametro, NVL(UPPER(ccStatus),'') WITH RESUME;
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumParametro, NVL(UPPER(ccStatus),'');
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO PARA EL LLENADO DEL COMBO QUE SE EJECUTA EN LA PANTALLA DE REPORTE DE PRODUCTO ORO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_rep_prod_upgrade2_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE , pTipo CHAR(1), pStatus CHAR(1), pArchivo CHAR(50))
	RETURNING CHAR(5) AS codret,						  
		INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescMensaje CHAR(100);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cDescMensaje = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_rep_prod_upgrade2_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
					
		EXECUTE PROCEDURE  bdicred:"informix".sp_rep_prod_upgrade2_totales(cEmpresa, pFechaIni, pFechaFin, pTipo, pStatus, pArchivo)
		INTO cCodRetSp, cDescMensaje, iNumRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_rep_prod_upgrade2_totales";		
		ELIF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN  cCodRet, iNumRegistros;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO PARA OBTENER EL TOTAL DE REGISTROS PARA EL GRID DE LA PANTALLA DE REPORTES PRODUCTO ORO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_nombreembozado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(26) AS nombre_1, 	  
		CHAR(26) AS nombre_2, 	  
		CHAR(26) AS apellido_pat, 
		CHAR(26) AS apellido_mat, 
		CHAR(1) AS nom1_ini,      
		CHAR(1) AS nom2_ini,      
		CHAR(1) AS apellpat_ini,  
		CHAR(1) AS apellmat_ini;  

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	DEFINE cNombre1         CHAR(26);	 
    DEFINE cNombre2         CHAR(26);	 
    DEFINE capell_paterno   CHAR(26);
    DEFINE capell_materno   CHAR(26);
    DEFINE cNom1_ini        CHAR(1);     
    DEFINE cNom2_ini        CHAR(1);     
    DEFINE cApellPat_ini    CHAR(1);	 
    DEFINE cApellMat_ini    CHAR(1);	 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cNombre1            = "";
	LET cNombre2            = "";
	LET capell_paterno      = "";
	LET capell_materno      = "";
	LET cNom1_ini           = "";
	LET cNom2_ini           = "";
	LET cApellPat_ini       = "";
	LET cApellMat_ini       = "";
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre1,cNombre2,capell_paterno,capell_materno,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_nombreembozado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre1,cNombre2,capell_paterno,capell_materno,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre1,cNombre2,capell_paterno,capell_materno,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini;
		END IF;

		EXECUTE PROCEDURE bdicred:"informix".sp_nom_embozado_upgrade(cEmpresa, pNumcte)
		INTO cCodRetSp, cNombre1,cNombre2,capell_paterno,capell_materno,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP: bdicred:sp_nom_embozado_upgrade";		
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
	
		RETURN ccodret,NVL(UPPER(TRIM(cNombre1)),''),NVL(UPPER(TRIM(cNombre2)),''),NVL(UPPER(TRIM(capell_paterno)),''),NVL(UPPER(TRIM(capell_materno)),''),
		NVL(UPPER(TRIM(cNom1_ini)),''),NVL(UPPER(TRIM(cNom2_ini)),''),NVL(UPPER(TRIM(cApellPat_ini)),''),NVL(UPPER(TRIM(cApellMat_ini)),'');		
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP PRODUCTIVO QUE OBTTIENE LOS DATOS DEL CLIENTE PARA EL EMBOZADO DE LA TARJETA',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_mostrar_grid_upgrade2_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolCred CHAR(20),pFlagAdicional CHAR(1),pNumcte CHAR(20))
	RETURNING CHAR(5) AS codret,		
		  INTEGER AS num_registros;
				  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,  NVL(iNumRegistros,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_mostrar_grid_upgrade2_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolCred = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,  NVL(iNumRegistros,0);
		END IF;		
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet,  iNumRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade2_totales(cEmpresa, pNumSolCred ,pFlagAdicional, pNumcte)
		INTO cCodRet, iNumRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_mostrar_grid_upgrade2_totales";		
		END IF;	
		
		RETURN  cCodRet,  iNumRegistros;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO PARA OBTENER EL TOTAL DE REGISTROS PARA EL PAGINADO DEL GRID',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_mostrar_grid_upgrade2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolCred CHAR(20),pFlagAdicional CHAR(1),pNumcte CHAR(20),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_credito,
		CHAR(2)  AS status_cred,
		CHAR(3)  AS tipo_tarjeta,
		CHAR(30) AS nombre,
		CHAR(21) AS nombre_embozado,
		CHAR(20) AS tarjeta,
		CHAR(20) AS cliente;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNumcredito CHAR(20);
    DEFINE cstatus     CHAR(2);
    DEFINE cTipotarjeta CHAR(3);
    DEFINE cNombre     CHAR(30);
    DEFINE cNomEmbozado CHAR(21);
    DEFINE cTarjeta    CHAR(20);
    DEFINE cNumcte     CHAR(20);
	DEFINE iNumRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNumcredito   = '';
	LET cstatus= '';
	LET cTipotarjeta  = '';
	LET cNombre = '';
	LET cNomEmbozado  = '';
	LET cTarjeta  = '';
	LET cNumcte  = '';
	LET iNumRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_mostrar_grid_upgrade2.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolCred = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte;
		END IF;

		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade2(cEmpresa, pNumSolCred ,pFlagAdicional, pNumcte, pRegistros, pRecuperacion)
			INTO cCodRetSp, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte

			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_mostrar_grid_upgrade2";
			END IF;

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, NVL(cNumcredito,''),NVL(UPPER(TRIM(cstatus)),''), NVL(UPPER(TRIM(cTipotarjeta)),''),NVL(UPPER(TRIM(cNombre)),''),NVL(UPPER(TRIM(cNomEmbozado)),''),NVL(cTarjeta,''),NVL(cNumcte,'')  WITH RESUME;
		END FOREACH;

		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumcredito, cstatus, cTipotarjeta, cNombre, cNomEmbozado, cTarjeta, cNumcte;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO PARA MOSTRAR LOS DATOS QUE LLENAN EL GRID CON TITULARES Y ADICIONALES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cat_constransacc_auditar(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pCodigo CHAR(4))
	RETURNING CHAR(5) AS codret,
		CHAR(10) AS Codigo,
		CHAR(40) AS Descripcion,
		CHAR(300) AS NumTran;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cCodigo      CHAR(10);
	DEFINE cDescripcion CHAR(40);
	DEFINE cNumTran     CHAR(300);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;		
	LET cCodigo      = '';
	LET cDescripcion = '';
	LET cNumTran     = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_constransacc_auditar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_constransacc_auditar(pTipo, cEmpresa, pCodigo)
			INTO cCodRetSp, cCodigo, cDescripcion, cNumTran
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_constransacc_auditar";		
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
			ELIF iCodRetSp = 2 OR iCodRetSp = 3 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodigo, cDescripcion, cNumTran;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCodigo, UPPER(cDescripcion), cNumTran WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigo, cDescripcion, cNumTran;	
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS DEL CATALOGO PARA LOS REPORTES DE TRANSACCION',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_bts_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10)  AS cFecha,
                  CHAR(12)  AS cHora,
                  CHAR(16)  AS cFolio,
                  CHAR(8)   AS cUsuario,
                  CHAR(4)   AS cSucursal,
                  CHAR(17)  AS cImporte,
                  CHAR(4)   AS cTransaccion,
                  CHAR(20)  AS cClave_de_Confirmacion,
                  CHAR(104) AS cBeneficiario,
                  CHAR(25)  AS cIdentificacion,
                  CHAR(25)  AS cFolio_Identificacion,
                  CHAR(45)  AS cForma_de_Pago,
                  CHAR(20)  AS cCuenta,
                  CHAR(4)   AS cTransSuc,
                  INTEGER   AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE dFecha        		CHAR(10);
	DEFINE cHora         		CHAR(12);
	DEFINE cFolio        		CHAR(16);
	DEFINE cUsuario      		CHAR(8);
	DEFINE cSucursal     		CHAR(4);
	DEFINE cImporte      		CHAR(17);
	DEFINE cTransaccion  		CHAR(4);
	DEFINE cCveConfirm   		CHAR(20);
	DEFINE cBeneficiario   		CHAR(104);
	DEFINE cIdentificacion 		CHAR(25);
	DEFINE cFolioIdentificacion CHAR(25);
	DEFINE cFormaPago    		CHAR(45);
	DEFINE cCuenta       		CHAR(20);
	DEFINE cTransacSuc   		CHAR(4);
	DEFINE iTotalRows  	 		INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET dFecha          	 = "";
	LET cHora           	 = "";
	LET cFolio          	 = "";
	LET cUsuario        	 = "";
	LET cSucursal       	 = "";
	LET cImporte        	 = "";
	LET cTransaccion    	 = "";
	LET cCveConfirm     	 = "";
	LET cBeneficiario   	 = "";
	LET cIdentificacion 	 = "";
	LET cFolioIdentificacion = "";
	LET cFormaPago      	 = "";
	LET cCuenta         	 = "";
	LET cTransacSuc     	 = "";
	LET iTotalRows   		 = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_bts_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_bts_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_bts_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, UPPER(cBeneficiario), UPPER(cIdentificacion), cFolioIdentificacion, UPPER(cFormaPago), cCuenta, cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE REMESAS BTS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_dev_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
				  CHAR(16) AS cFolio,
				  CHAR(10) AS cFecha,
				  CHAR(20) AS cCuenta,
				  CHAR(17) AS cMonto,
				  CHAR(12) AS cHora,
				  CHAR(8)  AS cUsuario,
				  CHAR(4)  AS cTransaccion,
				  CHAR(17) AS cSaldo,
				  CHAR(4)  AS cSucursal,
				  CHAR(4)  AS cBanco,
				  CHAR(20) AS cCuentaBanco,
				  CHAR(11) AS cCheque,
				  CHAR(16) AS cTarjeta,
				  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE dFechaAlt     CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cBanco        CHAR(4);
	DEFINE cCtaBanco     CHAR(20);
	DEFINE cCheque       CHAR(11);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = "";
	LET cFolio        = "";
	LET dFechaAlt     = "";
	LET cCuenta       = "";
	LET cMonto        = "";
	LET cHora         = "";
	LET cUsuario      = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cBanco        = "";
	LET cCtaBanco     = "";
	LET cCheque       = "";
	LET cTarjeta      = "";
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_dev_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_dev_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows

			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_dev_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES DEVUELTOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_propios_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(11) AS cCheque,
                  CHAR(4)  AS cTransSuc,
                  CHAR(16) AS cTarjeta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE cFecha        CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR (4);
	DEFINE cCheque       CHAR(11);
	DEFINE cTrans_Suc    CHAR(4);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = '';
	LET cFolio        = '';
	LET cFecha        = '';
	LET cCuenta       = '';
	LET cMonto        = '';
	LET cHora         = '';
	LET cUsuario      = '';
	LET cTransaccion  = '';
	LET cSaldo        = '';
	LET cSucursal     = '';
	LET cCheque       = '';
	LET cTrans_Suc    = '';
	LET cTarjeta      = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;				   
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_propios_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_propios_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_propios_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES PROPIOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_sbc_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(3)  AS cBanco,
                  CHAR(20) AS cCuentaBanco,
                  CHAR(11) AS cCheque,
                  CHAR(16) AS cTarjeta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE cFecha        CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cBanco        CHAR(4);
	DEFINE cCtaBanco     CHAR(20);
	DEFINE cCheque       CHAR(11);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = '';
	LET cFolio        = '';
	LET cFecha        = '';
	LET cCuenta       = '';
	LET cMonto        = '';
	LET cHora         = '';
	LET cUsuario      = '';
	LET cTransaccion  = '';
	LET cSaldo        = '';
	LET cSucursal     = '';
	LET cBanco        = '';
	LET cCtaBanco     = '';
	LET cCheque       = '';
	LET cTarjeta      = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_sbc_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_sbc_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_sbc_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_conc_efect_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cFolioPapeleta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cFolio        CHAR(16);
	DEFINE cUsuario      CHAR(8);
	DEFINE cSucursal     CHAR(4);
	DEFINE cImporte      CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cFolioPap     CHAR(10);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cHora         = '';
	LET cFolio        = '';
	LET cUsuario      = '';
	LET cSucursal     = '';
	LET cImporte      = '';
	LET cTransaccion  = '';
	LET cFolioPap     = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_conc_efect_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_conc_efect_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_conc_efect_aud";			
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CONCENTRACION DE EFECTIVO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_dota_efect_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cFolioPapeleta,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cFolio        CHAR(16);
	DEFINE cUsuario      CHAR(8);
	DEFINE cSucursal     CHAR(4);
	DEFINE cImporte      CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cFolioPap   	 CHAR(8);
	DEFINE cTransacSuc   CHAR(4);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cHora         = '';
	LET cFolio        = '';
	LET cUsuario      = '';
	LET cSucursal     = '';
	LET cImporte      = '';
	LET cTransaccion  = '';
	LET cFolioPap     = '';
	LET cTransacSuc   = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_dota_efect_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_dota_efect_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_dota_efect_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE DOTACION DE EFECTIVO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_orden_pago_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(14) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(20) AS cNoOrden,
                  CHAR(105)AS cBeneficiario,
                  CHAR(2)  AS cIdentificacion,
                  CHAR(25) AS cFolioIdentificacion,
                  CHAR(15) AS cFormaPago,
                  CHAR(12) AS cCuenta,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cFecha 	 	   CHAR(10);
	DEFINE cHora 	 	   CHAR(12);
	DEFINE cFolio 	 	   CHAR(16);
	DEFINE cUsuario  	   CHAR(8);
	DEFINE cSucursal 	   CHAR(4);
	DEFINE cImporte 	   CHAR(14);
	DEFINE cTransaccion    CHAR(4);
	DEFINE cNumOrden 	   CHAR(20);
	DEFINE cBeneficiario   CHAR(105);
	DEFINE cIdentificacion CHAR(2);
	DEFINE cFolioIdent 	   CHAR(25);
	DEFINE cFormaPago 	   CHAR(15);
	DEFINE cCuenta 		   CHAR(12);
	DEFINE cTransacSuc 	   CHAR(4);	
	DEFINE iTotalRows  	   INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha 			= "";
	LET cHora 			= "";
	LET cFolio 			= "";
	LET cUsuario		= "";
	LET cSucursal 		= "";
	LET cImporte 		= "";
	LET cTransaccion 	= "";
	LET cNumOrden 		= "";
	LET cBeneficiario 	= "";
	LET cIdentificacion = "";
	LET cFolioIdent 	= "";
	LET cFormaPago 		= "";
	LET cCuenta 		= "";
	LET cTransacSuc 	= "";
	LET iTotalRows   	= 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_orden_pago_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_orden_pago_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_orden_pago_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, UPPER(cBeneficiario), UPPER(cIdentificacion), cFolioIdent, UPPER(cFormaPago), cCuenta,cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE ORDEN DE PAGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_reversos_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cNoCliente,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(20) AS cCuenta,
                  CHAR(18) AS cMonto,
                  CHAR(4)  AS cTransaccion,
                  CHAR(18) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(4)  AS cTransSuc,
                  CHAR(40) AS cReferencia,
                  CHAR(20) AS cTarjeta,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cCliente 	 CHAR(20);
	DEFINE cFolio 		 CHAR(16);
	DEFINE cUsuario 	 CHAR(8);
	DEFINE cFecha 		 CHAR(10);
	DEFINE cHora 		 CHAR(12);
	DEFINE cCuenta 		 CHAR(20);
	DEFINE cMonto 		 CHAR(18);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo 		 CHAR(18);
	DEFINE cSucursal 	 CHAR(4);
	DEFINE cTransSuc 	 CHAR(4);
	DEFINE cReferencia 	 CHAR(40);
	DEFINE cTarjeta 	 CHAR(20);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente 	  = "";
	LET cFolio 		  = "";
	LET cUsuario 	  = "";
	LET cFecha 		  = "";
	LET cHora 		  = "";
	LET cCuenta 	  = "";
	LET cMonto 		  = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cTransSuc     = "";
	LET cReferencia   = "";
	LET cTarjeta 	  = "";
	LET iTotalRows 	  = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_reversos_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_reversos_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_reversos_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE REVERSOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_sobrantes_caja_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pFechaRep CHAR(10), pImporte CHAR(21), pFechaEliminacion CHAR(10), pNumTransaccion CHAR(4), pOperador CHAR(8), pLinea INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
				  CHAR(8)  AS cUsuario,
				  CHAR(45) AS cNombre,
				  CHAR(21) AS cImporte,
				  CHAR(10) AS cFechaEliminacion,
				  CHAR(4)  AS cTransaccion,
				  CHAR(4)  AS cSucursal,
				  CHAR(16) AS cSaldo,
				  CHAR(4)  AS cTransSuc,
				  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cUsuario      CHAR(8);
	DEFINE cNombreUsu    CHAR(45);
	DEFINE cImporte      CHAR(21);
	DEFINE cImporte2     CHAR(21);
	DEFINE cFechaElimina CHAR(10);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSucursal     CHAR(4);
	DEFINE cTransSuc     CHAR(4);	
	DEFINE iTotalRows  	 INTEGER;
	DEFINE cVacio        CHAR(4);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;		
	LET cFecha        = '';
	LET cUsuario      = '';
	LET cNombreUsu    = '';
	LET cImporte      = '';
	LET cImporte2     = '';
	LET cFechaElimina = '';
	LET cTransaccion  = '';
	LET cSucursal     = '';
	LET cTransSuc     = '';
	LET iTotalRows    = 0;
	LET cVacio     	  = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_sobrantes_caja_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_sobrantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion, pFechaRep , pImporte , pFechaEliminacion , pNumTransaccion , pOperador, pLinea)
			INTO cCodRetSp, cFecha, cUsuario, cNombreUsu, cImporte, cFechaElimina, cTransaccion, cSucursal, cImporte2, cTransSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_sobrantes_caja_aud";		
			ELIF iCodRetSp = 1 OR iCodRetSp = 3 OR iCodRetSp = 4 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			ELIF iCodRetSp = 5 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE SOBRANTES EN CAJA',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_spei_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cTransaccion,
                  CHAR(40) AS cReferencia,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE dFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cTransacSuc   CHAR(4);
	DEFINE cReferencia   CHAR(40);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = "";
	LET cFolio        = "";
	LET dFecha        = "";
	LET cHora         = "";
	LET cCuenta       = "";
	LET cMonto        = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cTransacSuc   = "";
	LET cReferencia   = "";
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_spei_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_spei_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_spei_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE SPEI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_param_conexion_postgres(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS cNumIp,
				  CHAR(100) AS cPuerto,
				  CHAR(100) AS cNomUsuario,
				  CHAR(100) AS cPassword,
				  CHAR(100) AS cNomBd,
				  CHAR(100) AS cTiempo,
				  CHAR(100) AS cLimite;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cNumIp      CHAR(100);
	DEFINE cPuerto     CHAR(100);
	DEFINE cNomUsuario CHAR(100);
	DEFINE cPassword   CHAR(100);
	DEFINE cNomBd      CHAR(100);
	DEFINE cTiempo     CHAR(100);
	DEFINE cLimite     CHAR(100);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;		
	LET cNumIp      = '';
	LET cPuerto     = '';
	LET cNomUsuario = '';
	LET cPassword   = '';
	LET cNomBd      = '';
	LET cTiempo     = '';
	LET cLimite     = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_param_conexion_postgres.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_obtiene_conexion_param(cEmpresa)
		INTO cCodRetSp, cNumIp, cPuerto, cNomUsuario, cPassword, cNomBd, cTiempo, cLimite;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_obtiene_conexion_param";		
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA CONEXION A LA BASE DE DATOS DE POSTGRES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_sucursal;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSucursal CHAR(45);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSucursal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_sucursal(cEmpresa, pSucursal)
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_valida_sucursal';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '00161'; --EL NÚMERO DE SUCURSAL ES INCORRECTO
		ELIF cCodRetSp::INTEGER = 0 THEN
			
			SELECT nombre 
			INTO cNombreSucursal 
			FROM bdinteg:"informix".si_sucursales 
			WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		END IF;
		
		RETURN cCodRet,NVL(UPPER(cNombreSucursal),'');
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 11/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: Spl encargado de validar que la sucursal exista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_catalogostatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
		CHAR(2) AS status,
		CHAR(40) AS descripcion;
    
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cStatus CHAR(2);
	DEFINE cDescripcion CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cStatus = null;
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cDescripcion;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_catalogostatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT status_solicitud, descripcion
			INTO cStatus, cDescripcion			
			FROM bdisolic:"informix".ss_status_sol ORDER BY status_solicitud
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cStatus, UPPER(cDescripcion) WITH RESUME; 
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo status.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaperfilusuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
		SMALLINT AS tipo_perfil,
		CHAR(10) AS desc_perfil;
    
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iTipoPerfil SMALLINT;
	DEFINE cDescPerfil CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET iTipoPerfil = null;
	LET cDescPerfil = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaperfilusuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;

		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_perfil_usuario(cEmpresa,pUsuario)
		INTO cCodRetSp, cDescCodRetSp, iTipoPerfil;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_valida_perfil_usuario';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;
		
		IF iTipoPerfil = 0 THEN
			LET cDescPerfil = 'CRÉDITO';
		ELIF iTipoPerfil = 1 THEN
			LET cDescPerfil = 'AUDITORÍA';
		END IF;
		
		RETURN cCodRet, iTipoPerfil, cDescPerfil; 
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el perfil del usuario que está ingresando a la funcionalidad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_detallestatussol(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
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
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_detallestatussol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pSucursal  = '' OR pStatus  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
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
			EXECUTE PROCEDURE bdicred:"informix".status_sol2(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus,pRegistros,pRecuperacion)			
			INTO cCodRetSp, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:status_sol2';
			END IF;
			
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
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle del status de la solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_detallestatussolaud(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
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
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_detallestatussolaud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pSucursal  = '' OR pStatus  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
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
			EXECUTE PROCEDURE bdicred:"informix".sp_status_sol_aud2(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus,pRegistros,pRecuperacion)			
			INTO cCodRetSp, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_status_sol_aud2';
			END IF;
			
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
'FECHA: 04/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle de los datos del reporte de solicitudes para el area de auditoria.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_faltantes_caja_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS fecha,
				  CHAR(8)  AS usuario,
				  CHAR(21) AS importe,
				  CHAR(45) AS nombre,
				  CHAR(4)  AS transaccion,
				  CHAR(4)  AS sucursal,
				  CHAR(10) AS fecha_eliminacion,
				  CHAR(21) AS saldo,
				  CHAR(10) AS fecha_asignacion,
				  INTEGER  AS total_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha 		 CHAR(10);
	DEFINE cUsuario		 CHAR(8);
	DEFINE cImporte		 CHAR(21);
	DEFINE cNombre		 CHAR(45);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSucursal	 CHAR(4);
	DEFINE cFechaElimina CHAR(10);
	DEFINE cSaldo	     CHAR(21);
	DEFINE cFechaAsigna  CHAR(10);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cUsuario      = '';
	LET cImporte      = '';
	LET cNombre		  = '';
	LET cTransaccion  = '';
	LET cSucursal	  = '';
	LET cFechaElimina = '';
	LET cSaldo	      = '';
	LET cFechaAsigna  = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_faltantes_caja_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni = '' OR pFechaFin = '' OR pSucursal = '' OR pCodigo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		IF pTipo = 1 THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_faltantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_faltantes_caja_aud";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE 
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 0 THEN
				LET pTipo = 2;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_faltantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SPL bdinteg:sp_cons_faltantes_caja_aud";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE 
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cUsuario, cImporte, UPPER(cNombre), cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 11/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: SPL encargado de obtener los datos del reporte de faltante en caja.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consctecuenta(pIdUsuario char(8), pIdFuncion char(10), pNumCliente char(20), pNumCuenta char(20), pSistemaCuenta char(2))
	RETURNING CHAR(5)     AS Cod_Retorno,
				CHAR(1)     AS Producto,
				CHAR(2)     AS Sistema_Cuenta,
				CHAR(20)    AS Numero_Cuenta,
				CHAR(4)     AS Cve_Producto,
				CHAR(40)    AS Nombre_Producto,
				DATE        AS Fecha_Apertura,
				CHAR(60)    AS Status_Cuenta,
				DATE        AS Fecha_Status,
				CHAR(4)     AS Clave_Sucursal,
				CHAR(8)     AS Ejecutivo,
				MONEY(14,2) AS Saldo_Actual,
                CHAR(20)    AS Numero_Tarjeta,
				CHAR(15)    AS Status_Tarjeta,
				CHAR(18)    AS Cuenta_CLABE,
				DATE        AS Fecha_Apertura_Inversion,
                SMALLINT    AS Dia_Corte,
				DATE		AS Fecha_cancelacion;

	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCodRetSp		CHAR(5);
	DEFINE iSql_err 		INT;
	--SISTEMA DE CUENTA 01 VARIABLES
	DEFINE cIProducto_chequera	CHAR(1);
	DEFINE cScuenta				CHAR(2);
	DEFINE cNo_cuenta			CHAR(20);
	DEFINE cNo_tarjeta			CHAR(20);
	DEFINE cClave_producto		CHAR(4);
	DEFINE cNombre_producto		CHAR(40);
	DEFINE cCuenta_clabe		CHAR(18);
	DEFINE dFecha_apertura		DATE;
	DEFINE cStatus_tarjeta		CHAR(15);
	DEFINE cStatus_cuenta		CHAR(60);
	DEFINE dFecha_status		DATE;
	DEFINE cClave_sucursal		CHAR(4);
	DEFINE cEjecutivo 			CHAR(8);
	DEFINE mSaldo_actual		MONEY(14,2);
	DEFINE dFecha_aperturaO_inv DATE;
	DEFINE dFecha_max			DATE;
	DEFINE dFecha_min			DATE;
	DEFINE cNumero_cuenta 		CHAR(20);
	DEFINE dFecha 				DATE;
	DEFINE iCont                INTEGER;
	DEFINE iMaxSec              INTEGER;
	DEFINE cCtaInv              CHAR(20);
	DEFINE cDiaCorte            SMALLINT;
	DEFINE dFecha_cancelacion	DATE;
	DEFINE iEncontrada			SMALLINT;	
	DEFINE iRegistros			INTEGER;
	DEFINE iRecuperacion		INTEGER;
	DEFINE cCodStatusCta        CHAR(2);

	--inicializando variables
	LET  iexiste = 0;
	LET cCodRet = "00000";
	LET cCodRetSp = "00000";
	LET iSql_err = 0 ;
	--SISTEMA DE CUENTA 01 VARIABLES
	LET cIProducto_chequera	 = "";
	LET cScuenta		 = "";
	LET cNo_cuenta		 = "";
	LET cNo_tarjeta			 = "";
	LET cClave_producto		 = "";
	LET cNombre_producto		 = "";
	LET cCuenta_clabe		 = "";
	LET dFecha_apertura		 = "";
	LET cStatus_tarjeta		 = "";
	LET cStatus_cuenta		 = "";
	LET dFecha_status		 = "";
	LET cClave_sucursal		 = "";
	LET cEjecutivo 			 = "";
	LET mSaldo_actual		= 0;
	LET dFecha_aperturaO_inv = "";
	LET dFecha_max			="";
	LET dFecha_min			="";
	LET cNumero_cuenta 	= "" ;
	LET iCont=0;
	LET iMaxSec=0;
	LET cCtaInv='';
	LET cDiaCorte           =0;
	LET dFecha_cancelacion = "";
	LET iEncontrada = 0;	
	LET iRegistros = 0;
	LET iRecuperacion = 1000;	
	LET cCodStatusCta = "";
				
	BEGIN
	
		ON EXCEPTION SET iSql_err
			LET cCodRet = iSql_err;
			RETURN 
				cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
				cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_consctecuenta_mfinis.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNumCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN 
				cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
				cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END IF;
		
	
		--VALIDACION
		EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(pIdUsuario,pIdFuncion, pNumCliente, pSistemaCuenta, '2')
		INTO cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN 
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		WHILE cCodRetSp = '00000'
			FOREACH EXECUTE PROCEDURE bdinteg:sp_cnsif_consprodcte(pIdUsuario, pIdFuncion, pNumCliente, pSistemaCuenta, iRegistros, iRecuperacion)
				INTO cCodRetSp,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
					cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
					cDiaCorte, dFecha_cancelacion, cCodStatusCta
				
				IF cCodRetSp =  '1001' THEN
					LET cCodRet = '00017';
					LET cCodRetSp = '99999';
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
					EXIT FOREACH;
				ELIF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
				END IF;
				
				IF TRIM(cNo_cuenta) = TRIM(pNumCuenta) THEN
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
					LET cCodRetSp = '99999';
					EXIT FOREACH;
				END IF
				
			END FOREACH;
			
			LET iRegistros = iRegistros + iRecuperacion;
			
		END WHILE;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde", 
"FECHA: 16/07/2013",
"DESCRIPCION: Procedimiento que busca solo una cuenta de un cliente dado, internamente ejecuta el ss sp_cnsif_consprodcte";

CREATE PROCEDURE "informix".sp_cnsif_consarchivosgenerados(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(45) AS nombre_archivo,
		CHAR(10) AS fecha,
		CHAR(5) AS hora;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE dFecha DATE;
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE dFechaHoy DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cNombreArchivo = '';
	LET dFecha = '';
	LET cFecha = '';
	LET cHora = '';
	LET dFechaHoy = CURRENT;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consarchivosgenerados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT nombre_archivo,fecha,NVL(TO_CHAR(hora,'%H:%M'), '') AS cHoraConv
			INTO cNombreArchivo,dFecha,cHora
			FROM bdicnweb:"informix".sw_cons_archivosgenerados
			WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta AND fecha = dFechaHoy
			ORDER BY cHoraConv ASC
			
			LET cFecha = LPAD(DAY(dFecha),2,0)||'/'||LPAD(MONTH(dFecha),2,0)||'/'||YEAR(dFecha);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombreArchivo,cFecha,cHora WITH RESUME;
		END FOREACH;				
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos generados a partir de la consulta de movimientos (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se modifica el tratado del campo hora de la tabla bdinteg:sw_cons_archivosgenerados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consarchivosgenerados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE dFecha DATE;
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE dFechaHoy DATE;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cNombreArchivo = '';
	LET dFecha = '';
	LET cFecha = '';
	LET cHora = '';
	LET dFechaHoy = CURRENT;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consarchivosgenerados_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' THEN
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
		FROM (SELECT DISTINCT nombre_archivo,fecha,hora
			  FROM bdicnweb:"informix".sw_cons_archivosgenerados
			  WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta AND fecha = dFechaHoy
			  ORDER BY hora ASC);						
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el número total de archivos generados a partir de la consulta de movimientos (CAPTACION/CREDITO/INVERSIONES).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_depuramovimientostemp(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
    DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET bInTransaction='f';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00114';
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_depuramovimientostemp.out';
		--TRACE ON;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;	
		
		BEGIN;
		TRUNCATE TABLE bdicnweb:"informix".sw_cons_movimientos;
		COMMIT;
		
		BEGIN;
		TRUNCATE TABLE bdicnweb:"informix".sw_cons_tempo_movimientos;
		COMMIT;
				
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_depuramovimientostempo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 08/01/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÃN/CRÃDITO/INVERSIONES',
'DESCRIPCION: Depura registros de movimientos de tablas temporales sw_cons_movimientos sw_cons_tempo_movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se cambia DELETE por TRUNCATE para realizar la depuraciÃ³n de las tablas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_verificastatusmovimientos(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveMov CHAR(50))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_verificastatusmovimientos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClaveMov = '' THEN
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
		FROM bdicnweb:"informix".sw_cons_statusproceso 
		WHERE usuario = pUsuario AND clave_mov = pClaveMov;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES', 
'DESCRIPCION: SPL encargado de verificar el status de la consulta para la recuperación de los registros correspondientes a los movimientos de CAPTACIÓN, CRÉDITO e INVERSIONES.',
'AUTOR: L. Montserrat León Amador',
'FECHA 08/01/2018',
'DESCRIPCION: Se modifica spl para filtrar la consulta por un nuevo parámetro de entrada (clave movimiento), la cual es generada en el proceso principal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizascparam(pUsuario CHAR(8), pIdFuncion CHAR(10),  pCodParam CHAR(100), pValor CHAR(100))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_ope_actualizascparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodParam = '' OR pValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			
		UPDATE bdicheq:"informix".sc_param SET valor = TRIM(pValor) WHERE codparam = TRIM(pCodParam);

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de actualizar el campo valor en la tabla bdicheq:sc_param cuando codparam sea igual a LimDepositoInterEdo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_insertconssucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),
pSucursal CHAR(4), pMonto MONEY(18,2), pNumTransacciones INT, pPlazo INT)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS sucursal,
		MONEY(18,2) AS monto,
		INT AS num_transacciones,
		INT AS plazo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE mMonto MONEY(18,2);
	DEFINE iNumTransacciones INT;
	DEFINE iPlazo INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET mMonto = 0.00;
	LET iNumTransacciones = 0;
	LET iPlazo = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
			END IF;
		END EXCEPTION;
		
	--	SET DEBUG FILE TO '/informix/vamilan/sp_ope_insertconssucursal.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pMonto IS NULL OR pNumTransacciones IS NULL OR pPlazo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_limitedeposito(sucursal,monto,num_transaccion,plazo,fecha_alta,usuario) 
			VALUES(pSucursal,pMonto,pNumTransacciones,pPlazo,DATE(CURRENT),pUsuario);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_limitedeposito 
			SET monto = pMonto, num_transaccion = pNumTransacciones, plazo = pPlazo 
			WHERE sucursal = pSucursal;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT sucursal, monto, num_transaccion, plazo 
			INTO cSucursal, mMonto, iNumTransacciones, iPlazo
			FROM bdicheq:"informix".sc_limitedeposito 
			WHERE sucursal = pSucursal;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar el detalle del límite de depósito de la sucursal consultada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_ope_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT sucursal 
		INTO cSucursal 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '01031'; --LA SUCURSAL NO EXISTE EN EL CATÁLOGO GENERAL DE SUCURSALES, VERIFIQUE
		ELSE 
			LET cCodRet = '00000';
		END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de validar si la sucursal existe.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_actualizascparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodParam CHAR(100), pValor CHAR(100))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_actualizascparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodParam = '' OR pValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			
		UPDATE bdicheq:"informix".sc_param SET valor = TRIM(pValor) WHERE codparam = TRIM(pCodParam);

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de actualizar el campo valor en la tabla bdicheq:sc_param.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_catestatusexencioncte(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		INT AS id_exencion,
		CHAR(35) AS desc_exencion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdExencion INT;
	DEFINE cDescExencion CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdExencion = 0;
	LET cDescExencion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdExencion, cDescExencion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_catestatusexencioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_exencion, desc_exencion
			INTO iIdExencion, cDescExencion
			FROM bdicheq:"informix".sc_exencioncte
			ORDER BY desc_exencion DESC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdExencion, UPPER(TRIM(cDescExencion)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: EXENCIÓN DEL LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estatus de la exención del cliente recuperado de la tabla bdicheq:sc_exencioncte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_catperiodicidad(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		INT AS id_periodicidad,
		CHAR(35) AS desc_periodicidad;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdPeriodicidad INT;
	DEFINE cDescPeriodicidad CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdPeriodicidad = 0;
	LET cDescPeriodicidad = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_catperiodicidad.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_periodicidad, desc_periodicidad 
			INTO iIdPeriodicidad, cDescPeriodicidad
			FROM bdicheq:"informix".sc_periodicidad
			ORDER BY desc_periodicidad ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPeriodicidad, UPPER(TRIM(cDescPeriodicidad)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo periodicidad recuperado de la tabla bdicheq:sc_periodicidad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_insertconsexencioncte(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1), pCliente CHAR(20), pStatus INT)
    RETURNING CHAR(5) AS codRet,
		INT AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iStatus INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iStatus = NULL;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iStatus;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_insertconsexencioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iStatus;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pStatus IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iStatus;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_retirocliente_exento(cliente,status,usuario,fecha_alta) 
			VALUES(pCliente,pStatus,pUsuario,DATE(CURRENT));

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_retirocliente_exento 
			SET status = pStatus, usuario = pUsuario, fecha_alta = DATE(CURRENT) 
			WHERE cliente = pCliente;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT status
			INTO iStatus
			FROM bdicheq:"informix".sc_retirocliente_exento 
			WHERE cliente = pCliente;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00050'; --EL NUMERO DE CLIENTE NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, iStatus;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: EXENCIÓN DEL LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar la exención del cliente consultado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_insertconssucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),
pSucursal CHAR(4), pMonto MONEY(18,2), pPeriodicidad INT, pPlazo INT)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS sucursal,
		MONEY(18,2) AS monto,
		INT AS periodicidad,
		INT AS plazo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE mMonto MONEY(18,2);
	DEFINE iPeriodicidad INT;
	DEFINE iPlazo INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET mMonto = 0.00;
	LET iPeriodicidad = 0;
	LET iPlazo = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_insertconssucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pMonto IS NULL OR pPeriodicidad IS NULL OR pPlazo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_limiteretiro(sucursal,monto,periodicidad,plazo,fecha_alta,usuario) 
			VALUES(pSucursal,pMonto,pPeriodicidad,pPlazo,DATE(CURRENT),pUsuario);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_limiteretiro 
			SET monto = pMonto, periodicidad = pPeriodicidad, plazo = pPlazo 
			WHERE sucursal = pSucursal;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT sucursal, monto, periodicidad, plazo 
			INTO cSucursal, mMonto, iPeriodicidad, iPlazo
			FROM bdicheq:"informix".sc_limiteretiro 
			WHERE sucursal = pSucursal;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar el detalle del límite de retiro de la sucursal consultada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT sucursal 
		INTO cSucursal 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '01031'; --LA SUCURSAL NO EXISTE EN EL CATÁLOGO GENERAL DE SUCURSALES, VERIFIQUE
		ELSE 
			LET cCodRet = '00000';
		END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de validar si la sucursal existe.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_verificastatusremconsgralremesascte(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_verificastatusremconsgralremesascte.out';
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
		FROM bdicnweb:"informix".sw_cons_statusprocesorem 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Uriel Caamaño Mejia',
'FECHA 21/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA GENERAL REMESAS POR CLIENTE', 
'DESCRIPCION: SPL encargado de verificar el status de la consulta para la recuperación de los registros correspondientes a la CONSULTA REMESAS POR CLIENTE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consgralremesascte_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pFechaIni DATE, pFechaFin DATE)
				RETURNING CHAR(5) AS codRet,
                INTEGER AS num_registros;               
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cDescCodRet CHAR(80);
        DEFINE cEmpresa CHAR(3);
        
        DEFINE cNumConvenio CHAR(3);
        DEFINE cNomConvenio CHAR(40);
        DEFINE iPagadasBts INTEGER;
        DEFINE iPagadasWu INTEGER;
        DEFINE iPagadasOv INTEGER;
        DEFINE iPagadasVg INTEGER;
        DEFINE iPagadasApp INTEGER;
        DEFINE mMontoPagBts CHAR(20);
        DEFINE mMontoPagWu CHAR(20);
        DEFINE mMontoPagOv CHAR(20);
        DEFINE mMontoPagVg CHAR(20);
        DEFINE mMontoPagApp CHAR(20);
        DEFINE cStatusCte CHAR(10);
        DEFINE dFechaStatus CHAR(25);
        DEFINE dFechaUltBts CHAR(25);
        DEFINE dFechaUltWu CHAR(25);
        DEFINE dFechaUltOv CHAR(25);
        DEFINE dFechaUltVg CHAR(25);
        DEFINE dFechaUltApp CHAR(25);
        
        DEFINE cNom_convenio CHAR(40);
        DEFINE iTotal_pagadas INTEGER;
        DEFINE cMonto_pagado CHAR(20);
        DEFINE cFecha_ult CHAR(25);
        DEFINE iRecuperacion INTEGER;
        DEFINE iNumRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cDescCodRet = '';
        LET cEmpresa = '001';
        
        LET cNumConvenio = '';
        LET cNomConvenio = '';
        LET iPagadasBts = 0;
        LET iPagadasWu = 0;
        LET iPagadasOv = 0;
        LET iPagadasVg = 0;
        LET iPagadasApp = 0;
        LET mMontoPagBts = '';
        LET mMontoPagWu = '';
        LET mMontoPagOv = '';
        LET mMontoPagVg = '';
        LET mMontoPagApp = '';
        LET cStatusCte = '';
        LET dFechaStatus = '';
        LET dFechaUltBts = '';
        LET dFechaUltWu = '';
        LET dFechaUltOv = '';
        LET dFechaUltVg = '';
        LET dFechaUltApp = '';
        
        LET cNom_convenio = '';
        LET iTotal_pagadas = 0;
        LET cMonto_pagado = '';
        LET cFecha_ult = '';
        LET iRecuperacion = 0;
        LET iNumRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr; 								
								UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
								SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
								RETURN cCodRet, iNumRegistros;						
                        END IF;					
						
                END EXCEPTION;
				
				ON EXCEPTION IN (-958)
				END EXCEPTION WITH RESUME;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consgralremesascte_totales.out';
                --TRACE ON;
                
				DELETE FROM bdicnweb:"informix".sw_cons_statusprocesorem WHERE usuario = pUsuario;
				
				-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3; 
				
				INSERT INTO bdicnweb:"informix".sw_cons_statusprocesorem(usuario,status,num_registros,error_proceso,error)
				VALUES(pUsuario,'I',0,'',cCodRet);  
				
                IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pFechaIni IS NULL OR pFechaFin IS NULL THEN
                        LET cCodRet = '00003';						
						UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
                        RETURN cCodRet,iNumRegistros;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN                        
						UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
						RETURN cCodRet, iNumRegistros;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 6;
                
                -- LIMPIA TABLAS
                DELETE FROM bdicnweb:"informix".sac_general_rem WHERE usuario_insert = pUsuario; 
                                
                --Compañía
                INSERT INTO bdicnweb:"informix".sac_general_rem (numconvenio,nomconvenio,total_pagadas,monto_pagado,
                fecha_ult,numcte,usuario_insert)
                SELECT numconvenio,nomconvenio,0,'','',pNumCliente,pUsuario
                FROM bdisac:"informix".sac_convenios
                WHERE numconvenio IN ('004','006','007','008','009') AND numcategoria = '07'
                ORDER BY numconvenio ASC;

                --No.Remesas Pagadas
                SELECT COUNT(*) INTO iPagadasBts 
                FROM bdisac:"informix".sac_bts_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND opcode = '1100'
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasWu 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasOv 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasVg 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasApp 
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                
                --Monto Pagado
                SELECT SUM(qr.destination_am::MONEY(18,2)) AS monto_pag INTO mMontoPagBts 
                FROM bdisac:"informix".sac_bts_payi AS pa, bdisac:"informix".sac_bts_qryi AS qr
                WHERE pa.numcte = TRIM(pNumCliente) AND pa.txn_status = 'A' AND pa.opcode = '1100'
                AND DATE(pa.fecha_insert) BETWEEN pFechaIni AND pFechaFin
                AND pa.confirmation_nm = qr.confirmation_nm
                AND qr.txn_status = 'A' AND qr.opcode = '1000'
                AND qr.fecha_insert IN (SELECT MAX(fecha_insert)
                                                                FROM bdisac:"informix".sac_bts_qryi
                                                                WHERE pa.confirmation_nm = confirmation_nm
                                                                AND txn_status = 'A' AND opcode = '1000');

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagWu 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagOv 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagVg 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT SUM(r_destinamount::MONEY(18,2)) AS monto_pag  INTO mMontoPagApp 
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                
                --Fecha Última Remesa Pagada
                SELECT MAX(process_dt) INTO dFechaUltBts
                FROM bdisac:"informix".sac_bts_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND opcode = '1100'
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(fecha_hora_rp) INTO dFechaUltWu
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(fecha_hora_rp) INTO dFechaUltOv
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT MAX(fecha_hora_rp) INTO dFechaUltVg
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(r_processdate) INTO dFechaUltApp
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                                
                --ACTUALIZA TABLA PRINCIPAL
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasBts, monto_pagado = mMontoPagBts, fecha_ult = dFechaUltBts
                WHERE numconvenio = '004' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasWu, monto_pagado = mMontoPagWu, fecha_ult = dFechaUltWu
                WHERE numconvenio = '006' AND numcte = pNumCliente AND usuario_insert = pUsuario;               
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasOv, monto_pagado = mMontoPagOv, fecha_ult = dFechaUltOv
                WHERE numconvenio = '007' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasVg, monto_pagado = mMontoPagVg, fecha_ult = dFechaUltVg
                WHERE numconvenio = '008' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasApp, monto_pagado = mMontoPagApp, fecha_ult = dFechaUltApp
                WHERE numconvenio = '009' AND numcte = pNumCliente AND usuario_insert = pUsuario;
								
                SELECT COUNT(*)
                INTO iNumRegistros
                FROM bdicnweb:"informix".sac_general_rem
                WHERE numcte = TRIM(pNumCliente) AND usuario_insert = pUsuario;							
				
				IF NVL(iNumRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
					SET status = 'E', error_proceso = 'S', num_registros = iNumRegistros, error = TRIM(cCodRet) WHERE usuario = pUsuario;
					RETURN cCodRet, iNumRegistros;						
                END IF;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
				SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = pUsuario;
				
				RETURN cCodRet, iNumRegistros;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 16/06/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA GENERAL DE REMESAS POR CLIENTE',
'DESCRIPCION: SPL encargado de consultar el número total de remesas por cliente.',
'BD: bdicnweb',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA 21/12/2017',
'DESCRIPCION: Preparacion para el hilo.';

CREATE PROCEDURE "informix".sp_rem_consparametrostransaccionapp(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumRem CHAR(12), pFecha DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(16) AS folio_suc,
		CHAR(4) AS id_sucursal,
		CHAR(40) AS desc_sucursal;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	
	DEFINE cFolio_suc				CHAR(16);
	DEFINE cId_sucursal				CHAR(4);
	DEFINE cDesc_sucursal 			CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';
	
	LET cFolio_suc					= '';
	LET cId_sucursal				= '';
	LET cDesc_sucursal 				= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consparametrostransaccionapp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNumRem = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			IF pFecha = (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
			
				SELECT folio_suc, id_sucursal
				INTO cFolio_suc, cId_sucursal
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND	flag_confirmacion_central = '1'
				AND	fecha_insert IN (SELECT MAX(fecha_insert) 
										   FROM bdisac:"informix".sac_movimientos 
										   WHERE numcategoria = '07'
										   AND numconvenio = '009'
										   AND referencia1 = pNumRem
										   AND flag_confirmacion_central = '1'); 
			
			ELIF pFecha < (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
			
				SELECT folio_suc, id_sucursal
				INTO cFolio_suc, cId_sucursal
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND	flag_confirmacion_central = '1'
				AND	ROWID IN (SELECT MAX(ROWID) 
										   FROM bdisac:"informix".sac_movimientoshistorial 
										   WHERE numcategoria = '07'
										   AND numconvenio = '009'
										   AND referencia1 = pNumRem
										   AND flag_confirmacion_central = '1'); 
										   
				IF NVL(cFolio_suc,'') = '' THEN
						
					SELECT folio_suc, id_sucursal
					INTO cFolio_suc, cId_sucursal
					--FROM bdisac:"c92357113".sac_movimientoshistorial_old
					FROM bdisac:sac_movimientoshistorial_old
					WHERE numcategoria = '07'
					AND numconvenio = '009'
					AND referencia1 = pNumRem
					AND	flag_confirmacion_central = '1'
					AND	ROWID IN (SELECT MAX(ROWID) 
											   --FROM bdisac:"c92357113".sac_movimientoshistorial_old 
											   FROM bdisac:sac_movimientoshistorial_old 
											   WHERE numcategoria = '07'
											   AND numconvenio = '009'
											   AND referencia1 = pNumRem
											   AND flag_confirmacion_central = '1');
						
				END IF;
			
			ELIF pFecha > (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
				LET cCodRet = '00975'; --LA FECHA DE PAGO ES INVÁLIDA
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF;
				
			IF NVL(cFolio_suc,'') = '' THEN
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR 
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF; 
			
			IF NVL(cId_sucursal,'') <> '' THEN
				SELECT nombre 
				INTO cDesc_sucursal
				FROM bdinteg:"informix".si_sucursales 
				WHERE sucursal = cId_sucursal;
			END IF;
			
		END IF;
		
		RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 12/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de consultar el valor de diferentes parámetros, dependiendo del id de consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consparametrostransaccionbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11))
    RETURNING CHAR(5) AS codRet,
		CHAR(64) AS trama,
		CHAR(100) AS id_transaccion,
		CHAR(80) AS nombre_usuario,
		DATE AS fecha_sistema,
		CHAR(4) AS sucursal,
		CHAR(8) AS hora;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	
	DEFINE cNombreUsuario CHAR(80);
	DEFINE dFechaSistema DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cTerminal CHAR(15);
	DEFINE cFormatFechaSistema CHAR(8);
	DEFINE cHora CHAR(8);
	DEFINE cFormatHora CHAR(6);
	DEFINE cTramaBts CHAR(64);
	DEFINE cIdTransaccionBts CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';
	
	LET cNombreUsuario = '';
	LET dFechaSistema = '';
	LET cSucursal = '';
	LET cTerminal = '';
	LET cFormatFechaSistema = '';
	LET cHora = '';
	LET cFormatHora = '';
	LET cTramaBts = '';
	LET cIdTransaccionBts = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consparametrostransaccionbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consinfobtssif(pUsuario)
		INTO cCodRetSp,cNombreUsuario,dFechaSistema,cSucursal;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_consinfobtssif';
		END IF;

		SELECT TO_CHAR(CURRENT::DATETIME HOUR TO MINUTE, '%I:%M:%S'), TO_CHAR(CURRENT::DATETIME HOUR TO MINUTE, '%I%M%S')
		INTO cHora, cFormatHora
		FROM bdinteg:"informix".si_fechas;
		
		LET cTerminal = TRIM(cSucursal)||TRIM(pUsuario);
		LET cFormatFechaSistema = SUBSTR(dFechaSistema,7,4) || SUBSTR(dFechaSistema,1,2) || SUBSTR(dFechaSistema,4,2);
		LET cTramaBts = TRIM(cSucursal)||TRIM(pNumBts)||RPAD(TRIM(UPPER(SUBSTR(cNombreUsuario,1,20))),20,' ')||RPAD(TRIM(cTerminal),15,' ')||TRIM(cFormatFechaSistema)||TRIM(cFormatHora);
		
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(407004)
		INTO cCodRetSp,cIdTransaccionBts;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 504 THEN
			LET cCodRet = '00954'; --POR EL MOMENTO EL SERVICIO DE BTS NO ESTA OPERANDO, INTÉNTELO MÁS TARDE
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF NVL(cIdTransaccionBts,'') = '' THEN
				LET cCodRet = '00955'; --NO SE PUDO OBTENER PARÁMETRO DE TRANSACCIÓN
			END IF;
		END IF;
		
		RETURN cCodRet, TRIM(cTramaBts), TRIM(cIdTransaccionBts), TRIM(UPPER(cNombreUsuario)), dFechaSistema, TRIM(cSucursal), TRIM(cHora);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 19/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar la trama y el id de la transacción de InterACT.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consremcambiobts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11), pTransStatusDt DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(15) AS cSucursal, 
		CHAR(15) AS cTerminal, 
		CHAR(3) AS cR_Type_Cd, 
		CHAR(20) AS cR_Identif_Nm, 
		CHAR(50) AS cR_Nom_Calle, 
		CHAR(5) AS cR_Num_Ext, 
		CHAR(5) AS cR_Num_Int, 
		CHAR(10) AS cR_Depto, 
		CHAR(80) AS cR_Colonia,
		CHAR(5) AS cR_Cp, 
		CHAR(50) AS cR_Mncpo_Deleg, 
		CHAR(50) AS cR_Ciudad, 
		CHAR(50) AS cR_Estado, 
		CHAR(3) AS cR_Issuer_Country_Cd, 
		CHAR(15) AS cR_Telefono, 
		CHAR(1) AS cTipo_Pago,
		CHAR(8) AS cR_Fecha_Nac,
		CHAR(50) AS cR_Nacionalidad, 
		CHAR(20) AS cR_pais_nac,
		CHAR(20) AS cFolio_SucPayi;
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INT;
	DEFINE cCodRetSp 			CHAR(6);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cDescCodRet 			CHAR(80);
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_pais_nac			CHAR(20);
	DEFINE cFolio_SucPayi       CHAR(20);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cDescCodRet 			= '';
	LET cEmpresa 				= '001';
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_pais_nac			    = '';
	LET cFolio_SucPayi          = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
				cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
				cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consremcambiobts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' OR pTransStatusDt IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
			cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
			cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
			cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
			cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consremcambiost(pNumBts,pTransStatusDt)
		INTO cCodRetSp, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
		cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
		cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_consremcambiost';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00971'; --FECHA REAL DEL PAGO INVALIDA, VERIFIQUE  
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '00964'; --NO HAY DATOS ADICIONALES DEL BENEFICIARIO  
		ELIF cCodRetSp::INTEGER = 4 THEN
			LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR     
		ELIF cCodRetSp::INTEGER = 5 THEN
			LET cCodRet = '00968'; --NO PUEDE ENVIAR MENSAJE, SUPERA EL MÁXIMO DE SOLICITUDES
		ELIF cCodRetSp::INTEGER = 6 THEN
			LET cCodRet = '00966'; --REMESA PAGADA DESDE SIF, NO PUEDE REVERSARSE
		END IF;
		
		RETURN cCodRet, cSucursal, cTerminal, UPPER(cR_Type_Cd), cR_Identif_Nm, UPPER(cR_Nom_Calle), cR_Num_Ext, cR_Num_Int, 
		cR_Depto, UPPER(cR_Colonia), cR_Cp, UPPER(cR_Mncpo_Deleg), UPPER(cR_Ciudad), UPPER(cR_Estado), cR_Issuer_Country_Cd, cR_Telefono, 
		UPPER(cTipo_Pago), cR_Fecha_Nac, UPPER(cR_Nacionalidad), UPPER(cR_pais_nac), cFolio_SucPayi;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 21/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de obtener informacion del registro de una remesa pagada cuando se consulta desde plataforma.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultapaises(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER  AS num_pais,       
		CHAR(3)  AS cod_pais,       
		CHAR(50) AS pais,    
		CHAR(1)  AS flag_banco;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cNumPais  	INTEGER;
	DEFINE cCodPais  	CHAR(3);
	DEFINE cPais     	CHAR(50);
	DEFINE cFlagBanco	CHAR(1);
	DEFINE iNoRegistros INTEGER;
    
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	
	LET cNumPais 	= 0; 	
	LET cCodPais  	='';
	LET cPais     	='';
    LET cFlagBanco	='';
	LET iNoRegistros = 0;
    
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultapaises.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		 
		 -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN 	cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion num_pais,cod_pais,pais,flag_banco  
				INTO cNumPais,cCodPais,cPais,cFlagBanco
				FROM bdisac:sac_app_paises
					
			LET iNoRegistros = iNoRegistros +1;
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco  WITH RESUME;
		END FOREACH
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        
		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
		
			RETURN 	cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
	    
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 16/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de Paises',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultaparametros(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pOpCode CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(255) AS valor;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSubTransaccion CHAR(5);
	DEFINE cOpCode CHAR(50);
	DEFINE cStatecode CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSubTransaccion = '';
	LET cOpCode = '';
	LET cStatecode = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,'';
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultaparametros.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,'';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--cSubTransaccion
		IF pIdConsulta = '1' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '1';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
			
		--cOpCode
		ELIF pIdConsulta = '2' THEN
		
			IF pOpCode = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,'';
			END IF;
		
			SELECT opcode_sd
			INTO cOpCode
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE opcode = pOpCode 
			AND agent_trans_type_code = 'QRYI';
		
			RETURN cCodRet,NVL(cOpCode,'');
			
		--cStatecode
		ELIF pIdConsulta = '3' THEN
		
			SELECT c.state_cd
			INTO cStatecode
			FROM bdisac:"informix".sac_param AS a,
			bdinteg:"informix".si_sucursales AS b,
			bdisac:"informix".sac_app_catestados AS c
			WHERE a.cod_param = '87112'
			AND b.sucursal = a.valor
			AND c.cve_estado = b.estado;

			RETURN cCodRet,NVL(cStatecode,'');
		
		--cSubTransaccion APPRIZA
		ELIF pIdConsulta = '4' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '3';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
		
		--cSubTransaccion APPRIZA (Pago)
		ELIF pIdConsulta = '5' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '2';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA DE REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de consultar el valor de los parámetros.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_estadosac(pUsuario CHAR(8), pIdFuncion CHAR(10),pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(3)     AS cod_pais,       
		CHAR(2)  	AS cve_estado,       
		CHAR(40) 	AS nombre_estado,    
		CHAR(3)  	AS state_cd;
	
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cCodPais		 CHAR(3);     
	DEFINE cCveEstado    CHAR(2);
	DEFINE cNombreEstado CHAR(40);
	DEFINE cStateCd      CHAR(3);
	
	
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	LET iNoRegistros = 0;
    
	LET cCodPais	 ='';	 
	LET cCveEstado   =''; 
	LET cNombreEstado=''; 
	LET cStateCd     =''; 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_estadosac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END IF;
		 
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END IF;
		
		SELECT edo.cod_pais, edo.cve_estado,edo.nombre_estado,edo.state_cd 
		INTO cCodPais,cCveEstado,cNombreEstado,cStateCd
		FROM bdinteg:si_sucursales suc
		INNER JOIN bdisac:sac_app_catestados  edo ON suc.estado=edo.cve_estado
		WHERE sucursal=pSucursal;
					
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 18/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de estados de sac',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_guardarespuestapayibts(pUsuario CHAR(8), 
														pIdFuncion CHAR(10),
														pSucursal CHAR (4), 
														pTxn_Status CHAR(1), 
														pConfirmation_nm CHAR (11), 
														pBank_Ref_Num CHAR(20), 
														pUser_name CHAR(20), 
														pTerminal CHAR(15), 
														pAgent_Dt CHAR(8), 
														pAgent_Tm CHAR(6), 
														pR_First_Name CHAR(40), 
														pR_Middle_Name CHAR(40), 
														pR_Last_Name CHAR(40), 
														pR_Mother_M_Name CHAR(40),
														pR_Type_Cd CHAR(3), 
														pR_Issuer_Cd CHAR(3), 
														pR_Issuer_State_Cd CHAR(3), 
														pR_Issuer_Country_Cd CHAR(3), 
														pR_Identif_Type CHAR(5),
														pR_Identif_Nm CHAR(20), 
														pR_Expiration_Dt CHAR(8),
														pR_Fecha_Nac CHAR(8),
														pR_Nacionalidad CHAR(50),
														pR_pais_nac CHAR(20),	
														pR_Nom_Calle CHAR(50),
														pR_Num_Ext CHAR(5),
														pR_Num_Int CHAR(5),
														pR_Depto CHAR(10),
														pR_Colonia CHAR(80),
														pR_Cp CHAR(5),
														pR_Mncpo_Delg CHAR(50),
														pR_Ciudad CHAR(50),
														pR_Estado CHAR(50),
														pR_Telefono CHAR(15),
														pTipo_Pago CHAR(1),
														pOpCode CHAR(4), 
														pProcess_Msg CHAR(255), 	
														pError_Param_Full_Name CHAR(255), 
														pTrans_Status_Cd CHAR(3), 
														pTrans_Status_Dt CHAR(8),
														pProcess_Dt CHAR(8), 
														pProcess_Tm CHAR(6))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_guardarespuestapayibts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pTxn_Status = '' OR pConfirmation_nm = '' OR 
		pBank_Ref_Num = '' OR pUser_name = '' OR pTerminal = '' OR pAgent_Dt = '' OR pAgent_Tm = '' OR 
		pR_First_Name = '' OR pR_Last_Name = '' OR pR_Type_Cd = '' OR pR_Issuer_Cd = '' OR pR_Issuer_State_Cd = '' OR 
		pR_Issuer_Country_Cd = '' OR pR_Identif_Nm = '' OR pR_Expiration_Dt = '' OR pR_pais_nac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_guardarespuestapayi(pSucursal,pTxn_Status,pConfirmation_nm, 
		pBank_Ref_Num,pUser_name,pTerminal,pAgent_Dt,pAgent_Tm,pR_First_Name,pR_Middle_Name, 
		pR_Last_Name,pR_Mother_M_Name,pR_Type_Cd,pR_Issuer_Cd,pR_Issuer_State_Cd,pR_Issuer_Country_Cd, 
		pR_Identif_Type,pR_Identif_Nm,pR_Expiration_Dt,pR_Fecha_Nac,pR_Nacionalidad,pR_pais_nac,	
		pR_Nom_Calle,pR_Num_Ext,pR_Num_Int,pR_Depto,pR_Colonia,pR_Cp,pR_Mncpo_Delg,pR_Ciudad,
		pR_Estado,pR_Telefono,pTipo_Pago,pOpCode,pProcess_Msg,pError_Param_Full_Name, 
	    pTrans_Status_Cd,pTrans_Status_Dt,pProcess_Dt,pProcess_Tm,pUsuario) 
		INTO cCodRetSp;		
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_guardarespuestapayi';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER > 1 THEN
			LET cCodRet = '00970'; --ERROR AL GUARDAR CONSULTA DE INTERACT, VERIFIQUE
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de guardar los datos de envío y recepción del mensaje PAYI de BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_guardarespuestarevibts(pUsuario CHAR(8), 
														pIdFuncion CHAR(10),
														pSucursal CHAR (4), 
														pTxn_Status CHAR(1), 
														pConfirmation_nm CHAR (11), 
														pProcess_Reason_Cd CHAR(3), 
														pBank_Ref_Num CHAR(20), 
														pRev_Bank_Ref_Nm CHAR(20), 
														pUser_name CHAR(20), 
														pSup_User_Name CHAR(20), 
														pTerminal CHAR(15), 
														pAgent_Dt CHAR(8), 
														pAgent_Tm CHAR(6), 
														pOpCode CHAR(4), 
														pProcess_Msg CHAR(255), 
														pError_Param_Full_Name CHAR(255), 
														pTrans_Status_Cd CHAR(3), 
														pTrans_Status_Dt CHAR(8),
														pProcess_Dt CHAR(8), 
														pProcess_Tm CHAR(6), 
														pService_Cd CHAR(3), 
														pPaymet_Type_Cd CHAR(3), 
														pOrig_Country_Cd CHAR(3), 
														pOrig_Currency_Cd CHAR(3), 
														pDest_Country_Cd CHAR(3), 
														pDest_Currency_Cd CHAR(3), 
														pOrig_Am CHAR(20), 
														pDestination_Am CHAR(20), 
														pExch_Rate_Fx CHAR(21), 
														pR_First_Name CHAR(40), 
														pR_Middle_Name CHAR(40), 
														pR_Last_Name CHAR(40), 
														pR_Mother_M_Name CHAR(40))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_guardarespuestarevibts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pTxn_Status = '' OR pConfirmation_nm = '' OR 
		pProcess_Reason_Cd = '' OR pBank_Ref_Num = '' OR pRev_Bank_Ref_Nm = '' OR pUser_name = '' OR pTerminal = '' OR 
		pAgent_Dt = '' OR pAgent_Tm = '' OR pSup_User_Name = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_guardarespuestarevi(pSucursal,pTxn_Status,pConfirmation_nm,
		pProcess_Reason_Cd,pBank_Ref_Num,pRev_Bank_Ref_Nm,pUser_name,pSup_User_Name,pTerminal, 
		pAgent_Dt,pAgent_Tm,pOpCode,pProcess_Msg,pError_Param_Full_Name,pTrans_Status_Cd,pTrans_Status_Dt,
		pProcess_Dt,pProcess_Tm,pService_Cd,pPaymet_Type_Cd,pOrig_Country_Cd,pOrig_Currency_Cd,pDest_Country_Cd, 
		pDest_Currency_Cd,pOrig_Am,pDestination_Am,pExch_Rate_Fx,pR_First_Name,pR_Middle_Name,pR_Last_Name, 
		pR_Mother_M_Name,pUsuario) 
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_guardarespuestarevi';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER > 1 THEN
			LET cCodRet = '00970'; --ERROR AL GUARDAR CONSULTA DE INTERACT, VERIFIQUE
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de guardar los datos de envío y recepción del mensaje REVI de BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_mensajes(pUsuario CHAR(8), pIdFuncion CHAR(10),pAgentTransTypeCode CHAR(4), pOpCode CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(4)     AS agent_trans_type_code,       
		CHAR(4)  	AS opcode,       
		CHAR(50) 	AS opcode_sd,    
		CHAR(255)  	AS opcode_ds;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cAgentTransTypeCode   CHAR(4);
	DEFINE cOpcode               CHAR(4);
	DEFINE cOpcodesd             CHAR(50);
	DEFINE cOpcodeds             CHAR(255);
    DEFINE iNoRegistros 		 INTEGER;
	
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	LET cAgentTransTypeCode='';
	LET cOpcode            ='';
	LET cOpcodesd          ='';
	LET cOpcodeds          ='';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_mensajes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pAgentTransTypeCode ='' OR  pOpCode=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END IF;
		 
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END IF;
		
		SELECT agent_trans_type_code,opcode,opcode_sd, opcode_ds 
		INTO cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds
		FROM bdisac:"informix".sac_app_cat_mensajes
		WHERE agent_trans_type_code=pAgentTransTypeCode
		AND opcode=pOpCode;
				
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 17/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de mensjes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_obtieneinfoidentificacionbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pCodTipoIdent CHAR(3))
    RETURNING CHAR(5) AS codRet,
		CHAR(3) AS cod_tipo_identificacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodigo CHAR(3);
	DEFINE cTipoIdentificacion CHAR(3);
	DEFINE cCodTipoIdentificacion CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cCodigo = '';
	LET cTipoIdentificacion = '';
	LET cCodTipoIdentificacion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_obtieneinfoidentificacionbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodTipoIdentificacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodTipoIdentificacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_bts_obtieneinfoidentificacion('1','')
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_bts_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cCodigo;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;			
			END FOREACH;
			
		ELIF pIdConsulta = '2' THEN
		
			IF pCodTipoIdent = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_bts_obtieneinfoidentificacion('2',pCodTipoIdent)
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_bts_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cTipoIdentificacion;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;				
			END FOREACH;
		
		ELIF pIdConsulta = '3' THEN
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_app_obtieneinfoidentificacion('1','')
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cCodigo;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;			
			END FOREACH;
		
		ELIF pIdConsulta = '4' THEN
		
			IF pCodTipoIdent = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_app_obtieneinfoidentificacion('2',pCodTipoIdent)
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cTipoIdentificacion;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;				
			END FOREACH;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de obtener los códigos y tipos de identificación válidos para BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_parametrostransrevpagbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdParametro INTEGER, pNumBts CHAR(11))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS id_transaccion,
		CHAR(20) AS agent_user;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cAgentUser CHAR(20);
	DEFINE cIdTransaccionBts CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';	
	LET cAgentUser = '';
	LET cIdTransaccionBts = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cIdTransaccionBts, cAgentUser;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_parametrostransrevpagbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdTransaccionBts, cAgentUser;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdTransaccionBts, cAgentUser;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT FIRST 1 user_name 
		INTO cAgentUser
		FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pNumBts;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(pIdParametro)
		INTO cCodRetSp,cIdTransaccionBts;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 504 THEN
			LET cCodRet = '00954'; --POR EL MOMENTO EL SERVICIO DE BTS NO ESTA OPERANDO, INTÉNTELO MÁS TARDE
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF NVL(cIdTransaccionBts,'') = '' THEN
				LET cCodRet = '00955'; --NO SE PUDO OBTENER PARÁMETRO DE TRANSACCIÓN
			END IF;
		END IF;
		
		RETURN cCodRet, TRIM(cIdTransaccionBts), TRIM(NVL(UPPER(cAgentUser),''));		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar el nombre de AgentUser y el id de la transacción de InterACT.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_queryorder(pUsuario 				CHAR(8),   
											pIdFuncion 				CHAR(10),  
											pTxn_status				CHAR(1),   
											pUnirefnum				CHAR(16),  
											pCode_Company			CHAR(3),   
											pChanneldid				CHAR(3),   
											pLocationunit			CHAR(15),  
											pNnumber				CHAR(15),  
											pTypecode_Branch		CHAR(3),
											pCountrycode_Branch		CHAR(3),   
											pStatecode_Branch		CHAR(3),   
											pTerminalid				CHAR(15),  
											pProcessdate_Qry		CHAR(8),   
											pProcesstime_Qry		CHAR(6),   
											pCode_Operacion			CHAR(5),   
											pCode					CHAR(4),   
											pMessage				CHAR(255), 
											pCode_d					CHAR(4),   
											pMessage_d				CHAR(255), 
											pProcessDate			CHAR(8),   
											pProcessTime			CHAR(6),   
											pRule					CHAR(3),   
											pValue					CHAR(3),   
											pGlobalTrackingNumber	CHAR(20),  
											pOrderStatusCode		CHAR(3),   
											pOrderStatusDate		CHAR(8),   
											pOrderStatusTime		CHAR(6),   
											pUniqueReferenceNumber	CHAR(16),  
											pCodesalecom			CHAR(3),   
											pCountryCode			CHAR(3),   
											pStateCodeSale			CHAR(3),   
											pSaleDate				CHAR(8),   
											pSaleTime				CHAR(6),   
											pCountryCode_o			CHAR(3),   
											pCurrencyCode			CHAR(3),   
											pServiceCode			CHAR(3),   
											pCountryCode_d			CHAR(3),   
											pCurrencyCode_d			CHAR(3),   
											pDeliveryMethodCode		CHAR(3),   
											pPayNetworkCode			CHAR(3),   
											pPaySubNetworkCode		CHAR(15),  
											pBranchNumber			CHAR(15),  
											pAccountTypeCode		CHAR(3),   
											pAccountNumber			CHAR(30),  
											pOriginAmount			CHAR(20),  
											pDestinationAmount		CHAR(20),  
											pRetailExchangeRate		CHAR(21),  
											pWholesaleExchangeRate	CHAR(21),  
											pDestinExchangeRate 	CHAR(21),  
											pServiceFeeAmount		CHAR(20),  
											pDiscountAmount			CHAR(20),  
											pTypeCode				CHAR(3),   
											pAccountNumber_c		CHAR(30),  
											pBicCode				CHAR(11),  
											pReferenceNumber		CHAR(30),  
											pCustomerNumber			CHAR(20),  
											pFirstName				CHAR(40),  
											pMiddleName				CHAR(40),  
											pLastName				CHAR(40),  
											pMotherMaidenName		CHAR(40),  
											pAddress				CHAR(80),  
											pCity					CHAR(40),  
											pCountryCode_a			CHAR(3),   
											pStateCode				CHAR(3),   
											pZipCode				CHAR(10),  
											pTypeCode_i				CHAR(3),   
											pNumber					CHAR(20),  
											pExpirationDate			CHAR(8),   
											pIssuerCountryCode		CHAR(3),   
											pIssuerStateCode		CHAR(3),   
											pDateOfBirth			CHAR(8),   
											pCustomerNumber_b		CHAR(20),  
											pFirstName_b			CHAR(40),  
											pMiddleName_b			CHAR(40),  
											pLastName_b				CHAR(40),  
											pMotherMaidenName_b		CHAR(40),  
											pFirstName_f			CHAR(40),  
											pMiddleName_f			CHAR(40),  
											pLastName_f				CHAR(40),  
											pMotherMaidenName_f		CHAR(40),  
											pAddress_b				CHAR(80),  
											pCity_b					CHAR(40),  
											pCountryCode_b			CHAR(3),   
											pStateCode_b			CHAR(3),   
											pZipCode_b				CHAR(10),  
											pEmail					CHAR(100), 
											pHomePhoneNumber		CHAR(15),  
											pWorkPhoneNumber		CHAR(15),  
											pNumber_cl				CHAR(15),  
											pReceiveEmail			CHAR(3),   
											pReceiveSMS				CHAR(3),   
											pTypeCode_ib			CHAR(3),   
											pNumber_ib				CHAR(20),  
											pExpirationDate_ib		CHAR(8),   
											pIssuerCountryCode_ib	CHAR(3),   
											pIssuerStateCode_ib		CHAR(3),   
											pReasonTypeCode			CHAR(3),   
											pReasonForTransfer		CHAR(40),  
											pSourceOfFunds			CHAR(40),  
											pSecurityPhrase			CHAR(40),  
											pFreeMessage			CHAR(255)) 
    RETURNING CHAR(5) AS codRet,
		CHAR(255) AS desc_CodRet,
		CHAR(255) AS mensaje_D;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(255);
	DEFINE cMensajeD CHAR(255);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cMensajeD = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cDescCodRet,cMensajeD;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_queryorder.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTxn_status = '' OR pUnirefnum = '' OR pCode_Company = '' OR 
		pChanneldid = '' OR pLocationunit = '' OR pNnumber = '' OR pTypecode_Branch = '' OR pCountrycode_Branch = '' OR 
		pStatecode_Branch = '' OR pTerminalid = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDescCodRet,cMensajeD;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDescCodRet,cMensajeD;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_queryorder(pTxn_status,pUnirefnum,pCode_Company,pChanneldid,
		pLocationunit,pNnumber,pTypecode_Branch,pCountrycode_Branch,pStatecode_Branch,pTerminalid,pProcessdate_Qry,		
		pProcesstime_Qry,pCode_Operacion,pCode,pMessage,pCode_d,pMessage_d,pProcessDate,pProcessTime,pRule,					
		pValue,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,pUniqueReferenceNumber,	
		pCodesalecom,pCountryCode,pStateCodeSale,pSaleDate,pSaleTime,pCountryCode_o,pCurrencyCode,pServiceCode,			
		pCountryCode_d,pCurrencyCode_d,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,pBranchNumber,			
		pAccountTypeCode,pAccountNumber,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,	
		pDestinExchangeRate,pServiceFeeAmount,pDiscountAmount,pTypeCode,pAccountNumber_c,pBicCode,pReferenceNumber,		
		pCustomerNumber,pFirstName,pMiddleName,pLastName,pMotherMaidenName,pAddress,pCity,pCountryCode_a,pStateCode,				
		pZipCode,pTypeCode_i,pNumber,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pDateOfBirth,pCustomerNumber_b,		
		pFirstName_b,pMiddleName_b,pLastName_b,pMotherMaidenName_b,pFirstName_f,pMiddleName_f,pLastName_f,pMotherMaidenName_f,		
		pAddress_b,pCity_b,pCountryCode_b,pStateCode_b,pZipCode_b,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pNumber_cl,				
		pReceiveEmail,pReceiveSMS,pTypeCode_ib,pNumber_ib,pExpirationDate_ib,pIssuerCountryCode_ib,pIssuerStateCode_ib,		
		pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,pSecurityPhrase,pFreeMessage,pUsuario) 
		INTO cCodRetSp,cDescCodRet,cMensajeD;		
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_queryorder';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet,cDescCodRet,cMensajeD;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 04/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de generar trama para pago de remesas Appriza Pay.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_submitpayment(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	pterminalid			CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pcustomernumber		CHAR(20),
	pfirstname			CHAR(40),
	pmiddlename			CHAR(40),
	plastname			CHAR(40),
	pmommaidenname	 	CHAR(40),
	padress				CHAR(80),
	pcity				CHAR(40),
	pcountrycodeadr		CHAR(3),
	pstatecodeadr		CHAR(3),
	pzipcode			CHAR(10),
	pemail				CHAR(100),
	phomephonenum		CHAR(15),
	pnumbercel			CHAR(15),
	preceiveemail		CHAR(3),
	preceivesms			CHAR(3),
	ptypecodeci			CHAR(3),
	pnumberci			CHAR(20),
	pexpirationdate		CHAR(8),
	pissuercc			CHAR(3),
	pdateofbirth		CHAR(8),
	pcontrycode			CHAR(5),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_rule				CHAR(3),
	pr_value			CHAR(3),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_codesalecom		CHAR(3),
	pr_countrycode		CHAR(3),
	pr_statecodesale	CHAR(3),
	pr_saledate			CHAR(8),
	pr_saletime			CHAR(6),
	pr_countrycode_o	CHAR(3),
	pr_currencycode		CHAR(3),
	pr_servicecode		CHAR(3),
	pr_countrycode_d	CHAR(3),
	pr_currencycod_d	CHAR(3),
	pr_delimethodcod	CHAR(3),
	pr_playnwcode		CHAR(3),
	pr_paysubnwcode		CHAR(15),
	pr_branchnumber		CHAR(15),
	pr_accounttcod		CHAR(3),
	pr_accountnumber	CHAR(30),
	pr_originamount		CHAR(20),
	pr_destinamount		CHAR(20),
	pr_rexchangerate	CHAR(21),
	pr_wholesalerate	CHAR(21),
	pr_deexhangerate	CHAR(21),
	pr_servfeeamount	CHAR(20),
	pr_discountamoun	CHAR(20),
	pr_typecode			CHAR(3),
	pr_accountnum		CHAR(30),
	pr_biccode			CHAR(11),
	pr_refnumber		CHAR(30),
	pr_customernum		CHAR(20),
	pr_firstname		CHAR(40),
	pr_middlename		CHAR(40),
	pr_lastname			CHAR(40),
	pr_mommaidenname 	CHAR(40),
	pr_address			CHAR(80),
	pr_city				CHAR(40),
	pr_countrycode_a	CHAR(3),
	pr_statecode		CHAR(3),
	pr_zipcode			CHAR(10),
	pr_typecode_i		CHAR(3),
	pr_number			CHAR(20),
	pr_expirdate		CHAR(8),
	pr_isscontrycode	CHAR(3),
	pr_issstatecode		CHAR(3),
	pr_dateofbirth		CHAR(8),
	pr_customernum_b 	CHAR(20),
	pr_firstname_b		CHAR(40),
	pr_middlename_b		CHAR(40),
	pr_lastname_b		CHAR(40),
	pr_mommaidenna_b 	CHAR(40),
	pr_firstname_f		CHAR(40),
	pr_middlename_f		CHAR(40),
	pr_lastname_f		CHAR(40),
	pr_mommaidenna_f 	CHAR(40),
	pr_address_b		CHAR(80),
	pr_city_b			CHAR(40),
	pr_countrycode_b	CHAR(3),
	pr_statecode_b		CHAR(3),
	pr_zipcode_b		CHAR(10),
	pr_email			CHAR(100),
	pr_homephonenum 	CHAR(15),
	pr_workphonenum		CHAR(15),
	pr_number_cl		CHAR(15),
	pr_receiveemail		CHAR(3),
	pr_receivesms		CHAR(3),
	pr_typecode_ib		CHAR(3),
	pr_number_ib		CHAR(20),
	pr_expirdate_ib		CHAR(8),
	pr_issconcode_ib	CHAR(3),
	pr_issstacode_ib	CHAR(3),
	pr_reastypecode		CHAR(3),
	pr_refortransfer	CHAR(40),
	pr_sourceoffunds	CHAR(40),
	pr_securphrase		CHAR(40),
	pr_feemessage		CHAR(255)
	)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   	CHAR(5);
DEFINE iSqlErr   	INTEGER;
DEFINE cCodRetSp 	CHAR(5);
DEFINE iCodRetSp 	INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(255);
DEFINE cError_Desc_Detail CHAR (255);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';
LET cError_Desc_Detail='';
BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_submitpayment.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR NVL(pnnumber, '') = ''  OR NVL(prefnum, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_submitpayment(ptxn_status,punirefnum,prefnum,pcode,pchanneldid,plocationunit,pnnumber,ptypecode,pcountrycode,pstatecode,pterminalid,pprocessdate,pprocesstime,pcustomernumber,pfirstname,pmiddlename,plastname,
		pmommaidenname,padress,pcity,pcountrycodeadr,pstatecodeadr,pzipcode,pemail,phomephonenum,pnumbercel,preceiveemail,preceivesms,ptypecodeci,pnumberci,pexpirationdate,pissuercc,pdateofbirth,pcontrycode,pr_operacion,pr_code,pr_message,pr_code_d,
		pr_message_d,pr_processdate,pr_processtime,pr_rule,pr_value,pr_globtracknum,pr_ordstatuscode,pr_ordstatusdate,pr_ordstatustime,pr_uniquerefnum,pr_codesalecom,pr_countrycode,pr_statecodesale,pr_saledate,pr_saletime,pr_countrycode_o,
		pr_currencycode,pr_servicecode,pr_countrycode_d,pr_currencycod_d,pr_delimethodcod,pr_playnwcode,pr_paysubnwcode,pr_branchnumber,pr_accounttcod,pr_accountnumber,pr_originamount,pr_destinamount,pr_rexchangerate,pr_wholesalerate,
		pr_deexhangerate,pr_servfeeamount,pr_discountamoun,pr_typecode,pr_accountnum,pr_biccode,pr_refnumber,pr_customernum,pr_firstname,pr_middlename,pr_lastname,pr_mommaidenname,pr_address,pr_city,pr_countrycode_a,pr_statecode,
		pr_zipcode,pr_typecode_i,pr_number,pr_expirdate,pr_isscontrycode,pr_issstatecode,pr_dateofbirth,pr_customernum_b,pr_firstname_b,pr_middlename_b,pr_lastname_b,pr_mommaidenna_b,pr_firstname_f,pr_middlename_f,pr_lastname_f,
		pr_mommaidenna_f,pr_address_b,pr_city_b,pr_countrycode_b,pr_statecode_b,pr_zipcode_b,pr_email,pr_homephonenum,pr_workphonenum,pr_number_cl,pr_receiveemail,pr_receivesms,pr_typecode_ib,pr_number_ib,pr_expirdate_ib,pr_issconcode_ib,
		pr_issstacode_ib,pr_reastypecode,pr_refortransfer,pr_sourceoffunds,pr_securphrase,pr_feemessage,pUsuario,CURRENT)
		INTO cCodRetSp ,cError_Desc,cError_Desc_Detail;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_app_submitpayment";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
				
		RETURN cCodRet; 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 17/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Cambio de Estatus Remesas Appriza',
'DESCRIPCION: Guarda respuesta de transaccion al realizar el PAGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_submitpayreversal(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pprocretypecode		CHAR(3),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),	
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	terminalid				CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6)
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   	CHAR(5);
DEFINE iSqlErr   	INTEGER;
DEFINE cCodRetSp 	CHAR(5);
DEFINE iCodRetSp 	INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(255);
DEFINE cError_Desc_Detail CHAR (255);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';
LET cError_Desc_Detail='';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_submitpayreversal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(prefnum, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_submitpayreversal(ptxn_status,punirefnum,prefnum,pprocretypecode,pcode,pchanneldid,plocationunit,pnnumber,ptypecode,pcountrycode,pstatecode,terminalid,pprocessdate,pprocesstime,
		pr_operacion,pr_code,pr_message,pr_code_d,pr_message_d,pr_processdate,pr_processtime,pr_uniquerefnum,pr_globtracknum,pr_ordstatuscode,pr_ordstatusdate,pr_ordstatustime,pUsuario,current)
		INTO cCodRetSp ,cError_Desc,cError_Desc_Detail;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_app_submitpayreversal";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 16/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Cambio de Estatus Remesas Appriza',
'DESCRIPCION: Guarda respuesta de transaccion al realizar el reverso',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaprocesosappriza(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumRem CHAR(12))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaprocesosappriza.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
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
		
		--Valida dígito
		IF pIdConsulta = '1' THEN
		
			IF pNumRem = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF LENGTH(pNumRem) < 12 THEN
				LET cCodRet = '00974'; --EL NÚMERO DE CONFIRMACIÓN DEBE SER DE 12 DÍGITOS
				RETURN cCodRet;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_app_valdigito(pNumRem)
			INTO cCodRetSp;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_valdigito';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 04/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA DE REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de validar los datos de entrada vs los parámetros de consulta establecidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaprocesosbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumBts CHAR(12))
    RETURNING CHAR(5) AS codRet,
		CHAR(10) AS fecha_servidor,
		CHAR(25) AS hora_servidor;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha, dHora;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaprocesosbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, dHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, dHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		--Valida fecha/hr del sistema
		IF pIdConsulta = '1' THEN
		
			EXECUTE PROCEDURE bdinteg:"informix".sp_obtenfechahrasistema()
			INTO cCodRetSp,cFecha,dHora;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_obtenfechahrasistema';
			END IF;
			
			IF TO_CHAR(dHora, '%H%M%S') > (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param = '87011') THEN
				LET cCodRet = '00951'; --HORARIO EXCEDE AL MÁXIMO PARAMETRIZADO
			END IF;
			
		--Valida número de confirmación BTS
		ELIF pIdConsulta = '2' THEN
		
			IF pNumBts = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, dHora;
			ELIF LENGTH(pNumBts) < 11 THEN
				LET cCodRet = '00952'; --NÚMERO DE CONFIRMACIÓN NO VÁLIDO
				RETURN cCodRet, cFecha, dHora;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumBts)
			INTO cCodRetSp,cDescCodRet;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validabts';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
		
		--Valida número de confirmación APPRIZA
		ELIF pIdConsulta = '3' THEN
		
			IF pNumBts = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, dHora;
			ELIF LENGTH(pNumBts) < 12 THEN
				LET cCodRet = '00979'; --EL NÚMERO DE CONFIRMACIÓN DEBE SER DE 12 DÍGITOS
				RETURN cCodRet, cFecha, dHora;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumBts)
			INTO cCodRetSp,cDescCodRet;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validabts';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
			
		END IF;
		
		RETURN cCodRet, cFecha, dHora;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 19/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de validar los datos de entrada vs los parámetros de consulta establecidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaremesabts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11), pFolioSucursal CHAR(16), pFechaRealPago DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(15) AS Sucursal,
		CHAR(15) AS Terminal,
		CHAR(3)  AS R_Type_Cd,
		CHAR(20) AS R_Identif_Nm,
		CHAR(50) AS Nom_Calle,
		CHAR(5)  AS Num_Ext,
		CHAR(5)  AS Num_Int,
		CHAR(10) AS Depto,
		CHAR(80) AS Colonia,
		CHAR(5)  AS Cp,
		CHAR(50) AS Mncpo_Deleg,
		CHAR(50) AS Ciudad,
		CHAR(50) AS Estado,
		CHAR(3)  AS Issuer_Country_Cd,
		CHAR(15) AS Telefono,
		CHAR(1)  AS Tipo_Pago,
		CHAR(8)  AS Fecha_Nac,
		CHAR(50) AS Nacionalidad,
		CHAR(20) AS Pais_Nac,
		CHAR(20) AS Folio_Sucursal,
		CHAR(21) AS R_Issuer_Cd,
		CHAR(22) AS R_Expiration_Dt;
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INT;
	DEFINE cCodRetSp 			CHAR(6);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cDescCodRet 			CHAR(80);
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_Pais_Nac			CHAR(20);
	DEFINE cFolio_Sucursal      CHAR(20);
	DEFINE cR_Issuer_Cd         CHAR(21);
	DEFINE cR_Expiration_Dt     CHAR(22);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cDescCodRet 			= '';
	LET cEmpresa 				= '001';
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_Pais_Nac				= '';
	LET cFolio_Sucursal			= '';
	LET cR_Issuer_Cd            = '';
	LET cR_Expiration_Dt		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
				cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
				cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
				cR_Issuer_Cd,cR_Expiration_Dt;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaremesabts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' OR pFolioSucursal = '' OR pFechaRealPago IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_validarembtsensac(pNumBts,pFolioSucursal,pFechaRealPago)
		INTO cCodRetSp,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
		cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
		cR_Issuer_Cd,cR_Expiration_Dt;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validarembtsensac';
		ELIF cCodRetSp::INTEGER > 0 THEN
			IF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 4 THEN
				LET cCodRet = '00971'; --FECHA REAL DEL PAGO INVALIDA, VERIFIQUE
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF cFolio_Sucursal <> '' AND (pFolioSucursal = cFolio_Sucursal) THEN
				LET cCodRet = '00000';
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		END IF;
		
		RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,UPPER(cR_Colonia),cR_Cp,UPPER(cR_Mncpo_Deleg),UPPER(cR_Ciudad),UPPER(cR_Estado),UPPER(cR_Issuer_Country_Cd),
		cR_Telefono,UPPER(cTipo_Pago),cR_Fecha_Nac,UPPER(cR_Nacionalidad),UPPER(cR_Pais_Nac),cFolio_Sucursal,		
		UPPER(cR_Issuer_Cd),cR_Expiration_Dt;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de validar que exista la remesa que se desea pagar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesamensajeserrorwu(pUsuario CHAR(8), pIdFuncion CHAR(10), pCode CHAR(6), pDescripcion CHAR(255))
		RETURNING CHAR(5) AS codret,
		CHAR(6)     AS codError,       
		CHAR(255)   AS traduccion;
	
	DEFINE cCodRet      CHAR(5);
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodError    CHAR(6);  
	DEFINE cTraduccion  CHAR(255);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet         = '00000';
	LET iSqlErr         = 0;
	LET cCodError       = '';  
	LET cTraduccion     = '';
	LET iNoRegistros    = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodError,cTraduccion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesamensajeserrorwu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCode = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		 
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF EXISTS(SELECT coderror FROM intercard:"informix".wswesternunionerrores WHERE coderror = pCode) THEN
				
			SELECT coderror,NVL(traduccion,'') INTO cCodError,cTraduccion
			FROM intercard:"informix".wswesternunionerrores WHERE coderror=pCode;
							
			RETURN cCodRet,cCodError,cTraduccion;
		
		ELSE
						
			INSERT INTO intercard:"informix".wswesternunionerrores(coderror,traduccion) VALUES(pCode,pDescripcion);
	
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF; 
				
			RETURN cCodRet,pCode,pDescripcion;

				
		END IF;
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 06/06/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: Consulta de Remesas WU',
'DESCRIPCION: SPL que consulta o inserta en el catálogo de mensajes',
'AUTOR: L. Montserrat León Amador',
'FECHA: 21/08/2017',
'DESCRIPCION: Se modifica spl para corregir validación de parámetros de entrada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    CHAR(25),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10) 
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   CHAR(5);
DEFINE iSqlErr   INTEGER;
DEFINE cCodRetSp CHAR(3);
DEFINE iCodRetSp INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(30);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu.out';
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
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current)--pFechaHoraRp
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search";
		ELIF iCodRetSp = 27 THEN
			LET cCodRet = '00976'; -- USUARIO NO TIENE ID. ASIGNADO
		ELIF iCodRetSp = 26 THEN
			LET cCodRet = '00025'; -- NO EXISTE USUARIO, 			 	EL USUARIO NO EXISTE
		ELIF iCodRetSp = 23 THEN
			LET cCodRet = '00978'; -- SE TIENE QUE REVERSAR PRIMERO ANTES DE INTENTAR EL PAGO NUEVAMENTE	
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00977'; -- NO EXISTE MARCA EN SAC PARAM	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00770'; -- ERROR EN EL PROCESO, 				PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 05/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Consulta Remesas WU',
'DESCRIPCION: Guarda respuesta de transaccion en bdisac:sac_wu_search',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_actlimiteremesa_edo_suc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pValor CHAR(4), 
pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_actlimiteremesa_edo_suc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL OR pValor = '' OR 
		pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_DIA_';
			LET cMarca = 'APP';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_DIA_';
			LET cMarca = 'BTS';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_DIA_';
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Actualiza Estado
		IF pIdEjecucion = '1' THEN
		
			UPDATE bdisac:"informix".sac_limite_edo SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND estado = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
				
		--Actualiza Sucursal 
		ELIF pIdEjecucion = '2' THEN
		
			UPDATE bdisac:"informix".sac_limite_suc SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND sucursal = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		--Guarda Sucursal 
		ELIF pIdEjecucion = '3' THEN
			
			INSERT INTO bdisac:"informix".sac_limite_suc (abreviatura,sucursal,pesos,usd,marca,status,descripcion,fecha_insert) 
			VALUES(TRIM(cAbreviatura),TRIM(pValor),pPesos,pUsd,TRIM(cMarca),pStatus,'Limite por operaciones',CURRENT YEAR TO FRACTION(3));
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de guardar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora y estado o sucursal seleccionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoestado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_estado,
			CHAR(30) AS desc_estado;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdEstado = 0;
	LET cDescEstado = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdEstado, cDescEstado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoestado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
		IF pIdConsulta = '1' THEN
			LET cMarca = 'APP';
		ELIF pIdConsulta = '2' THEN
			LET cMarca = 'BTS';
		ELIF pIdConsulta = '3' THEN
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT a.estado, b.nombre
			INTO cIdEstado, cDescEstado
			FROM bdisac:"informix".sac_limite_edo AS a, bdinteg:"informix".si_estados As b 
			WHERE a.estado = b.estado AND a.marca = TRIM(cMarca) ORDER BY a.estado ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdEstado, TRIM(UPPER(cDescEstado)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estado, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoremesadora(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_remesadora,
			CHAR(100) AS desc_remesadora;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdRemesadora SMALLINT;
	DEFINE cDescRemesadora CHAR(100);
	DEFINE cGpoRemesadora CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdRemesadora = 0;
	LET cDescRemesadora = '';
	LET cGpoRemesadora = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoremesadora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
			LET cGpoRemesadora = 'A';
		ELIF pIdConsulta = '3' THEN
			LET cGpoRemesadora = 'C';
		END IF;
		
		IF pIdConsulta = '1' OR pIdConsulta = '3' THEN
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora = TRIM(cGpoRemesadora)
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
		
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		ELIF pIdConsulta = '4' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B','C')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo remesadora dependiendo del tipo de límite seleccionado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogostatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_status,
			CHAR(12) AS desc_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(2);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = 0;
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogostatus.out';
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
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT id_status,desc_status 
			INTO cIdStatus, cDescStatus
			FROM bdicnweb:"informix".sw_rem_statuslimite
			ORDER BY id_status ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdStatus, TRIM(UPPER(cDescStatus)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar los status disponibles del límite de remesas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_monto_acum(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), 
pTipoMonto CHAR(1), pIdRemesadora SMALLINT, pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret,
			MONEY(16,2) AS usd,
			MONEY(16,2) AS pesos,
			SMALLINT AS status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE mUsd MONEY(16,2);
	DEFINE mPesos MONEY(16,2);
	DEFINE sStatus SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET mUsd = 0.00;
	LET mPesos = 0.00;
	LET sStatus = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_monto_acum.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pTipoMonto = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
		
		IF pTipoMonto = 'D' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_DIA_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_DIA_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_DIA_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_DIA_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_DIA_AUT_';
			END IF;
		
		ELIF pTipoMonto = 'M' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_MES_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_MES_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_MES_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_MES_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_MES_AUT_';
			END IF;
			
		ELIF pTipoMonto = 'A' THEN
		
			IF pIdRemesadora = 6 THEN
				LET cAbreviatura = 'TODAS_';
			END IF;
			
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT usd, pesos, status 
			INTO mUsd, mPesos, sStatus
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, mUsd, mPesos, sStatus;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, mUsd, mPesos, sStatus;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_numtrans(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pNoTransacciones SMALLINT)
		RETURNING CHAR(5) AS codret,
			SMALLINT AS no_transacciones;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE sNoTransacciones SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET sNoTransacciones = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sNoTransacciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_numtrans.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sNoTransacciones;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sNoTransacciones;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_MES_';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_MES_';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_MES_';
		ELIF pIdRemesadora = 4 THEN
			LET cAbreviatura = 'APP_MES_AUT_';
		ELIF pIdRemesadora = 5 THEN
			LET cAbreviatura = 'BTS_MES_AUT_';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT operaciones
			INTO sNoTransacciones
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pNoTransacciones IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sNoTransacciones;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET operaciones = pNoTransacciones--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, sNoTransacciones;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 19/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el número de transacciones, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_generarepremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClaveId CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS limite,
		DATE AS fecha_env,
		CHAR(40) AS nombre1_ord,
		CHAR(40) AS nombre2_ord,
		CHAR(40) AS appaterno_ord,
		CHAR(40) AS apmaterno_ord,
		CHAR(80) AS direccion_ord,
		CHAR(80) AS colonia_ord,
		CHAR(40) AS ciudad_ord,
		CHAR(3) AS estado_ord,
		CHAR(3) AS pais_ord,
		CHAR(3) AS tipoid_ord,
		CHAR(20) AS numeroid_ord,
		CHAR(3) AS ciudadid_ord,
		CHAR(3) AS paisid_ord,
		CHAR(3) AS moneda_ord,
		CHAR(20) AS monto_origen,
		CHAR(20) AS monto_pesos,
		CHAR(40) AS nombre1_ben,
		CHAR(40) AS nombre2_ben,
		CHAR(40) AS appaterno_ben,
		CHAR(40) AS apmaterno_ben,
		CHAR(8) AS fechanacimiento_ben,
		CHAR(80) AS direccion_ben,
		CHAR(80) AS colonia_ben,
		CHAR(40) AS ciudad_ben,
		CHAR(40) AS estado_ben,
		CHAR(15) AS telefono_ben,
		CHAR(3) AS tipoid_ben,
		CHAR(20) AS numeroid_ben,
		CHAR(4) AS numeroid_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
				cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
				cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generarepremesasnopagadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pClaveId = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		IF pIdLimite = 8 THEN
			LET pIdLimite = NULL;
		END IF;
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion limite,fecha_env,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,
			tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,
			fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc
			INTO cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc				
			FROM bdicnweb:"informix".sw_detalleremesasnopagadas
			WHERE id_limite = (CASE WHEN pIdLimite IS NULL THEN id_limite ELSE pIdLimite END)
			AND fecha_env BETWEEN pFechaInicio AND pFechaFin
			AND usuario_insert = pUsuario AND clave_id = TRIM(pClaveId)
			ORDER BY limite,fecha_env ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc WITH RESUME;
			
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de consultar el detalle de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_verificastatusremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS num_registros,
			  CHAR(100) AS clave_id,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iNumRegistros INTEGER;
	DEFINE cClaveId CHAR(100);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iNumRegistros = 0;
	LET cClaveId = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_verificastatusremesasnopagadas.out';
		--TRACE ON;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,clave_id,error_proceso,error
		INTO cStatus,iNumRegistros,cClaveId,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_statusprocesoremnopag WHERE usuario_insert = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I',0,'','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/01/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de verificar el status del proceso de consulta de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallefacturacionos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCte CHAR(9), 
pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoFecha SMALLINT, pTipoConsulta SMALLINT)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;	
	
	DEFINE cCodRet 		  CHAR(5);
	DEFINE iSqlErr 		  INTEGER;
	DEFINE cCodRetSp 	  CHAR(6);
	DEFINE cDesCodRetSp   CHAR(50);
	DEFINE cEmpresa 	  CHAR(3);
	DEFINE cSucursal      CHAR (4);
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iImpresas      INTEGER;
	DEFINE dImpresasPor   DECIMAL(5,2);
	DEFINE iNoImpresas    INTEGER;
	DEFINE dNoImpresasPor DECIMAL(5,2);
	DEFINE iStatusA       INTEGER;
	DEFINE dStatusAPor    DECIMAL(5,2);
	DEFINE iStatusR       INTEGER;
	DEFINE dStatusRPor    DECIMAL(5,2);
	DEFINE iStatusD       INTEGER;
	DEFINE dStatusDPor    DECIMAL(5,2);
	DEFINE iStatusS       INTEGER;
	DEFINE dStatusSPor    DECIMAL(5,2);
	DEFINE iBancoppel     INTEGER;
	DEFINE iCoppel        INTEGER;
	DEFINE iMixta         INTEGER;
	DEFINE iTotal         INTEGER;
	DEFINE iNumRegistros  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet 		  = '00000';
	LET iSqlErr           = 0;
	LET cCodRetSp 		  = '';
	LET cDesCodRetSp 	  = '';
	LET cEmpresa 		  = '001';
	LET cSucursal         = '';
	LET iTotalEnviadas    = 0;
	LET iImpresas         = 0;
	LET dImpresasPor      = 0;
	LET iNoImpresas       = 0;
	LET dNoImpresasPor    = 0;
	LET iStatusA          = 0;
	LET dStatusAPor       = 0;
	LET iStatusR          = 0;
	LET dStatusRPor       = 0;
	LET iStatusD          = 0;
	LET dStatusDPor       = 0;
	LET iStatusS          = 0;
	LET dStatusSPor       = 0;
	LET iBancoppel        = 0;
	LET iCoppel           = 0;
	LET iMixta            = 0;
	LET iTotal            = 0;
	LET iNumRegistros     = 0;
	LET iRecuperacion	  = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallefacturacionos_totales.out';
		--TRACE ON;

		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_statusproceso_os WHERE usuario = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_statusproceso_os(usuario,status,num_registros,error_proceso,error)
		VALUES(pUsuario,'I',0,'',TRIM(cCodRet)); 
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pTipoFecha IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_facturacion_os WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			EXECUTE PROCEDURE bdisolic:"informix".sp_consultarfacturacionos2(cEmpresa,pSucursal,pNumCte,pFechaInicio,pFechaFin,pTipoFecha,pTipoConsulta,0,0)
			INTO cCodRetSp, cSucursal, iTotalEnviadas, iImpresas, dImpresasPor, iNoImpresas, dNoImpresasPor, iStatusA, dStatusAPor, 
			iStatusR, dStatusRPor, iStatusD, dStatusDPor, iStatusS, dStatusSPor, iBancoppel, iCoppel, iMixta, iTotal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_consultarfacturacionos2';
			ELIF cCodRetSp::INTEGER = 1 OR cCodRetSp::INTEGER = 4 THEN 
				LET cCodRet = '00044'; --EL TIPO DE BUSQUEDA ES INCORRECTO
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 2 OR cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 5 THEN 
				LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 6 THEN 
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			END IF;
				
			LET iRecuperacion = iRecuperacion + 1;
			INSERT INTO bdicnweb:"informix".sw_facturacion_os(sucursal,total_enviadas,impresas_n,impresas_p,no_impresas_n,no_impresas_p,
			statusA_n,statusA_p,statusR_n,statusR_p,statusD_n,statusD_p,statusS_n,statusS_p,bancoppel,coppel,mixta,total,usuario_insert)
			VALUES(cSucursal,iTotalEnviadas,iImpresas,dImpresasPor,iNoImpresas,dNoImpresasPor,iStatusA,dStatusAPor,iStatusR,dStatusRPor, 
			iStatusD,dStatusDPor,iStatusS,dStatusSPor,iBancoppel,iCoppel,iMixta,iTotal,pUsuario);
		END FOREACH;
		
		SELECT COUNT(*) 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_facturacion_os 
		WHERE usuario_insert = pUsuario;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		UPDATE bdicnweb:"informix".sw_statusproceso_os
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = TRIM(pUsuario);  
		RETURN cCodRet, NVL(iNumRegistros,0);
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 20/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el número total de facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catcalles_consecutivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		INTEGER AS secuencia;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iSecuencia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iSecuencia=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iSecuencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catcalles_consecutivo.out';
		--TRACE ON;
		
		IF pUsuario = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		INSERT INTO sw_cli_calles_consecutivo(us_insert,fecha_insert) VALUES(pUsuario, CURRENT);
		
		SELECT MAX(id_serial) INTO iSecuencia FROM sw_cli_calles_consecutivo;
		
		RETURN cCodRet, iSecuencia;
	
	END;
	
END PROCEDURE;