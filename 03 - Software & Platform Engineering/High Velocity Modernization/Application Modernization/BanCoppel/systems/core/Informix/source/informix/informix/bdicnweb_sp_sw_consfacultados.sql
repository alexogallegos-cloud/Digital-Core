create procedure "informix".sp_sw_consfacultados(pUsuarioC char(8), pIdFuncion char(10), pTipoBusqueda int)
	returning char(5) as CodRet,
			  int as idFacultado,
			  char(50) as rolFuncion,
			  char(50) as nombreCorto,
			  char(80) as nombreFacultado,
			  char(50) as puestoFacultado,
			  char(1) as status,
			  smallint as id_rolfuncion
			  
	define cCodRet char(5);	
	define iIdFacultado int;
	define cRolFuncion char(50);
	define cNombreCorto char(50);
	define cNombreFacultado char(80);
	define cPuestoFacultado char(50);
	define cStatus char(1);
	define iSqlErr int;
	define iNoRows int;
	define iIdRolFuncion smallint;
	
	let iIdFacultado = 0;
	let cRolFuncion = '';
	let cNombreCorto = '';
	let cNombreFacultado = '';
	let cPuestoFacultado = '';
	let cStatus = '';
	let iSqlErr = 0;
	let cCodRet = '00000';
	let iIdRolFuncion = 0;
	
	begin

		on exception set iSqlErr
				if iSqlErr <> 0 then
					let cCodRet = iSqlErr;
					return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
				end if;
		end exception;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
		end if;
		
		-- Validaciones de entrada
		if pUsuarioC = '' or
			pIdFuncion = '' or
			pTipoBusqueda is null then
			
			let cCodRet = '00003';
			return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
		end if;
		
		if pTipoBusqueda not in (0,1) then
			let cCodRet = '00087';
			return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
		end if;
		
		set isolation to dirty read;
		if pTipoBusqueda = 0 then
		
			select count(*)
			into iNoRows
			from (sw_ro_facultados a left join sw_ro_roles_funciones b on (b.id_rolfuncion = a.id_rolfuncion))
				left join sw_ro_insenlace1nivel c on c.id_institucion1n = a.id_institucion1n;
				
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
			end if;

			foreach 
				select a.id_facultado, nvl(b.desc_rolfuncion, ''), nvl(c.desc_i1n_nombrecorto, ''), a.nombre_facultado,
					a.puesto_facultado, a.status, nvl(b.id_rolfuncion, 0)
				into iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion	
				from (sw_ro_facultados a left join sw_ro_roles_funciones b on (b.id_rolfuncion = a.id_rolfuncion))
					left join sw_ro_insenlace1nivel c on c.id_institucion1n = a.id_institucion1n

				return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion with resume;
			end foreach;
		elif pTipoBusqueda = 1 then
			select count(*)
			into iNoRows
			from (sw_ro_facultados a left join sw_ro_roles_funciones b on (b.id_rolfuncion = a.id_rolfuncion and a.status = '1'))
				left join sw_ro_insenlace1nivel c on c.id_institucion1n = a.id_institucion1n;
				
			if iNoRows = 0 then
				let cCodRet = '00017';
				return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion;
			end if;

			foreach 
				select a.id_facultado, nvl(b.desc_rolfuncion, ''), nvl(c.desc_i1n_nombrecorto, ''), a.nombre_facultado,
					a.puesto_facultado, a.status, nvl(b.id_rolfuncion, 0)
				into iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion	
				from (sw_ro_facultados a left join sw_ro_roles_funciones b on (b.id_rolfuncion = a.id_rolfuncion))
					left join sw_ro_insenlace1nivel c on c.id_institucion1n = a.id_institucion1n
				where a.status = '1'

				return cCodRet, iIdFacultado, cRolFuncion, cNombreCorto, cNombreFacultado, cPuestoFacultado, cStatus, iIdRolFuncion with resume;
			end foreach;
		end if;
		
	end;
end procedure;