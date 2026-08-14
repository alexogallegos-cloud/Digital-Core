CREATE PROCEDURE "informix".sp_sw_ro_conscodbloqcap(pIdUsuario char(8), pIdFuncion char(10), pOpcion char(1))
	returning char(5) as codRet,
		char(2) as codigo_bloqueo,
		char(35) as descripcion;
	
	define cCodRet char(5);
	define cCodBloq char(2);
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodBloq = '';
	let cDescripcion = '';
	let iSqlErr = 0;
	
	begin
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cCodBloq, cDescripcion;
			end if;
		end exception;
		
		if pIdUsuario = '' or
			pIdFuncion = '' or
			pOpcion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		if pOpcion not in ('0', '1') then
			let cCodRet = '00044';
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		if pOpcion = '0' then
			set isolation to dirty read;
			foreach select codigo, descripcion 
				into cCodBloq, cDescripcion
				from bdicheq:sc_bloqueo order by 1
				
				return cCodRet, cCodBloq, cDescripcion with resume;
				
			end foreach;
		elif pOpcion = '1' then
			set isolation to dirty read;
			foreach select codigo, descripcion 
				into cCodBloq, cDescripcion
				from bdicheq:sc_bloqueo
				where codigo <> '00'
				order by 1 asc
				
				return cCodRet, cCodBloq, cDescripcion with resume;
				
			end foreach;
		end if;
		
	end;
end procedure;