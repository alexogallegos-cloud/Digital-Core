create procedure "informix".sp_prueba() returning integer;
{
MODIFICACION: Daniel Chirinos Lopez
              M-19/sep/2006
              - Se modifico las lineas que direccionaban a bdicent por bdinteg
}
define v_codigos varchar(20);
define v_cantidad integer;

let v_codigos = '116, 115';

select count(*) into v_cantidad
--->from bdicent:si_codret
from bdinteg:si_codret
where codigo_retorno in (v_codigos);

return v_cantidad;


end procedure
;