create procedure "informix".sp_sw_ro_consstatusbloqueo(pUsuario char(8), pIdFuncion char(10), pTipoCuenta char(2), pNumCuenta char(20))
	returning char(1) as status_bloqueo,
			char(40) as motivo_bloqueo,
			date as fecha_bloqueo
	
	define cStatusBloqueo char(1);
	define cMotivoBloqueo char(40);
	define cFechaBloqueo char(10);
	-- Variables de la ejecución del SP de bloqueo de cuentas de credito
	define cCodErrCred char(6);
    define cMensErrCred char(80);
	define cEmpresaCred char(3);
	define cNumCuentaCred char(20);
    define cNumCteCred char(20);
	define cNombreCteCred char(50);
	define cSucursalCred char(4);
	define cBloqueoCred char(30);
	define cCausaCred char(50);
	define cStatusCred char(2);
	define dFechaBloqCred date;
	
	-- Variables de la ejecución del SP de bloqueo de cuentas de captacion
	define cCodRetCap char(5);
	define cMovimientoCap char(2);
	define cStatusCap char(2);
	define cImporteBloqCap money(14,2);
	define cFechaBloqCap date;
	define cNumClienteCap char(15);
	define cClaveAreaCap char(2);
	define cCodigoAreaCap char(1);
	define cCodTipoBloqCap char(1);
	define cClaveTipoBloqCap char(2);
	
	let cStatusBloqueo = '0';
	let cMotivoBloqueo = '';
	let cFechaBloqueo = '';
	-- Variables de la ejecución del SP de bloqueo de cuentas de credito
	let cCodErrCred = '';
    let cMensErrCred = '';
	let cEmpresaCred = '';
	let cNumCuentaCred = '';
    let cNumCteCred = '';
	let cNombreCteCred = '';
	let cSucursalCred = '';
	let cBloqueoCred = '';
	let cCausaCred = '';
	let cStatusCred = '';
	let dFechaBloqCred = null;
	
	-- Variables de la ejecución del SP de bloqueo de cuentas de captacion
	let cCodRetCap = '';
	let cMovimientoCap = '';
	let cStatusCap = '';
	let cImporteBloqCap = '';
	let cFechaBloqCap = '';
	let cNumClienteCap = '';
	let cClaveAreaCap = '';
	let cCodigoAreaCap = '';
	let cClaveTipoBloqCap = '';
	let cCodTipoBloqCap = '';
	
	begin
		if pTipoCuenta = '01' then
			execute procedure sp_sw_ro_consbloqctacap(pUsuario, pIdFuncion, pNumCuenta)
			into cCodRetCap, cMovimientoCap, cStatusCap, cImporteBloqCap, cFechaBloqCap, 
					cNumClienteCap, cClaveAreaCap, cCodigoAreaCap, cClaveTipoBloqCap, cCodTipoBloqCap;
					
			if cStatusCap = 'B' then -- La cuenta esta bloqueada
				let cStatusBloqueo = '1';
				let cFechaBloqueo = cFechaBloqCap;
				
				select descripcion into cMotivoBloqueo from bdicheq:sc_tipobloqueo where clave = cClaveTipoBloqCap;
			end if;
		elif pTipoCuenta = '06' then
			execute procedure bdicred:sp_consultacuenta ('001', pNumCuenta)
						into cCodErrCred, cMensErrCred, cEmpresaCred, cNumCuentaCred, cNumCteCred, cNombreCteCred, cSucursalCred,
							cBloqueoCred, cCausaCred, cStatusCred, dFechaBloqCred;
							
			if cCodErrCred in('000003', '000004', '000006') then
				let cStatusBloqueo = '1';
				let cFechaBloqueo = dFechaBloqCred;
				let cMotivoBloqueo = cCausaCred;
			end if;
		end if;
		
		let cMotivoBloqueo = UPPER(cMotivoBloqueo);
		return cStatusBloqueo, cMotivoBloqueo, cFechaBloqueo;
	end;
end procedure;