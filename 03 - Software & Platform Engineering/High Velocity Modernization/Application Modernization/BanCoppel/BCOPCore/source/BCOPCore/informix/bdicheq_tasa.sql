create procedure "informix".tasa() returning decimal(9,6);
define v_fecha_tiie date;
define v_tasa_sbc decimal(9,6);

        select max(fecha) into v_fecha_tiie
                from bdinteg:si_fechavalor
                where codigo="TIIE";

        select valor into v_tasa_sbc 
                from bdinteg:si_fechavalor 
                where codigo="TIIE"
                and fecha=v_fecha_tiie;

        if v_tasa_sbc is null then 
                let v_tasa_sbc=10;
        end if;
return v_tasa_sbc;
end procedure;