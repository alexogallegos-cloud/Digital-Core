create procedure "informix".sp_sw_consenclace1n(pUsuarioC char(8), pIdFuncion char(10), pTipoBusqueda int)
	returning char(5) as CodRet,
			  int as idInstitucion,
			  char(50) as DescNombreCorto,
			  char(100) as DescNombreLargo,
			  char(255) as DireccionOficio,
			  char(1) as status
			  
			
	define  cCodRet char(5);	
	define iIdInstitucion int;
	define cDescNombreCorto char(50);
	define cDescNombreLargo char(100);
	define cDirectorioOficio char(255);
	define cStatus char(1);
	define iSqlErr int;
	define iNoRows int;
	
	let cCodRet='00000';
	let iIdInstitucion=0;
	let cDescNombreCorto='';
	let cDescNombreLargo='';
	let cDirectorioOficio='';
	let cStatus='';
	let iSqlErr=0;
	
	begin

		on exception set iSqlErr
				if iSqlErr <> 0 then
					let cCodRet = iSqlErr;
					return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
				end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
		end if;
		
		-- Validaciones de entrada
		if pUsuarioC = '' or
			pIdFuncion = '' or
            pTipoBusqueda is null then
			
			let cCodRet = '00003';
			return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
		end if;
		
		if pTipoBusqueda not in (0,1) then
			let cCodRet = '00087';
			return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
		end if;
		
		set isolation to dirty read;
		set lock mode to wait 3;
		if pTipoBusqueda = 0 then -- Se buscan todos los registros
			select count(*)
			into iNoRows
			from sw_ro_insenlace1nivel; 
			
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
			end if;
			
			
			foreach 
				select id_institucion1n, desc_i1n_nombrecorto, desc_i1n_nombrelargo, direccion_oficio, status
				into iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus
				from sw_ro_insenlace1nivel
				order by id_institucion1n
				
				return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus with resume;
			end foreach;
		elif pTipoBusqueda = 1 then
			select count(*)
			into iNoRows
			from sw_ro_insenlace1nivel
			where status = '1'; 
			
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus;
			end if;
			
			
			foreach 
				select id_institucion1n, desc_i1n_nombrecorto, desc_i1n_nombrelargo, direccion_oficio, status
				into iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus
				from sw_ro_insenlace1nivel
				where status = '1'
				order by id_institucion1n
				
				return cCodRet, iIdInstitucion, cDescNombreCorto, cDescNombreLargo, cDirectorioOficio, cStatus with resume;
			end foreach;
		end if;
	end
end procedure;