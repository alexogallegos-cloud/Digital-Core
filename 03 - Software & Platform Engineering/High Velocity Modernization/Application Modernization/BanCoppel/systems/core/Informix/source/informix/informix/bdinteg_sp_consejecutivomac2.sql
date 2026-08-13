CREATE PROCEDURE "informix".sp_consejecutivomac2(pejecutivo char(8), pmac char(12), p_sTipo char(1))
	returning char(5),char(1) ;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;
define vmac char(12);
define vstatus char(1);
define vmach char(3) ;
define vsucursal char(4) ;
define msucursal char(4) ;
define vdepto char(3) ;
define vpuesto char(3) ;
define varea char(3) ;
define vsuc char(4) ;
define vtejecut char(2);
define cAreaMaquina char(3);
define vExiste integer;
define compare_ejecutivo char(8);

let compare_ejecutivo = "";

let vmach="0" ;
let vciclo = 0;
let vcodret = "000";
let vsqlerr = 0;

let vmac = "";
let vstatus = "";
let vsucursal = "";
let vdepto = "";
let vpuesto = "";
let varea = "";
let vsuc = "";
let msucursal = "";
let vtejecut = "";
let cAreaMaquina = "";
let vExiste = 0;

--SET DEBUG FILE TO "/tmp/anj/sp_consejecutivomac.sql";
--TRACE ON;

BEGIN

	on exception set vsqlerr
		if vsqlerr <> 0 then
			-- rollback work;
			let vcodret = vsqlerr;
			return vcodret,vmac ;
		end if;
	end exception;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET pmac = TRIM(pmac);

	Select sucursal, departamento, puesto
	into vsucursal, vdepto, vpuesto
	from "informix".si_ejecut
	where ejecutivo = pejecutivo;

	IF p_sTipo = 'Z' AND vpuesto='005' THEN
		let vmach='1';
	ELSE

		SELECT sucursal
		INTO msucursal
		FROM "informix".si_sucursalesmaquina
		WHERE mac = upper(pmac);
	
		select tipo_maquina
		INTO vtejecut
		from "informix".si_equiv_ejecut
		where tipo_ejecut=p_sTipo;

		--Begin work;

		IF vsucursal = msucursal THEN

			if cast(nvl(vsucursal,'0') as int) > 0 and cast(nvl(vdepto,'0') as int) = 0 then

				Select area
				into varea
				From "informix".si_macarea
				where sucursal='0001' and puesto = vpuesto;
				
				Select count(ejecutivo) into vExiste 
				From "informix".si_macejecutivo where ejecutivo = pejecutivo;
				
				if vExiste > 0 then
					Foreach

						Select status
						into vstatus
						from "informix".si_macejecutivo
						where ejecutivo = pejecutivo

						Select distinct sucursal
						into vsuc
						From "informix".si_sucursalesmaquina where mac = upper(pmac);

						IF (p_sTipo = 'A') OR (p_sTipo = 'G') THEN
							if not vsuc = '' then
							
								let vExiste = 0;
								Select count(ejecutivo) into vExiste
								from "informix".si_macejecutivo where ejecutivo = pejecutivo and mac = vsuc;
								
								if vExiste > 0 then
									Select status
									into vstatus
									from "informix".si_macejecutivo
									where ejecutivo = pejecutivo and mac = vsuc;

									if vstatus in ('A','T') then
										let vmach='1';
										exit Foreach;
									else
										let vmach='2';
									end if;
								else
									let vmach='3';
								end if;
							else
								let vmach='3';
							end if;
						ELSE
							/*
							IF vpuesto = '003' AND p_sTipo = 'U' THEN
								LET varea = 'AU';
								LET vtejecut = 'AU';
							END IF;
							*/
							IF (vpuesto = '008' AND p_sTipo = 'U') or (vpuesto = '010' AND p_sTipo = 'N') or (vpuesto = '015' AND p_sTipo = 'E') THEN
								LET varea = 'PR';
								LET vtejecut = 'PR';
							END IF;
							
							let vExiste = 0;
							Select count(mac) into vExiste
							From "informix".si_sucursalesmaquina where mac = upper(pmac) and sucursal = vsuc and area = varea;
							
							if vExiste > 0 then
								let vExiste = 0;
								Select count(mac) into vExiste 
								from "informix".si_sucursalesmaquina where sucursal=vsuc and area=varea and departamento=vdepto and vtejecut=varea;
								if vExiste > 0 then
									if vstatus in ('A','T') then
										let vmach='1';
										exit Foreach;
									else
										let vmach='2';
									end if;
								else
									let vmach='3';
								end if;
							else
								let vmach='3';
							end if;
						END IF;
					end Foreach;
				else
					let vmach='3';
				end if;

			else
				let vExiste = 0;
				select count(me.mac) into vExiste 
				from "informix".si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac);
				if vExiste > 0 then
					let vExiste = 0;
					select count(me.mac) into vExiste
					from "informix".si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac) and me.status in ('A','T');
					if vExiste > 0then
						let vmach='1';
					else
						let vmach='3';
					end if;
				else
					let vmach='2';
				end if;
			end if;

		ELSE
			let vmach='3';
		END IF;
			IF vmach ='2' OR vmach = '3' THEN
				--LFCP 23 1187 INICIO
				/*SELECT si_bitacora_loginfallido para ver si el usuario existe en la tabla*/
					SELECT usuario
					INTO compare_ejecutivo
					FROM "informix".si_bitacora_loginfallido
					where usuario = pejecutivo;
					
				/*Si el usuario existe entonces*/
				IF pejecutivo = compare_ejecutivo THEN
				
				UPDATE "informix".si_bitacora_loginfallido 
				SET sucursal = vsucursal, puesto = vpuesto , fecha_login = current, mac = upper(pmac) , intentos_fallido = intentos_fallido +1 
				WHERE usuario = compare_ejecutivo;
				/*Si el usuario NO existe entonces*/
				ELSE
					INSERT INTO "informix".si_bitacora_loginfallido(usuario, sucursal, puesto, fecha_login, mac, intentos_fallido)
					VALUES (pejecutivo, vsucursal, vpuesto, current, upper(pmac), 1);
				END IF;
				
			END IF;
			--LFCP 23 1187 FIN
		END IF;

	return vcodret,vmach ;

END;
end procedure;