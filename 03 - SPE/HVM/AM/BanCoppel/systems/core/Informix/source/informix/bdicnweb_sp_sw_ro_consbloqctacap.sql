CREATE procedure "informix".sp_sw_ro_consbloqctacap(pIdUsuario char(8), pIdFuncion char(10), pNumCta char(20))
returning char(5) as codRet,
				char(2) as movimiento,
				char(2) as status,
				money(14,2) as importeBloq,
				date as fechaBloq,
				char(15) as numCliente,
				char(2) as claveArea,
				char(1) as codigoArea,
				char(2) as claveTipoBloq,
				char(1) as codTipoBloq
	
	define cCodRet char(5);
	define cMensaje char(45);
	define cMovimiento char(2);
	define cClave char(5);
	define cStatus char(2);
	define cImporteBloq money(14,2);
	define cFechaBloq date;
	define cIdUsuario char(10);
	define cDescMotivoBloq char(45);
	define cDescOpcBloq  char(45);
	define cDescAreaSolic char(25);
	define cDescTipoBloq char(25);
	define cNumCliente char(15);
	define cClaveArea char(2);
	define cCodigoArea char(1);
	define cCodTipoBloq char(1);
	define cClaveTipoBloq char(2);
	define iSqlErr int;
	define iNoRows int;
	
	let cCodRet = '00000';
	let cMensaje = '';
	let cMovimiento = '';
	let cClave = '';
	let cStatus = '';
	let cImporteBloq = '';
	let cFechaBloq = '';
	let cIdUsuario = '';
	let cDescMotivoBloq = '';
	let cDescOpcBloq = '';
	let cDescAreaSolic = '';
	let cDescTipoBloq = '';
	let cNumCliente = '';
	let cClaveArea = '';
	let cCodigoArea = '';
	let cClaveTipoBloq = '';
	let cCodTipoBloq = '';
	let iSqlErr = 0;
	let iNoRows = 0;
	
	begin
		
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cMovimiento, cStatus, cImporteBloq, cFechaBloq, 
					cNumCliente, cClaveArea, cCodigoArea, cClaveTipoBloq, cCodTipoBloq;
			end if;
		end exception;
		
	--SET DEBUG FILE TO "/informix/VH/sp_sw_ro_consbloqctacap.out";
	--TRACE ON;

		-- Validaciones
		if pIdUsuario = '' or pIdFuncion = '' or pNumCta = '' then
			let cCodRet = '00003';
			return cCodRet, cMovimiento, cStatus, cImporteBloq, cFechaBloq, 
					cNumCliente, cClaveArea, cCodigoArea, cClaveTipoBloq, cCodTipoBloq;
		end if;
		
		--execute procedure bdinteg:sp_cnsif_permisosejecutivo(pIdUsuario, pIdFuncion, pNumCliente, cSistemaCta,'2') into cCodRet;
		--if cCodRet <> '00000' then
		--	return cCodRet, cMovimiento, cStatus, cImporteBloq, cFechaBloq, 
		--		cNumCliente, cClaveArea, cCodigoArea, cClaveTipoBloq, cCodTipoBloq;
		--end if;
		
		foreach execute procedure bdicheq:sp_blqconsultabloqueo(pNumCta)
			into cCodRet, cMensaje, cMovimiento, cClave, cStatus, cImporteBloq, cFechaBloq, 
				cIdUsuario, cDescMotivoBloq, cDescOpcBloq, cDescAreaSolic, cDescTipoBloq, 
				cNumCliente, cClaveArea, cCodigoArea, cClaveTipoBloq, cCodTipoBloq
				
			let iNoRows = iNoRows + 1;
			IF cIdUsuario NOT IN("agnt70ct","informix") THEN			
				if iNoRows = 1 then
					exit foreach;
				end if;
			END IF;
		end foreach;
			
		if cCodRet <> '00000' then
			let cMovimiento = 'D';
			let cStatus = 'D';
			let cCodRet = '00000';
		end if;
		
		return cCodRet, cMovimiento, cStatus, cImporteBloq, cFechaBloq, 
					cNumCliente, cClaveArea, cCodigoArea, cClaveTipoBloq, cCodTipoBloq;
		
		
	end;
	
end procedure;