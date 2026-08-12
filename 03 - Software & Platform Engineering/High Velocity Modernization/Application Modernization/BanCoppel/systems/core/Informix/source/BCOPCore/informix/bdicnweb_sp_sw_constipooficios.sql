create procedure "informix".sp_sw_constipooficios(pUsuarioC char(8), pIdFuncion char(10), iTipoBusqueda int)
	returning char(5) as CodRet,
			int as idTipoOficio,
			char(100) as DescTipoOficio,
			char(1) as status

	define cCodRet char(5);
	define iIdTipoOficio int;
	define cDescOficio char(100);
	define cStatus char(1);
	define iSqlErr int;
	define iNoRows int;
	
	let cCodRet = '00000';
	let iIdTipoOficio = 0;
	let cDescOficio = '';
	let cStatus = '';
	let iSqlErr = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
		end if;
		
		-- Validaciones de entrada
		if pUsuarioC = '' or
			pIdFuncion = '' or 
			iTipoBusqueda is null then
			
			let cCodRet = '00003';
			return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
		end if;
		
		-- Validaciones del tipo de operacion
		if iTipoBusqueda not in (0,1) then
			let cCodRet = '00087';
			return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
		end if;
		
		set isolation to dirty read;
		set lock mode to wait 3;
		if iTipoBusqueda = 0 then -- Se buscan todos los registros
		
			-- Contamos el numero de registros
			select count(*)
			into iNoRows
			from sw_ro_tipooficios;
			
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
			end if;
		
			foreach
				select id_tipooficio, desc_tipooficio, status 
				into iIdTipoOficio, cDescOficio, cStatus
				from sw_ro_tipooficios
				order by id_tipooficio
				
				return cCodRet, iIdTipoOficio, cDescOficio, cStatus with resume;
			end foreach;
		elif iTipoBusqueda = 1 then
			-- Contamos el numero de registros con estatus de activo
			select count(*)
			into iNoRows
			from sw_ro_tipooficios
			where status = '1';
			
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdTipoOficio, cDescOficio, cStatus;
			end if;
			
			foreach
				select id_tipooficio, desc_tipooficio, status 
				into iIdTipoOficio, cDescOficio, cStatus
				from sw_ro_tipooficios
				where status = '1'
				order by id_tipooficio
				
				return cCodRet, iIdTipoOficio, cDescOficio, cStatus with resume;
			end foreach;
		end if;
		
	end;
end procedure;