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