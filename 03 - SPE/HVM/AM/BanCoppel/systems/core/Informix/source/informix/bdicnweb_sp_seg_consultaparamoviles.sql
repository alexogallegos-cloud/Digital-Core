CREATE PROCEDURE "informix".sp_seg_consultaparamoviles(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipOperacion CHAR(1),pCodigo INTEGER, pDescripcion CHAR(480), pStatus CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
			RETURNING CHAR(5) AS codret,
            CHAR(5) AS codigo, 
	        CHAR(480) AS descripcion, 
            CHAR(10) AS status;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodigo INTEGER;
	DEFINE cDescripcion CHAR(480);
	DEFINE cStatus CHAR(10);
    DEFINE iNoRegistros INTEGER;
	DEFINE cDesc CHAR(480);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodigo = 0;
	LET cDescripcion = '';
	LET cStatus = '';
	LET iNoRegistros = 0;
	LET cDesc = '';	

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCodigo, cDescripcion, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_seg_consultaparamoviles.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipOperacion = ''  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCodigo, cDescripcion, cStatus;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iCodigo, cDescripcion, cStatus;
		END IF;
		
		IF pTipOperacion NOT IN(0,1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iCodigo, cDescripcion, cStatus;
		END IF;		
				
		IF pTipOperacion IN (1, 2) THEN
			IF pCodigo IS NULL OR pDescripcion = '' OR pStatus = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			END IF;
		END IF;			
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iCodigo, cDescripcion, cStatus;
		END IF;	
		
		--REALIZA CONSULTA
		IF pTipOperacion = 0 THEN
			FOREACH 
				SELECT SKIP pRegistros FIRST pRecuperacion cod_param, Descripcion, valor
					INTO iCodigo, cDescripcion, cStatus
				FROM bdinteg:si_param_movil
				
				LET iNoRegistros = iNoRegistros + 1;
		
				RETURN cCodRet, iCodigo, cDescripcion, cStatus WITH RESUME;				
			END FOREACH;
			
			
			IF iNoRegistros = 0 THEN
				IF pRegistros = 0 THEN 
					LET cCodRet = '00017';
				ELIF pRegistros > 0 THEN 
					LET cCodRet = '1001';
				END IF;
				
				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			END IF;
			
		END IF;
		
		--REALIZA ALTA
		IF pTipOperacion = 1 THEN	
			SELECT COUNT(*) 
				INTO iNoRegistros 
			 FROM bdinteg:si_param_movil 
				WHERE cod_param = pCodigo;
			
			IF iNoRegistros > 0 THEN
					LET cCodRet = '00004';				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
            END IF;			
			
			IF  (SELECT COUNT(*) FROM bdinteg:si_param_movil WHERE UPPER(TRIM(descripcion)) = UPPER(TRIM(pDescripcion))) = 0 THEN
				INSERT INTO bdinteg:si_param_movil VALUES ('001', pCodigo, pDescripcion, pStatus,pUsuario,CURRENT);
				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			ELSE 
				LET cCodRet = '00520';				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			END IF;
		END IF;
		
		--REALIZA MODIFICACION
		IF pTipOperacion = 2 THEN
			 SELECT COUNT(*) 
				INTO iNoRegistros 
			 FROM bdinteg:si_param_movil 
				WHERE cod_param = pCodigo;
			
			IF iNoRegistros = 0 THEN
					LET cCodRet = '00001';				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
            END IF;		
			
			IF (SELECT COUNT(*) FROM bdinteg:si_param_movil WHERE cod_param <> pCodigo AND UPPER(TRIM(descripcion)) = UPPER(TRIM(pDescripcion))) > 0 THEN
				LET cCodRet = '00520';				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			END IF
			
			IF (SELECT COUNT(*) FROM bdinteg:si_param_movil WHERE cod_param = pCodigo AND UPPER(TRIM(descripcion)) = UPPER(TRIM(pDescripcion)) AND valor <> pStatus) = 1  THEN
				UPDATE bdinteg:si_param_movil SET  valor = pStatus, descripcion= pDescripcion
											WHERE cod_param = pCodigo;				
				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			ELIF (SELECT COUNT(*) FROM bdinteg:si_param_movil WHERE cod_param = pCodigo AND (TRIM(descripcion)) <> (TRIM(pDescripcion))) = 1 THEN
				UPDATE bdinteg:si_param_movil SET descripcion = pDescripcion, 
												  valor = pStatus
											WHERE cod_param = pCodigo;
			     RETURN cCodRet, iCodigo, cDescripcion, cStatus;			
			ELSE 			
				RETURN cCodRet, iCodigo, cDescripcion, cStatus;
			END IF;
						
		END IF;			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Miguel Huitzil Cuachayo',
'FECHA: 27/11/2015',
'MODULO: SEGURIDAD',
'FUNCIONALIDAD: MANTENIMIENTO DE PARAMETROS MOVIL',
'DESCRIPCION: SPL que realiza consulta,alta y modificacion de la siguiente tabla bdinteg:si_param_movil.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 11/01/2016',
'DESCRIPCION: Se realizo la modificacion quitando una comparacion de mayusculas para que realice la actualizacion de descripciones.',
'BD: bdicnweb','AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 18/02/2016',
'DESCRIPCION: Se realizo la modificacion en la actualizacion de descripciones al cambio de statua a valor.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_seg_consultaparamoviles_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipOperacion CHAR(1), pCodigo INTEGER, pDescripcion CHAR(480), pStatus CHAR(10))
			  RETURNING CHAR(5) AS codret,
              INTEGER AS total_Registros, 
	          INTEGER AS ultimo_Codigo;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalRegistros INTEGER;
	DEFINE iUltimoCodigo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotalRegistros = "";
	LET iUltimoCodigo = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros, iUltimoCodigo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_seg_consultaparamoviles_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros, iUltimoCodigo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros, iUltimoCodigo;
		END IF;		
		
		SELECT COUNT(*), MAX(cod_param) 
			INTO iTotalRegistros, iUltimoCodigo
		FROM bdinteg:'informix'.si_param_movil;  
		
		LET iUltimoCodigo = iUltimoCodigo + 1;	 
        RETURN cCodRet, iTotalRegistros, iUltimoCodigo;		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Miguel Huitzil Cuachayo',
'FECHA: 27/11/2015',
'MODULO: SEGURIDAD',
'FUNCIONALIDAD: MANTENIMIENTO DE PARAMETROS MOVIL',
'DESCRIPCION: SPL que consulta los totales de tabla bdinteg:si_param_movil.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscaxctectatar(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pTipoConsulta int, 
	pCriterio char(20), pRecuperacion int, pIp char(15), pMac char(12))
	returning char(5)  as codret,
			  char(20) as numerocliente,
			  char(13) as rfc,
			  char(1)  as nivelcliente,
			  char(26) as nombre1,
			  char(26) as nombre2,
			  char(26) as ap_paterno,
			  char(26) as ap_materno,
			  char(60) as razon_social,
			  char(2)  as tipo_persona,
			  char(1)  as tipo_cliente,
			  int      as status_busqueda,
			  char(20) as desc_status_busqueda,
			  int      as id_encontrado
	
	define cCodRet char(5);
	define iSqlErr int;
	define cNumCte char(20);
	define cNumCta char(20);
	define cNumTar char(20);
	
	-- Variables de retorno
	define cNumeroCliente char(20);
	define cRfc char(13);
	define cNivelCliente char(1);
	define cNombre1 char(26);
	define cNombre2 char(26);
	define cApPaterno char(26);
	define cApMaterno char(26);
	define cRazonSocial char(60);
	define iNoRegistros int;
	define cEtiqueta char(20);
	define iStatusBusqueda smallint;
	define cTipoPersona char(2);
	define cTipoCliente char(1);
	define cCodRetSp char(5);
	define iRegsProc int;
	define iIdGenerado int;
	
	define cDescTipoCliente char(40);
	define dFechaNacimiento date;
	define cSexo char(1);
	define cDescTipoPersona char(20);
	define dFechaAlta date;
	define cCveSucursalAltaCte char(4);
	define cPlazaAlta char(3);
	define cCveSitEspecial char(5);
	define cDescSitEspecial char(75);
	define iSecuencia int;
	define cCalle char(40);
	define cNoExt char(10);
	define cNoInt char(10);
	define cDepto char(6);
	define cColonia char(60);
	define cDelMun char(60);
	define cCiudad char(60);
	define cEstado char(30);
	define cPais char(20);
	define cCodPostal char(5);
	define cTelParticular char(13);
	define cTelCelular char(13);
	define cTelOficina char(13);
	define cExt char(5);
	define iNivelCliente int;
	define cDescNivelCliente char(60);
	define cTipoCuenta char(2);
	define cTipoBusquedaPersona char(1);
	
	
	let cCodRet = '00000';
	let cCodRetSp = '';
	let cNumeroCliente = '';
	let cRfc = '';
	let cNivelCliente = '';
	let cNombre1 = '';
	let cNombre2 = '';
	let cApPaterno = '';
	let cApMaterno = '';
	let cRazonSocial = '';
	let iNoRegistros = 0;
	let cEtiqueta = 'NO LOCALIZADO';
	let iStatusBusqueda = 0; -- 0. No encontrado, 1. Encontrado, 2. Homonimo
	let cTipoPersona = '';
	let cTipoCliente = '';
	let cCodRetSp = '';
	let iRegsProc = 0;
	let iIdGenerado = 0;
	let cNumCte = '';
	let cNumCta = '';
	let cNumTar = '';
	
	let cDescTipoCliente = '';
	let dFechaNacimiento = null;
	let cSexo = '';
	let cDescTipoPersona = '';
	let dFechaAlta = null;
	let cCveSucursalAltaCte = '';
	let cPlazaAlta = '';
	let cCveSitEspecial = '';
	let cDescSitEspecial = '';
	let iSecuencia = 0;
	let cCalle = '';
	let cNoExt = '';
	let cNoInt = '';
	let cDepto = '';
	let cColonia = '';
	let cDelMun = '';
	let cCiudad = '';
	let cEstado = '';
	let cPais = '';
	let cCodPostal = '';
	let cTelParticular = '';
	let cTelCelular = '';
	let cTelOficina = '';
	let cExt = '';
	let iNivelCliente = 0;
	let cDescNivelCliente = '';
	let cTipoCuenta = '';
	
	
	begin
		
		if pTipoConsulta = 1 then
			let cNumCte = pCriterio;
		elif pTipoConsulta = 2 then
			let cNumCta = pCriterio;
		elif pTipoConsulta = 3 then
			let cNumTar = pCriterio;
		end if;
		
		foreach
			execute procedure bdinteg:sp_cnsif_consnumcte(pUsuario, pIdFuncion, pTipoConsulta, '1', '0', cNumCte, cNumCta, cNumTar, '')
			into cCodRetSp, cNumeroCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cRfc, cTipoCliente, cDescTipoCliente, dFechaNacimiento,
				cSexo, cTipoPersona, cDescTipoPersona, dFechaAlta, cCveSucursalAltaCte, cPlazaAlta, cCveSitEspecial, cDescSitEspecial, iSecuencia, 
				cCalle, cNoExt, cNoInt, cDepto, cColonia, cDelMun, cCiudad, cEstado, cPais, cCodPostal, cTelParticular, cTelCelular, cTelOficina, 
				cExt, iNivelCliente, cDescNivelCliente
				
			if cCodRetSp = '00000' then  -- Se encontro al cliente
				let iStatusBusqueda = 1;
				let cNivelCliente = iNivelCliente;
				let cEtiqueta = 'LOCALIZADO';
				
				if pTipoConsulta = 2 then
					foreach execute procedure sp_sw_ro_buscacte_ctatar(1, cNumCta)
						into cCodRetSp, cTipoBusquedaPersona, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cTipoCuenta
					end foreach;
				end if;
				
				if pTipoConsulta = 3 then
					foreach execute procedure sp_sw_ro_buscacte_ctatar(2, cNumTar)
						into cCodRetSp, cTipoBusquedaPersona, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cTipoCuenta
					end foreach;
				end if;
				
				-- Se almacena la busqueda
				execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
							cApPaterno, cApMaterno, cNombre1, cNombre2, 
							cRazonSocial, cRfc, 
							cNumeroCliente, cNumCta, cNumTar, cTipoCuenta,
							cTipoCliente, iStatusBusqueda, pIp, pMac)
				into cCodRetSp, iIdGenerado;
				
				if cCodRetSp <> '00000' then
					return cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
				end if;
				
				
				-- Se almacena al cliente encontrado
				execute procedure sp_sw_ro_bitacoracteenc(pUsuario, pIdBusqueda, pIdOficio, iIdGenerado, cNumeroCliente, 
									cApPaterno, cApMaterno, cNombre1, cNombre2, 
									cRazonSocial, cRfc, pIp, pMac)
				into cCodRetSp, iRegsProc;
				
				if cCodRetSp <> '00000' then
					return cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
				end if;
				
				-- Se buscan las cuentas y participaciones del cliente
				if cTipoCliente = '1' then
					execute procedure sp_sw_ro_consctascteparticipacion(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, iRegsProc, cNumeroCliente, 
								pRecuperacion, pIp, pMac) into cCodRetSp;
					if cCodRetSp <> '00000' then
						return cCodRetSp, 'En 1 part', cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc;
					end if;
				elif cTipoCliente = '2' then
					execute procedure sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, iRegsProc, cNumeroCliente, pIp, pMac) into cCodRetSp;
					if cCodRetSp <> '00000' then
						return cCodRetSp, 'en 2 part', cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc;
					end if;
				end if;
				
				return cCodRet, cNumeroCliente, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc with resume;
			else
				if cCodRetSp <> '00000' then
					return cCodRetSp, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
				end if;
				execute procedure sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, 
								cApPaterno, cApMaterno, cNombre1, cNombre2, 
								cRazonSocial, cRfc, 
								cNumCte, cNumCta, cNumTar, cTipoCuenta,
								cTipoCliente, iStatusBusqueda, pIp, pMac)
				into cCodRetSp, iRegsProc;
				
				if cCodRetSp <> '00000' then
					return cCodRetSp, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, 0;
				end if;
				
				let cCodRet = '00000';
				let cNivelCliente = '9';
				return cCodRet, cNumCte, cRfc, cNivelCliente, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, cEtiqueta, iRegsProc;
			end if;
		end foreach;
	
	end;
end procedure;