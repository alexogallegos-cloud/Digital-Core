create procedure "informix".doctosbc(pempresa char(3),
                           pcuenta   char(20),
                           psistema  char(2),
                           pbanco    char(3),
                           pctabco   char(20),
                           pdocto    integer,
                           pimporte  money(14,2),
                           pfolio    char(16),
                           pusuario  char(8),
                           psucursal char(4))
        returning char(5);

define v_codret char(5);
define v_row smallint;
define v_fechoy date;
let v_codret="000";

select fecha_hoy into v_fechoy
   from sc_fechas where empresa = pempresa;
select count(*) into v_row
   from sc_maechq
   where empresa = pempresa and cuenta = pcuenta;
if v_row is null then
   let v_codret="100";
   return v_codret;
else
   insert into sc_doctosbc
      values(pempresa,pcuenta,psistema,pbanco,pctabco,pdocto,
             pimporte,pfolio,pusuario,psucursal,v_fechoy," ");
      return v_codret;
end if;
end procedure;