create procedure "informix".sp_sw_ro_consopcbloqcap(pIdUsuario char(8), pIdFuncion char(10), pOpcion char(1))
	returning char(5) as codRet,
		int as codigo_opcion,
		char(35) as descripcion
	
	define cCodRet char(5);
	define cCodOpc int;
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodOpc = 0;
	let cDescripcion = '';
	let iSqlErr = 0;
	
	begin
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cCodOpc, cDescripcion;
			end if;
		end exception;
		
		if pIdUsuario = '' or
			pIdFuncion = '' or
			pOpcion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodOpc, cDescripcion;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, cCodOpc, cDescripcion;
		end if;
		
		if pOpcion not in ('0', '1') then
			let cCodRet = '00044';
			return cCodRet, cCodOpc, cDescripcion;
		end if;
		
		if pOpcion = '0' then
			set isolation to dirty read;
			foreach select opcion, descripcion 
				into cCodOpc, cDescripcion
				from bdicheq:sc_opcionbloqueo order by 1
				
				return cCodRet, cCodOpc, cDescripcion with resume;
				
			end foreach;
		elif pOpcion = '1' then
			set isolation to dirty read;
			foreach select opcion, descripcion 
				into cCodOpc, cDescripcion
				from bdicheq:sc_opcionbloqueo
				where opcion <> '0'
				order by 1
				
				return cCodRet, cCodOpc, cDescripcion with resume;
				
			end foreach;
		end if;
		
	end;
end procedure;