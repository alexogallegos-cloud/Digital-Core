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