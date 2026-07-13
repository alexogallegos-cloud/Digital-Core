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