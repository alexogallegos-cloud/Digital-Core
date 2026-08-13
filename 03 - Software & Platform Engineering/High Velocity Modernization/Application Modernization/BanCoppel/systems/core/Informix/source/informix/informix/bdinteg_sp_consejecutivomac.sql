CREATE procedure "informix".sp_consejecutivomac(pejecutivo char(8), pmac char(12), p_sTipo char(1))
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

let vmach="0" ;
let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vmac = "";
let vstatus = "";
let vsucursal = "";
let vdepto = "";
let vpuesto = "";
let varea = "";
let vsuc = "";
let msucursal = "";
let vtejecut = "";



--SET DEBUG FILE TO "/tmp/sp_consejecutivomac.sql";
--TRACE ON;

begin

   on exception set vsqlerr
      if vsqlerr <> 0 then
	 -- rollback work;
         let vcodret = vsqlerr;
         return vcodret,vmac ;
      end if;
   end exception;

        Select sucursal, departamento, puesto
        into vsucursal, vdepto, vpuesto
        from si_ejecut
        where ejecutivo = pejecutivo;

        SELECT sucursal
        INTO msucursal
        FROM si_sucursalesmaquina
        WHERE mac = trim(upper(pmac));

        select tipo_maquina 
        INTO vtejecut        
        from si_equiv_ejecut 
        where tipo_ejecut=p_sTipo;

 --Begin work;

        IF vsucursal = msucursal THEN

          if cast(nvl(vsucursal,'0') as int) > 0 and cast(nvl(vdepto,'0') as int) = 0 then

            Select area
            into varea
            From si_macarea
            where sucursal='0001' and puesto = vpuesto;

            if exists(Select ejecutivo From si_macejecutivo where ejecutivo = pejecutivo) then
                Foreach

                    Select status
                    into vstatus
                    from si_macejecutivo
                    where ejecutivo = pejecutivo

                    Select distinct sucursal
                    into vsuc
                    From si_sucursalesmaquina where mac = trim(upper(pmac));

					IF p_sTipo = 'A' THEN
						if not vsuc = '' then
                            if exists(Select ejecutivo from si_macejecutivo where ejecutivo = pejecutivo and mac = vsuc) then
                                Select status
                                into vstatus
                                from si_macejecutivo
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
                        if exists(Select mac From si_sucursalesmaquina where mac = trim(upper(pmac)) and sucursal = vsuc and area = varea) then
                            if exists(Select mac from si_sucursalesmaquina where sucursal=vsuc and area=varea and departamento=vdepto and vtejecut=varea) then
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
            if exists(select me.mac from si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac)) then
                if exists(select me.mac from si_macejecutivo me where me.ejecutivo = pejecutivo and me.mac = upper(pmac) and me.status in ('A','T')) then
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

    return    vcodret,vmach ;

-- commit work;
end
end procedure;