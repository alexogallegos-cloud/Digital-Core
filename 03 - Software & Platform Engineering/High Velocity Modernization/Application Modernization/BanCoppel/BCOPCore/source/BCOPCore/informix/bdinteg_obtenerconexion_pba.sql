create procedure "informix".obtenerconexion_pba(pEmpresa char(3), pDSN char(15), pUsuario char(8))
	returning	char(3) as regreso, char(15) as instancia, char(15) as ip, integer as puerto, 
				char(15) as protocolo, char(15) as usuario, char(32) as password, char(15) as db, char(15) as dsn;
	
	define cRegreso char(3);
	define cInstancia char(15);
	define cIP char(15);
	define iPuerto integer;
	define cProtocolo char(15);
	define cUsuario char(15);
	define cPassword char(32);
	define cDB char(15);
	define cDSN char(15);
		
	let cRegreso='000';
	let cInstancia='';
	let cIP='';
	let iPuerto=0;
	let cProtocolo='';
	let cUsuario='';
	let cPassword='';
	let cDB='';
	let cDSN='';
	
set lock mode to wait 3;
set pdqpriority 0;

	begin
		
		select {+INDEX(si_ejecut idx_si_ejecut), +INDEX(si_perfil_ejecut idx_si_perfil_ejecut), +INDEX(si_ejecutdb idx_si_ejecutdb)} first 1 db.instancia, db.ip, db.puerto, db.protocolo, eje.asistente, eje.password, db.bd, db.dsn
		into cInstancia, cIP, iPuerto, cProtocolo, cUsuario, cPassword, cDB, cDSN
		from si_ejecut eje, si_perfil_ejecut per, si_ejecutdb db
		where eje.empresa=pEmpresa
			and eje.ejecutivo=pUsuario
			and per.cod_emp=eje.empresa
			and per.ejecutivo=eje.ejecutivo 			
			and db.sistema=per.sistema
			and db.dsn=pDSN;
	
		if cDSN is null then
			let cRegreso='001';
		end if;
		
		return cRegreso, cInstancia, cIP, iPuerto, cProtocolo, cUsuario, cPassword, cDB, cDSN;
	end	
end procedure;