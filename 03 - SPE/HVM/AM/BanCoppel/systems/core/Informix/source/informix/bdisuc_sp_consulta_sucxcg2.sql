CREATE PROCEDURE "informix".sp_consulta_sucxcg2(vplaza_cajagen CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5), CHAR(100), VARCHAR(4), VARCHAR(40);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret VARCHAR(5);
DEFINE msj VARCHAR(100);
DEFINE vsucursal VARCHAR(4);
DEFINE vnombre VARCHAR(40);

LET cod_ret = '00000';
LET msj = 'Operación exitosa';
LET vsucursal = '';
LET vnombre = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;
        LET msj = ERROR_INFO;
        RETURN cod_ret, msj, vsucursal, vnombre;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    
    IF vplaza_cajagen = '0000' THEN -- Validación para consultar por TODAS las sucursales.
        FOREACH
            SELECT {+index(bdisuc:ss_proveedores idx01ss_proveedores)}
                   SKIP pRegistros FIRST pRecuperacion S.sucursal, S.nombre
              INTO vsucursal, vnombre
              FROM bdinteg:si_sucursales S, 
                   bdisuc:ss_proveedores P
             WHERE P.plaza = S.plaza_cajagen 
               AND S.tpo_sucursal = 'S'
             ORDER BY S.sucursal

            RETURN cod_ret, msj, vsucursal, vnombre WITH RESUME;
        END FOREACH;
    ELSE -- Validación para consultar por una sucursal en especifico.
        FOREACH
            SELECT {+index(bdisuc:ss_proveedores idx01ss_proveedores)}
                   SKIP pRegistros FIRST pRecuperacion S.sucursal, S.nombre
              INTO vsucursal, vnombre
              FROM bdinteg:si_sucursales S, 
                   bdisuc:ss_proveedores P
             WHERE P.plaza = S.plaza_cajagen 
               AND P.cod_proveedor = vplaza_cajagen 
               AND S.tpo_sucursal = 'S'
             ORDER BY S.sucursal

            RETURN cod_ret, msj, vsucursal, vnombre WITH RESUME;
        END FOREACH;
    END IF;

END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 09/03/2017',
'DESCRIPCION: Se clona spl para agregar paginación.';

CREATE PROCEDURE "informix".sp_catsecciones_oemn(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS seccion,
		CHAR(100) AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iSeccion SMALLINT;
	DEFINE cDescripcion CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iSeccion = 0;
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iSeccion, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catsecciones_oemn.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iSeccion, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iSeccion, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSeccion, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion seccion, descripcion
			INTO iSeccion, cDescripcion
			FROM bdisuc:"informix".sw_ope_reportesoemn
			ORDER BY seccion ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iSeccion, TRIM(UPPER(cDescripcion)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iSeccion, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iSeccion, cDescripcion;
		END IF;

	END;
END PROCEDURE
--DOCUMENT 'AUTOR: L. Montserrat León Amador',
--'FECHA: 28/02/2018',
--'MODULO: OPERACIONES',
--'FUNCIONALIDAD: GENERACIÓN DE REPORTES EN EFECTIVO EN MONEDA NACIONAL',
--'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de los reportes en efectivo en moneda nacional.',
--'BD: bdisuc';;

CREATE PROCEDURE "informix".sp_ope_actualizacuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pClave CHAR(1), pDescripcion CHAR(100))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(1);
	DEFINE cDescripcion CHAR(100);
	DEFINE dFecha DATE;
	DEFINE cHora CHAR(8);
	DEFINE iContAct INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET dFecha = '';
	LET cHora = '';
	LET iContAct = 0;
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizacuentas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion = '' OR pClave = '' OR pDescripcion = '' THEN
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
		
		-- SE VALIDA SI LA INFORMACIÓN EXISTE (INSERT)
		IF pEjecucion = '1' THEN
		
			IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_tiposctas WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave)) AND TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
				LET cCodRet = '01045'; --LA CLAVE Y DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTEN. VERIFIQUE
			ELIF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_tiposctas WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave))) THEN
				LET cCodRet = '90000'; --LA CLAVE QUE DESEA DAR DE ALTA YA EXISTE. ¿DESEA ACTUALIZAR EL REGISTRO?
			ELSE
				IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_tiposctas WHERE TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
					LET cCodRet = '01050'; --LA DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
				ELSE
				
					INSERT INTO bdisuc:"informix".ss_tiposctas(clave,descripcion)
					VALUES(pClave,pDescripcion);
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00282';
						RETURN cCodRet;
					ELSE
					
						LET dFecha = DATE(CURRENT);
						LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');

						-- BITACORÉO
						INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
						VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO clave EN LA TABLA bdisuc:"informix".ss_tiposctas',null,pClave);
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00282';
							RETURN cCodRet;
						ELSE
							
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO descripcion EN LA TABLA bdisuc:"informix".ss_tiposctas',null,pDescripcion);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
						END IF;
					END IF;
					
				END IF;
			END IF;
		
		-- SE REALIZA LA ACTUALIZACIÓN DE LA INFORMACIÓN (UPDATE)
		ELIF pEjecucion = '2' THEN
		
			SELECT clave,descripcion
			INTO cClave,cDescripcion
			FROM bdisuc:"informix".ss_tiposctas
			WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
			
			IF NVL(cClave,'') <> '' THEN
			
				LET dFecha = DATE(CURRENT);
				LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
						
				IF TRIM(UPPER(pDescripcion)) <> TRIM(UPPER(cDescripcion)) THEN
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_tiposctas WHERE TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
						LET cCodRet = '01050'; --LA DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
						RETURN cCodRet;
					ELSE
					
						UPDATE bdisuc:"informix".ss_tiposctas SET descripcion = pDescripcion
						WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						ELSE
						
							-- BITACORÉO
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE ACTUALIZA EL CAMPO descripcion EN LA TABLA bdisuc:"informix".ss_tiposctas',cDescripcion,pDescripcion);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
							
						END IF;
					
						LET iContAct = iContAct + 1;
					
					END IF;
					
				END IF;
				
				IF NVL(iContAct,0) = 0 THEN
					LET cCodRet = '01045'; --LA CLAVE Y DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTEN. VERIFIQUE
				END IF;
				
			ELSE
				LET cCodRet = '00001';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - TIPOS DE CUENTAS',
'DESCRIPCION: SPL encargado de insertar y/o actualizar un registro al catálogo de tipos de cuentas.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_actualizanivcuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pClave CHAR(1), pDescripcion CHAR(30))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(1);
	DEFINE cDescripcion CHAR(30);
	DEFINE dFecha DATE;
	DEFINE cHora CHAR(8);
	DEFINE iContAct INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET dFecha = '';
	LET cHora = '';
	LET iContAct = 0;
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizanivcuentas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion = '' OR pClave = '' OR pDescripcion = '' THEN
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
		
		-- SE VALIDA SI LA INFORMACIÓN EXISTE (INSERT)
		IF pEjecucion = '1' THEN
		
			IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_nivelesctas WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave)) AND TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
				LET cCodRet = '01045'; --LA CLAVE Y DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTEN. VERIFIQUE
			ELIF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_nivelesctas WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave))) THEN
				LET cCodRet = '90000'; --LA CLAVE QUE DESEA DAR DE ALTA YA EXISTE. ¿DESEA ACTUALIZAR EL REGISTRO?
			ELSE
				IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_nivelesctas WHERE TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
					LET cCodRet = '01050'; --LA DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
				ELSE
				
					INSERT INTO bdisuc:"informix".ss_nivelesctas(clave,descripcion)
					VALUES(pClave,pDescripcion);
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00282';
						RETURN cCodRet;
					ELSE
					
						LET dFecha = DATE(CURRENT);
						LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');

						-- BITACORÉO
						INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
						VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO clave EN LA TABLA bdisuc:"informix".ss_nivelesctas',null,pClave);
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00282';
							RETURN cCodRet;
						ELSE
							
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO descripcion EN LA TABLA bdisuc:"informix".ss_nivelesctas',null,pDescripcion);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
						END IF;
					END IF;
					
				END IF;
			END IF;
		
		-- SE REALIZA LA ACTUALIZACIÓN DE LA INFORMACIÓN (UPDATE)
		ELIF pEjecucion = '2' THEN
		
			SELECT clave,descripcion
			INTO cClave,cDescripcion
			FROM bdisuc:"informix".ss_nivelesctas
			WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
			
			IF NVL(cClave,'') <> '' THEN
			
				LET dFecha = DATE(CURRENT);
				LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
						
				IF TRIM(UPPER(pDescripcion)) <> TRIM(UPPER(cDescripcion)) THEN
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_nivelesctas WHERE TRIM(UPPER(descripcion)) = TRIM(UPPER(pDescripcion))) THEN
						LET cCodRet = '01050'; --LA DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
						RETURN cCodRet;
					ELSE
					
						UPDATE bdisuc:"informix".ss_nivelesctas SET descripcion = pDescripcion
						WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						ELSE
						
							-- BITACORÉO
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE ACTUALIZA EL CAMPO descripcion EN LA TABLA bdisuc:"informix".ss_nivelesctas',cDescripcion,pDescripcion);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
							
						END IF;
					
						LET iContAct = iContAct + 1;
					
					END IF;
					
				END IF;
				
				IF NVL(iContAct,0) = 0 THEN
					LET cCodRet = '01045'; --LA CLAVE Y DESCRIPCIÓN QUE DESEA DAR DE ALTA YA EXISTEN. VERIFIQUE
				END IF;
				
			ELSE
				LET cCodRet = '00001';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - NIVELES DE CUENTAS',
'DESCRIPCION: SPL encargado de insertar y/o actualizar un registro al catálogo de niveles de cuentas.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_actualizatransportadora(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecucion CHAR(1), pClave CHAR(6), pRfc CHAR(13), pRazonSocial CHAR(200), pNomCorto CHAR(60))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(6);
	DEFINE cRfc CHAR(13);
	DEFINE cRazonSocial CHAR(200);
	DEFINE cNomCorto CHAR(60);
	DEFINE dFecha DATE;
	DEFINE cHora CHAR(8);
	DEFINE iContAct INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cRfc = '';
	LET cRazonSocial = '';
	LET cNomCorto = '';
	LET dFecha = '';
	LET cHora = '';
	LET iContAct = 0;
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizatransportadora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecucion = '' OR pClave = '' OR pRfc = '' OR pRazonSocial = '' OR pNomCorto = '' THEN
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
		
		-- SE VALIDA SI LA INFORMACIÓN EXISTE (INSERT)
		IF pEjecucion = '1' THEN
		
			IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave))) THEN
				LET cCodRet = '90000'; --LA CLAVE QUE DESEA DAR DE ALTA YA EXISTE. ¿DESEA ACTUALIZAR EL REGISTRO?
			ELSE
				IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(rfc)) = TRIM(UPPER(pRfc))) THEN
					LET cCodRet = '01047'; --EL RFC QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE		
				ELIF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(razonsocial)) = TRIM(UPPER(pRazonSocial))) THEN
					LET cCodRet = '01048'; --EL NOMBRE O RAZÓN SOCIAL QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
				ELIF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(nomcorto)) = TRIM(UPPER(pNomCorto))) THEN
					LET cCodRet = '01049'; --EL NOMBRE CORTO QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
				ELSE
				
					INSERT INTO bdisuc:"informix".ss_transp_val(clave,rfc,razonsocial,nomcorto)
					VALUES(pClave,pRfc,pRazonSocial,pNomCorto);
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00282';
						RETURN cCodRet;
					ELSE
					
						LET dFecha = DATE(CURRENT);
						LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
	
						-- BITACORÉO
						INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
						VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO clave EN LA TABLA bdisuc:"informix".ss_transp_val',null,pClave);
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00282';
							RETURN cCodRet;
						ELSE
						
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO rfc EN LA TABLA bdisuc:"informix".ss_transp_val',null,pRfc);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							ELSE
							
								INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
								VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO razonsocial EN LA TABLA bdisuc:"informix".ss_transp_val',null,pRazonSocial);
						
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00282';
									RETURN cCodRet;
								ELSE
								
									INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
									VALUES(dFecha,cHora,pUsuario,'SE INSERTA UN NUEVO CAMPO nomcorto EN LA TABLA bdisuc:"informix".ss_transp_val',null,pNomCorto);
							
									IF DBINFO('sqlca.sqlerrd2') = 0 THEN
										LET cCodRet = '00282';
										RETURN cCodRet;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
					
				END IF;
			END IF;
		
		-- SE REALIZA LA ACTUALIZACIÓN DE LA INFORMACIÓN (UPDATE)
		ELIF pEjecucion = '2' THEN
		
			SELECT clave,rfc,razonsocial,nomcorto
			INTO cClave,cRfc,cRazonSocial,cNomCorto
			FROM bdisuc:"informix".ss_transp_val
			WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
			
			IF NVL(cClave,'') <> '' THEN
			
				LET dFecha = DATE(CURRENT);
				LET cHora = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%I:%M:%S');
						
				IF TRIM(UPPER(pRfc)) <> TRIM(UPPER(cRfc)) THEN
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(rfc)) = TRIM(UPPER(pRfc))) THEN
						LET cCodRet = '01047'; --EL RFC QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
						RETURN cCodRet;
					ELSE
					
						UPDATE bdisuc:"informix".ss_transp_val SET rfc = pRfc
						WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						ELSE
						
							-- BITACORÉO
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE ACTUALIZA EL CAMPO rfc EN LA TABLA bdisuc:"informix".ss_transp_val',cRfc,pRfc);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
							
						END IF;
					
						LET iContAct = iContAct + 1;
						
					END IF;
					
				END IF;
				
				IF TRIM(UPPER(pRazonSocial)) <> TRIM(UPPER(cRazonSocial)) THEN
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(razonsocial)) = TRIM(UPPER(pRazonSocial))) THEN
						LET cCodRet = '01048'; --EL NOMBRE O RAZÓN SOCIAL QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
						RETURN cCodRet;
					ELSE
					
						UPDATE bdisuc:"informix".ss_transp_val SET razonsocial = pRazonSocial
						WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						ELSE
						
							-- BITACORÉO
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE ACTUALIZA EL CAMPO razonsocial EN LA TABLA bdisuc:"informix".ss_transp_val',cRazonSocial,pRazonSocial);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
							
						END IF;
					
						LET iContAct = iContAct + 1;
						
					END IF;
					
				END IF;
				
				IF TRIM(UPPER(pNomCorto)) <> TRIM(UPPER(cNomCorto)) THEN
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_transp_val WHERE TRIM(UPPER(nomcorto)) = TRIM(UPPER(pNomCorto))) THEN
						LET cCodRet = '01049'; --EL NOMBRE CORTO QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
						RETURN cCodRet;
					ELSE
					
						UPDATE bdisuc:"informix".ss_transp_val SET nomcorto = pNomCorto
						WHERE TRIM(UPPER(clave)) = TRIM(UPPER(pClave));
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						ELSE
						
							-- BITACORÉO
							INSERT INTO bdisuc:"informix".oemn_bitacora(fecha,hora,usuario,accion,val_ant,val_new)
							VALUES(dFecha,cHora,pUsuario,'SE ACTUALIZA EL CAMPO nomcorto EN LA TABLA bdisuc:"informix".ss_transp_val',cNomCorto,pNomCorto);
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00282';
								RETURN cCodRet;
							END IF;
							
						END IF;
					
						LET iContAct = iContAct + 1;
					
					END IF;
					
				END IF;
				
				IF NVL(iContAct,0) = 0 THEN
					LET cCodRet = '01043'; --LA INFORMACIÓN QUE DESEA DAR DE ALTA YA EXISTE. VERIFIQUE
				END IF;
				
			ELSE
				LET cCodRet = '00001';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 26/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - TRANSPORTADORA DE VALORES',
'DESCRIPCION: SPL encargado de insertar y/o actualizar un registro al catálogo de transportadora de valores.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_catestadomunicipio(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(1), pEstado CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(3) AS clave,
		CHAR(30) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catestadomunicipio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pConsulta = '1' THEN
			
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion TRIM(estado) AS estado, TRIM(nombre) AS nombre
				INTO cClave, cDescripcion
				FROM bdinteg:"informix".si_estados
				ORDER BY 2 ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
			END FOREACH;
			
		ELIF pConsulta = '2' THEN
		
			IF pEstado = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
			
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion TRIM(municipio) AS municipio, TRIM(nombre) AS nombre
				INTO cClave, cDescripcion
				FROM bdinteg:"informix".si_municipios
				WHERE estado = pEstado
				ORDER BY 2 ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - SUC´S, BÓVEDA Y ATM',
'DESCRIPCION: SPL encargado de consultar el detalle de los catálogos estado y municipio.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallecontrapartes(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave CHAR(6), pDescripcion CHAR(40), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(6) AS contraparte,
		CHAR(40) AS descripcion,
		CHAR(20) AS nombre_corto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cContraparte CHAR(6);
	DEFINE cDescripcion CHAR(40);
	DEFINE cNomCorto CHAR(20);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cContraparte = '';
	LET cDescripcion = '';
	LET cNomCorto = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallecontrapartes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion '0'||LEFT(TRIM(casfim),2)||RIGHT(TRIM(casfim),3) AS contraparte, TRIM(descripcion) AS nombre, TRIM(vchrnombrecorto) AS nombrecorto
			INTO cContraparte, cDescripcion, cNomCorto
			FROM bdinteg:"informix".si_bancos
			WHERE casfim IS NOT NULL 
			AND '0'||LEFT(TRIM(casfim),2)||RIGHT(TRIM(casfim),3) = (CASE WHEN TRIM(pClave) = '' THEN '0'||LEFT(TRIM(casfim),2)||RIGHT(TRIM(casfim),3) ELSE TRIM(pClave) END) 
			AND UPPER(descripcion) LIKE (CASE WHEN TRIM(UPPER(pDescripcion)) = '' THEN UPPER(descripcion) ELSE '%'||TRIM(UPPER(pDescripcion))||'%' END)
			ORDER BY 2 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cContraparte, UPPER(cDescripcion), UPPER(cNomCorto) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01039'; --EL CATÁLOGO DE CONTRAPARTES NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cContraparte, cDescripcion, cNomCorto;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - CONTRAPARTES',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de contrapartes (bancos).',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallecontrapartes_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave CHAR(6), pDescripcion CHAR(40))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cContraparte CHAR(6);
	DEFINE cDescripcion CHAR(40);
	DEFINE cNomCorto CHAR(20);
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cContraparte = '';
	LET cDescripcion = '';
	LET cNomCorto = '';
	LET iRecuperacion = 0;
	LET iNumRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallecontrapartes_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdinteg:"informix".si_bancos
		WHERE casfim IS NOT NULL 
		AND '0'||LEFT(TRIM(casfim),2)||RIGHT(TRIM(casfim),3) = (CASE WHEN TRIM(pClave) = '' THEN '0'||LEFT(TRIM(casfim),2)||RIGHT(TRIM(casfim),3) ELSE TRIM(pClave) END) 
		AND UPPER(descripcion) LIKE (CASE WHEN TRIM(UPPER(pDescripcion)) = '' THEN UPPER(descripcion) ELSE '%'||TRIM(UPPER(pDescripcion))||'%' END);
	
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '01039'; --EL CATÁLOGO DE CONTRAPARTES NO CUENTA CON INFORMACIÓN
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - CONTRAPARTES',
'DESCRIPCION: SPL encargado de consultar el número total de registros que retornará el detalle del catálogo de contrapartes (bancos).',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallecuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(1) AS clave,
		CHAR(100) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(1);
	DEFINE cDescripcion CHAR(100);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallecuentas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion TRIM(clave) AS clave, TRIM(descripcion) AS descripcion
			INTO cClave, cDescripcion
			FROM bdisuc:"informix".ss_tiposctas
			ORDER BY 1 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01044'; --EL CATÁLOGO DE TIPOS DE CUENTAS NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - TIPOS DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de tipos de cuentas.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallenivcuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(1) AS clave,
		CHAR(30) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(1);
	DEFINE cDescripcion CHAR(30);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallenivcuentas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion TRIM(clave) AS clave, TRIM(descripcion) AS descripcion
			INTO cClave, cDescripcion
			FROM bdisuc:"informix".ss_nivelesctas
			ORDER BY 2 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01046'; --EL CATÁLOGO DE NIVELES DE CUENTAS NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - NIVELES DE CUENTAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de niveles de cuentas.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetalleoperacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(4) AS clave,
		CHAR(35) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetalleoperacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH			
			SELECT SKIP pRegistros FIRST pRecuperacion TRIM(codigo) AS clave, TRIM(descripcion) AS descripcion
			INTO cClave, cDescripcion
			FROM bdisuc:"informix".ss_param_cajagen
			WHERE TRIM(codigo) NOT IN ('0010','0011','0012','0013','0014','0015','0016','0017','0018','0019','0020','0021','0022','0023','0024')
			AND TRIM(UPPER(codigo)) = (CASE WHEN TRIM(UPPER(pClave)) = '' THEN codigo ELSE TRIM(UPPER(pClave)) END) 
			ORDER BY 2 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cClave, UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01040'; --EL CATÁLOGO DE TIPOS DE OPERACIÓN NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - TIPOS DE OPERACIÓN',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de tipos de operación.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallesucbovatm(pUsuario CHAR(8), pIdFuncion CHAR(10), pId CHAR(8), pCveEdo CHAR(2), pCveMun CHAR(3),
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(3) AS institucion,
		CHAR(8) AS id_suc_caj,
		CHAR(40) AS nom_suc_caj,
		CHAR(100) AS calle,
		CHAR(6) AS numero,
		CHAR(8) AS colonia,
		CHAR(5) AS cp,
		CHAR(14) AS localidad,
		CHAR(3) AS municipio,
		CHAR(2) AS estado,
		CHAR(1) AS entrega_billetes,
		DATE AS fecha_alta,
		CHAR(1) AS tipo_caja;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cInstitucion CHAR(3);
	DEFINE cIdSucCaj CHAR(8);
	DEFINE cNomSucCaj CHAR(40);
	DEFINE cCalle CHAR(100);
	DEFINE cNumero CHAR(6);
	DEFINE cColonia CHAR(8);
	DEFINE cCp CHAR(5);
	DEFINE cLocalidad CHAR(14);
	DEFINE cMunicipio CHAR(3);
	DEFINE cEstado CHAR(2);
	DEFINE cEntBilletes CHAR(1);
	DEFINE dFechaAlta DATE;
	DEFINE cTipoCaja CHAR(1);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cInstitucion = '';
	LET cIdSucCaj = '';
	LET cNomSucCaj = '';
	LET cCalle = '';
	LET cNumero = '';
	LET cColonia = '';
	LET cCp = '';
	LET cLocalidad = '';
	LET cMunicipio = '';
	LET cEstado = '';
	LET cEntBilletes = '';
	LET dFechaAlta = '';
	LET cTipoCaja = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
				cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallesucbovatm.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion institucion,
			TRIM(id_suc_caj), TRIM(nom_suc_caja), TRIM(calle), TRIM(numero), TRIM(colonia), TRIM(cp),
			TRIM(localidad), TRIM(municipio), TRIM(estado), TRIM(ent_billetes), fecha_alta, TRIM(tipo_caja)
			INTO cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja
			FROM bdisuc:"informix".sw_ope_detallesucbovatm
			WHERE usuario_insert = pUsuario 
			AND tipo_caja IN ('S','A','B')
			AND NVL(id_suc_caj,'') = (CASE WHEN TRIM(pId) = '' THEN NVL(id_suc_caj,'') ELSE TRIM(pId) END)
			AND NVL(estado,'') = (CASE WHEN TRIM(pCveEdo) = '' THEN NVL(estado,'') ELSE TRIM(pCveEdo) END) 
			AND NVL(municipio,'') = (CASE WHEN TRIM(pCveMun) = '' THEN NVL(municipio,'') ELSE TRIM(pCveMun) END)
			ORDER BY 3 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cInstitucion, UPPER(cIdSucCaj), UPPER(cNomSucCaj), UPPER(cCalle), cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, UPPER(cTipoCaja) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01041'; --EL CATÁLOGO DE SUCS, BÓVEDA Y ATM NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cInstitucion, cIdSucCaj, cNomSucCaj, cCalle, cNumero, cColonia, cCp,
			cLocalidad, cMunicipio, cEstado, cEntBilletes, dFechaAlta, cTipoCaja;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - SUC´S, BÓVEDA Y ATM',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de suc´s, bóveda y atm.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetallesucbovatm_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pId CHAR(8), pCveEdo CHAR(2), pCveMun CHAR(3))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cInstitucion CHAR(3);
	DEFINE cIdSucCaj CHAR(8);
	DEFINE cNomSucCaj CHAR(40);
	DEFINE cCalle CHAR(100);
	DEFINE cNumero CHAR(6);
	DEFINE cColonia CHAR(8);
	DEFINE cCp CHAR(5);
	DEFINE cLocalidad CHAR(14);
	DEFINE cMunicipio CHAR(3);
	DEFINE cEstado CHAR(2);
	DEFINE cEntBilletes CHAR(1);
	DEFINE dFechaAlta DATE;
	DEFINE cTipoCaja CHAR(1);
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cInstitucion = '';
	LET cIdSucCaj = '';
	LET cNomSucCaj = '';
	LET cCalle = '';
	LET cNumero = '';
	LET cColonia = '';
	LET cCp = '';
	LET cLocalidad = '';
	LET cMunicipio = '';
	LET cEstado = '';
	LET cEntBilletes = '';
	LET dFechaAlta = '';
	LET cTipoCaja = '';
	LET iRecuperacion = 0;
	LET iNumRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE bdisuc:"informix".sw_ope_statussucbovatm
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetallesucbovatm_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdisuc:"informix".sw_ope_statussucbovatm WHERE usuario = pUsuario;
		DELETE FROM bdisuc:"informix".sw_ope_detallesucbovatm WHERE usuario_insert = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdisuc:"informix".sw_ope_statussucbovatm(usuario,status,num_registros,error_proceso,error)
		VALUES(pUsuario,'I',0,'',cCodRet);  
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			UPDATE bdisuc:"informix".sw_ope_statussucbovatm
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdisuc:"informix".sw_ope_statussucbovatm
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdinteg:"informix".si_ptf AS a
		LEFT JOIN bdinteg:"informix".si_sucursales AS b ON a.id_ptf = b.sucursal
		LEFT JOIN bdisuc:"informix".ss_relacionccid AS c ON a.id_ptf = c.cc
		WHERE a.tipo IN ('S','A','B')
		AND CASE WHEN TRIM(a.tipo) = 'A' THEN NVL(c.id,'') ELSE NVL(a.id_ptf,'') END = (CASE WHEN TRIM(pId) = '' THEN CASE WHEN TRIM(a.tipo) = 'A' THEN NVL(c.id,'') ELSE NVL(a.id_ptf,'') END ELSE TRIM(pId) END) 
		AND a.cve_estado = (CASE WHEN TRIM(pCveEdo) = '' THEN a.cve_estado ELSE TRIM(pCveEdo) END) 
		AND a.cve_mun = (CASE WHEN TRIM(pCveMun) = '' THEN a.cve_mun ELSE TRIM(pCveMun) END);
		
		IF NVL(iNumRegistros,0) > 0 THEN
		
			INSERT INTO bdisuc:"informix".sw_ope_detallesucbovatm(usuario_insert,fecha_hora_insert,institucion,id_suc_caj,nom_suc_caja,
			calle,numero,colonia,cp,localidad,municipio,estado,ent_billetes,fecha_alta,tipo_caja)
			SELECT pUsuario, dFechaHora, b.empresa AS institucion,
			CASE WHEN a.tipo = 'A' THEN c.id ELSE a.id_ptf END AS idsucursalocajero,
			b.nombre, a.calle, a.num_ext AS numero, a.cve_col AS colonia, a.cp,
			a.cve_localidad, a.cve_mun AS municipio, a.cve_estado AS estado,
			a.dispensa_baja AS entregabilletesbajadenominacion,
			b.fecha_insert AS fechaalta, a.tipo AS tipocaja
			FROM bdinteg:"informix".si_ptf AS a
			LEFT JOIN bdinteg:"informix".si_sucursales AS b ON a.id_ptf = b.sucursal
			LEFT JOIN bdisuc:"informix".ss_relacionccid AS c ON a.id_ptf = c.cc
			WHERE a.tipo IN ('S','A','B')
			AND CASE WHEN TRIM(a.tipo) = 'A' THEN NVL(c.id,'') ELSE NVL(a.id_ptf,'') END = (CASE WHEN TRIM(pId) = '' THEN CASE WHEN TRIM(a.tipo) = 'A' THEN NVL(c.id,'') ELSE NVL(a.id_ptf,'') END ELSE TRIM(pId) END) 
			AND a.cve_estado = (CASE WHEN TRIM(pCveEdo) = '' THEN a.cve_estado ELSE TRIM(pCveEdo) END) 
			AND a.cve_mun = (CASE WHEN TRIM(pCveMun) = '' THEN a.cve_mun ELSE TRIM(pCveMun) END)
			ORDER BY b.nombre ASC;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
				UPDATE bdisuc:"informix".sw_ope_statussucbovatm
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, iNumRegistros;
			END IF;
		
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdisuc:"informix".sw_ope_detallesucbovatm 
			WHERE usuario_insert = pUsuario
			AND tipo_caja IN ('S','A','B')
			AND NVL(id_suc_caj,'') = (CASE WHEN TRIM(pId) = '' THEN NVL(id_suc_caj,'') ELSE TRIM(pId) END)
			AND NVL(estado,'') = (CASE WHEN TRIM(pCveEdo) = '' THEN NVL(estado,'') ELSE TRIM(pCveEdo) END) 
			AND NVL(municipio,'') = (CASE WHEN TRIM(pCveMun) = '' THEN NVL(municipio,'') ELSE TRIM(pCveMun) END); 	
		
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '01041'; --EL CATÁLOGO DE SUCS, BÓVEDA Y ATM NO CUENTA CON INFORMACIÓN
			UPDATE bdisuc:"informix".sw_ope_statussucbovatm
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		UPDATE bdisuc:"informix".sw_ope_statussucbovatm
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = pUsuario;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - SUC´S, BÓVEDA Y ATM',
'DESCRIPCION: SPL encargado de consultar el número total de registros que retornará el detalle del catálogo de suc´s, bóveda y atm.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consdetalletransportadora(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(6) AS clave,
		CHAR(13) AS rfc,
		CHAR(200) AS razonsocial,
		CHAR(60) AS nomcorto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(6);
	DEFINE cRfc CHAR(13);
	DEFINE cRazonSocial CHAR(200);
	DEFINE cNomCorto CHAR(60);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cRfc = '';
	LET cRazonSocial = '';
	LET cNomCorto = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdetalletransportadora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion TRIM(clave) AS clave, TRIM(rfc) AS rfc, TRIM(razonsocial) AS razonsocial, TRIM(nomcorto) AS nomcorto
			INTO cClave, cRfc, cRazonSocial, cNomCorto
			FROM bdisuc:"informix".ss_transp_val
			ORDER BY 3 ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, UPPER(cClave), UPPER(cRfc), UPPER(cRazonSocial), UPPER(cNomCorto) WITH RESUME;
		END FOREACH;
	
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01042'; --EL CATÁLOGO DE TRANSPORTADORA DE VALORES NO CUENTA CON INFORMACIÓN
			RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cRfc, cRazonSocial, cNomCorto;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 26/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - TRANSPORTADORA DE VALORES',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo de transportadora de valores.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_consfuncionalidadesmttocat(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consfuncionalidadesmttocat.out';
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
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			SELECT a.id_operacion, a.id_funcion, a.desc_funcion, b.id_submodulo
			INTO iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo
			FROM bdisuc:"informix".sw_ope_catalogoreportesoemn AS a
			INNER JOIN bdinteg:"informix".si_seg_funciones AS b ON a.id_funcion = b.id_funcion
			WHERE a.id_funcion IN (SELECT a.id_funcion
								   FROM bdinteg:"informix".si_seg_usuarios_funciones a, bdinteg:"informix".si_seg_funciones b
								   WHERE id_usuario = pUsuario
								   AND a.id_funcion[1, 3] =  'RMN'
								   AND a.status = '1'
								   AND b.id_funcion = a.id_funcion
								   AND b.id_submodulo = 38)
			ORDER BY a.id_operacion ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00749'; --EL USUARIO NO TIENE NINGÚN CATÁLOGO ASIGNADO
			RETURN cCodRet, iIdCatalogo, cIdFuncion, cDescFuncion, iIdSubmodulo;
		END IF;
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 22/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS',
'DESCRIPCION: SPL encargado de consultar las funcionalidades que llenan el contenedor de Mantenimiento Catálogos.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_verificastatussecciones(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(35) AS nombre_archivo,
		CHAR(6) AS error_spl,
		CHAR(250) AS descripcion_error_spl;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cNombre_archivo CHAR(35);
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_verificastatussecciones.out';
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
		FROM bdisuc:"informix".sw_ope_statusrepoemn 
		WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cNombre_archivo,cError_spl,cDescripcion_error_spl;
		END IF;	
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: GENERACIÓN DE REPORTES EN EFECTIVO EN MONEDA NACIONAL',
'DESCRIPCION: SPL encargado de verificar el status de la generación de los reportes correspondientes a las operaciones de moneda nacional.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_ope_verificastatussucbovatm(pUsuario CHAR(8), pIdFuncion CHAR(10))
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
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_verificastatussucbovatm.out';
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
		FROM bdisuc:"informix".sw_ope_statussucbovatm 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
/*DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 23/02/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO CATÁLOGOS - SUC´S, BÓVEDA Y ATM',
'DESCRIPCION: SPL encargado de verificar el status de la consulta para la recuperación de los registros correspondientes al catálogo de suc´s, bóveda y atm.',
'BD: bdisuc';*/;

CREATE PROCEDURE "informix".sp_consulta_cajagen_etv2( pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(4), CHAR(60);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vcod_proveedor CHAR(4);
DEFINE vdescripcion CHAR(60);

LET cod_ret = '00000';
LET vcod_proveedor = '';
LET vdescripcion = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;

        RETURN cod_ret,vcod_proveedor,vdescripcion;
    END EXCEPTION;

    set isolation to dirty read;

        --SET debug file to "/informix/1170/calizarraga/sp_consulta_cajagen_etv.out";
        --trace on;

        --SET DEBUG FILE TO "/tmp/mfinis/sp_consulta_cajagen_etv2.out";
        --TRACE ON;

    FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor,descripcion
        INTO vcod_proveedor, vdescripcion
        FROM bdisuc:"informix".ss_proveedores
        ORDER BY cod_proveedor

        RETURN cod_ret,vcod_proveedor,vdescripcion WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'DESCRIPCION: Se clona spl para sp_consulta_cajagen_etv agregar paginaciÃ³n.',
'AUTOR:Martha Salgado',
'FECHA: 06/08/2018',
'DESCRIPCION: Se agrega el orden por campo cod_proveedor',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_ccpanamericano_etv2(pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(4),CHAR (30);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vcentro_costos CHAR(4);
DEFINE vcaja_general CHAR (30);

LET cod_ret = '00000';
LET vcentro_costos = '';
LET vcaja_general = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,vcentro_costos,vcaja_general;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_consulta_ccpanamericano_etv2.out";
	--TRACE ON;

    FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion centro_costos,caja_general
        INTO vcentro_costos,vcaja_general
        FROM bdisuc:"informix".ss_sucursales_panamericano
        ORDER BY centro_costos

        RETURN cod_ret,vcentro_costos,vcaja_general WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'DESCRIPCION: Se clona spl sp_consulta_ccpanamericano_etv para agregar paginaciÃ³n.';

CREATE PROCEDURE "informix".sp_consulta_sucursal_atm_etv2(pRegistros INTEGER, pRecuperacion INTEGER)
							
RETURNING CHAR(6),CHAR(4);

DEFINE SQL_ERR   	  			INTEGER;
DEFINE ISAM_ERR   	 			INTEGER;
DEFINE vcodret 					CHAR(6);
DEFINE vcentro_costos        	CHAR(4);


LET vcodret='';
LET vcentro_costos = '';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR
      LET vcodret    = SQL_ERR;
      
      RETURN vcodret,vcentro_costos;
   END EXCEPTION;
 

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT sucursal 
	INTO vcentro_costos
	FROM bdisuc:"informix".ss_operaciones WHERE 
	cod_trans in ('0026','0002','0041')
	--and fecha_operacion = today
	ORDER BY sucursal

	RETURN vcodret,vcentro_costos WITH RESUME;
END FOREACH;
	
end;						
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL clon que consulta el centro de costos por Concentaciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_sucursal_atm_etv2_2(pRegistros INTEGER, pRecuperacion INTEGER)
							
RETURNING CHAR(6),CHAR(4);

DEFINE SQL_ERR   	  			INTEGER;
DEFINE ISAM_ERR   	 			INTEGER;
DEFINE vcodret 					CHAR(6);
DEFINE vcentro_costos        	CHAR(4);


LET vcodret='';
LET vcentro_costos = '';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR
      LET vcodret    = SQL_ERR;
      
      RETURN vcodret,vcentro_costos;
   END EXCEPTION;
 

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT sucursal 
	INTO vcentro_costos
	FROM bdisuc:"informix".ss_operaciones WHERE 
	cod_trans in ('0001','0010','0036')
	--and fecha_operacion = today
	ORDER BY sucursal

	RETURN vcodret,vcentro_costos WITH RESUME;
END FOREACH;
	
end;						
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP clon que consulta el centro de costos por Dotaciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tipo_operacion_etv()

RETURNING CHAR(5),CHAR(20);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vtipo_operacion CHAR(20);


LET cod_ret = '00000';
LET vtipo_operacion = '';


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,vtipo_operacion;
    END EXCEPTION;

    set isolation to dirty read;
	
	--SET debug file to "/informix/1170/calizarraga/sp_tipo_operacion_etv.out";
	--trace on;

    FOREACH
        SELECT tipo_operacion
        INTO vtipo_operacion
        FROM bdisuc:"informix".ss_cat_tipo_operacion_etv
        ORDER BY tipo_operacion

        RETURN cod_ret,vtipo_operacion WITH resume;
    END FOREACH;
END;

END PROCEDURE;