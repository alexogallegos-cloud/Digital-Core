CREATE PROCEDURE "informix".sp_sw_ro_consdatoscteoficio(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pRecuperacion int, pRegistros int)
	returning char(5) as codret,
		smallint as id_tipobusqueda,
		int as id_busqueda,
		int as id_resulcte,
		char(20) as numcte,
		char(164) as nombre,
		char(20) as cuenta,
		char(20) as num_tarjeta,
		char(1) as ind_rfc,
		char(1) as ind_domicilio, 
		char(1) as ind_nacionalidad,
		char(1) as ind_empleo,
		char(1) as ind_expdig,
		char(13) as rfc,
		char(255) as domicilio,
		char(15) as nacionalidad,
		char(255) as domicilio_empleo,
		char(15) as telefono_oficina;
		
	define iSqlErr int;
	define cCodRet char(5);
	define cNumCte char(20);
	define cNombre char(164);
	define cNumCta char(20);
	define cNumTarjeta char(20);
	define cRfc char(13);
	define cIndEmpleo char(1);
	define cIndDomicilio char(1);
	define cIndNacionalidad char(1);
	define cIndRfc char(1);
	define cIndExpDig char(1);
	define cDirEmpleo char(255);
	define cDirActual char(255);
	define cNacionalidad char(15);
	define cTelOficina char(15);
	define iNoRows int;
	define iIdTipoBusqueda smallint;
	define iIdBusqueda int;
	define iIdCliente int;
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	let cNumCte = '';
	let cNombre = '';
	let cNumCta = '';
	let cNumTarjeta = '';
	let cRfc = '';
	let cIndEmpleo = '';
	let cIndDomicilio = '';
	let cIndNacionalidad = '';
	let cIndRfc = '';
	let cIndExpDig = '';
	let cDirEmpleo = '';
	let cDirActual = '';
	let cNacionalidad = '';
	let cTelOficina = '';
	let iNoRows = 0;
	let iIdTipoBusqueda = 0;
	let iIdBusqueda = 0;
	let iIdCliente = 0;
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
			end if;
		end exception;
		
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pRecuperacion = '' or pRegistros = '' then
			let cCodRet = '00003';
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
		end if;
		
		if pRecuperacion < 0 then
			let cCodRet = '00098';
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
		end if;
		
		if pRegistros <= 0 then
			let cCodRet = '00098';
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
		end if;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute procedure bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
		end if;
	
		SET ISOLATION TO DIRTY READ;		
		foreach
				select skip pRecuperacion first pRegistros b.id_tipobusqueda, b.id_busqueda, a.numcte, trim(trim(trim(a.nombre1)||' '||trim(a.nombre2))||' '||trim(trim(a.apell_paterno)||' '||trim(a.apell_materno))||' '||trim(a.razon_social)) as nombre_razonsocial
					, case when b.id_tipobusqueda = 5 then a.cuenta else '' end as cuenta
					, case when b.id_tipobusqueda = 6 then a.num_tarjeta else '' end as num_tarjeta
					, c.ind_rfc
					, c.ind_empleo
					, c.ind_domicilio
					, c.ind_nacionalidad 
					, c.ind_expdig
					, trim(nvl(c.rfc, '')) as rfc
					, c.id_resulcte
				into iIdTipoBusqueda, iIdBusqueda, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad, cIndExpDig, cRfc, iIdCliente
				from ((sw_ro_resulper a left join sw_ro_buscaper b on (b.id_busqueda = a.id_busqueda))
						left join sw_ro_resulcte c on c.id_resulper = a.id_resulper)
				where a.id_oficio = pIdOficio
					and a.status = '1' 
					and a.status_busqueda = '1'
					and a.ind_omitir = '0'
				order by b.id_tipobusqueda			
			
			if cIndDomicilio = '1' then
				-- Domicilio particular del cliente
				execute procedure sp_sw_ro_consdireccion(pUsuario, pIdFuncion, cNumCte, '1') into cDirActual, cTelOficina;
			end if;
			
			if cIndNacionalidad = '1' then
				-- Obtención de la nacionalidad del cliente
				SELECT NVL(NA.descripcion, '') 
				INTO cNacionalidad
				FROM bdinteg:si_ctepf CF
				LEFT JOIN bdinteg:si_nacion NA ON NA.nacion = CF.nacionalidad
				WHERE CF.numcte = cNumCte;
			end if;
			
			if cIndEmpleo = '1' then
				-- Domicilio del empleo
				execute procedure sp_sw_ro_consdireccion(pUsuario, pIdFuncion, cNumCte, '2') into cDirEmpleo, cTelOficina;
			end if;
				
			let iNoRows = iNoRows + 1;
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina with resume;
			
		end foreach;
		
		if iNoRows = 0 then
			let cCodRet = '01001';
			return cCodRet, iIdTipoBusqueda, iIdBusqueda, iIdCliente, cNumCte, cNombre, cNumCta, cNumTarjeta, cIndRfc, cIndDomicilio, cIndNacionalidad, cIndEmpleo, cIndExpDig, cRfc, cDirActual, cNacionalidad, cDirEmpleo, cTelOficina;
		end if;		
	end;
end procedure;