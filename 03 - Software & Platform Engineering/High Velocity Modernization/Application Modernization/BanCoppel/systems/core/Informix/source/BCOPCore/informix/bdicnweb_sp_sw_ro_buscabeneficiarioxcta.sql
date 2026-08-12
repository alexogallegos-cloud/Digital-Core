create procedure "informix".sp_sw_ro_buscabeneficiarioxcta(pUsuario char(8), pIdFuncion char(10), pTipoCuenta char(2), pCuenta char(20))
	returning char(5) as cod_ret,
		char(20) as cuenta,
		char(20) as numcte,
		char(2) as tipo_persona,
		char(26) as nombre1,
		char(26) as nombre2,
		char(26) as apell_paterno,
		char(26) as apell_materno,
		char(60) as razon_social
		
	define cCodRet char(5);
	define cNumCte char(20);
	define cTipoPersona char(2);
	define cNombre1 char(26);
	define cNombre2 char(26);
	define cApellidoPaterno char(26);
	define cApellidoMaterno char(26);
	define cRazonSocial char(60);
	define iRegistros int;
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cNumCte = '';
	let cTipoPersona = '';
	let cNombre1 = '';
	let cNombre2 = '';
	let cApellidoPaterno = '';
	let cApellidoMaterno = '';
	let cRazonSocial = '';
	let iRegistros = 0;
	let iSqlErr = 0;
	
	begin
		
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial;
			end if;
		end exception;
		
		-- Validación de variables
		if pUsuario = '' or pIdFuncion = '' or pTipoCuenta = '' or pCuenta = '' then
			let cCodRet = '00003';
			return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial;
		end if;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial;
		end if;
		
		if pTipoCuenta = '03' then
			foreach select a.numcte, b.tpo_persona, b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.razon_social
					into cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial
					from bdinvers:sv_benefic a left join bdinteg:si_cliente b on b.numcte = a.numcte
					where a.cuenta = pCuenta
				
				let iRegistros = iRegistros + 1;
				return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial with resume;
					
			end foreach;
			
			if iRegistros = 0 then
				let cCodRet = '1001';
				return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial;
			end if;
		else
			let cCodRet = '00037';
			return cCodRet, pCuenta, cNumCte, cTipoPersona, cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cRazonSocial;
		end if;
	end;	
end procedure;