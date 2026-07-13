create procedure "informix".cons_tels_web(pnumcte char(20))
                        returning char(5),char(13),char(13);

define vcodret char(5);
define vtel1 char(13);
define vtel2 char(13);
DEFINE vsqlerr int;   


let vcodret = "00000";
let vtel1 = " ";
let vtel2 = " ";


begin
        on exception set vsqlerr
        if vsqlerr <> 0 then
                let vcodret = vsqlerr;
                RETURN vcodret, vtel1, vtel2;
        end if
        end exception;
        
	IF  	pnumcte is null then	
		   -- datos de entrada incompletos	   
		LET vcodret = '00110'; 
		RETURN vcodret, vtel1, vtel2;
	END IF;

        FOREACH

                select telefono
                into vtel1
                from bdinteg:si_telefonos_actual
                where numcte = trim(pnumcte)
                and tipo_tel=1
                order by secuencia desc
        
                EXIT FOREACH;
        END FOREACH
        
        FOREACH

                select telefono
                into vtel2
                from bdinteg:si_telefonos_actual
                where numcte = trim(pnumcte)
                and tipo_tel=2
                order by secuencia desc
        
                EXIT FOREACH;
        END FOREACH

        RETURN vcodret, vtel1, vtel2;

end   
end procedure;