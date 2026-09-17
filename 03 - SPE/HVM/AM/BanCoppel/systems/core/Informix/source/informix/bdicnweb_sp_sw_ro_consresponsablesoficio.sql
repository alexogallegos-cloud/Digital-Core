create procedure "informix".sp_sw_ro_consresponsablesoficio(pUsuario char(8), pIdFuncion char(10), pIdOficio int)
	returning char(5) as codret,
		int as id_facultado,
		char(70) as nombre_facultado,
		char(40) as puesto_facultado
		
	define cCodRet char(5);
	define iSqlErr int;
	define iIdFacultado int;
	define cNombreFacultado char(70);
	define cPuestoFacultado char(40);
	define iNoRegistros int;
	
	let cCodRet = '';
	let iSqlErr = 0;
	let iIdFacultado = 0;
	let cNombreFacultado = '';
	let cPuestoFacultado = '';
	let iNoRegistros = 0;
	
	begin
		
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iIdFacultado, cNombreFacultado, cPuestoFacultado;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' then
			let cCodRet = '00003';
			return cCodRet, iIdFacultado, cNombreFacultado, cPuestoFacultado;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		
		if cCodRet <> '00000' then
			return cCodRet, iIdFacultado, cNombreFacultado, cPuestoFacultado;
		end if;
		
		
		foreach
			select a.id_rolfuncion, nvl(b.nombre_facultado,'SIN NOMBRE'), nvl(b.puesto_facultado, '')
			into iIdFacultado, cNombreFacultado, cPuestoFacultado
			from sw_ro_oficio_facultados a left join sw_ro_facultados b on b.id_facultado = a.id_facultado
			where a.id_oficio = pIdOficio
				and a.id_rolfuncion <> 1
				and a.status = '1'
			order by a.id_facultado, a.id_secuencia
			
			let iNoRegistros = iNoRegistros + 1;
			return cCodRet, iIdFacultado, cNombreFacultado, cPuestoFacultado with resume;
			
		end foreach;
		
		if iNoRegistros = 0 then
			let cCodRet = '00017';
			return cCodRet, iIdFacultado, cNombreFacultado, cPuestoFacultado;
		end if;
		
	end;
	
end procedure;