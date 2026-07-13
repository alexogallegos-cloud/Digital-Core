create procedure "informix".altaejecutivos(pUsuario int8)
	returning char(3);

	define iEjecutivo int8;
	define cNombre char(45);
	define cSistema char(2);
	define cEmpresa char(3);
	define cSucursal char(4);
	define cPassword char(8);
	define cUsuario char(8);
	define dVigencia date;
	define iPerfil integer;
	define cRegreso char(3);

	let cEmpresa='001';
	let cSucursal='0001';
	let cPassword='informix';
	let cUsuario='informix';
	let dVigencia='12/31/2010'::date;
	let cRegreso='000';

	


	foreach	select ejecutivo, nombre, sistema
			into iEjecutivo, cNombre, cSistema
			from si_altasejecutivos
			where ejecutivo<>0

		if not exists(select ejecutivo from si_ejecut where ejecutivo=iEjecutivo::char(8)) then
			insert into si_ejecut(empresa, ejecutivo, nombre, password, vigencia, asistente, user_insert, fecha_insert)
			values(cEmpresa, iEjecutivo, cNombre, cPassword, dVigencia, cUsuario, pUsuario, current::date);
		end if;

		foreach	select distinct perfil
				into iPerfil
				from si_perfil_ejecut
				where sistema=cSistema

			if not exists(select ejecutivo from si_perfil_ejecut where ejecutivo=iEjecutivo::char(8) and perfil=iPerfil) then
				insert into si_perfil_ejecut(cod_emp, sistema, ejecutivo, perfil, user_insert, fecha_insert)
				values(cEmpresa, cSistema, iEjecutivo, iPerfil, pUsuario, current::date);
			end if;
		end foreach;
	end foreach;

	return cRegreso;
end procedure;