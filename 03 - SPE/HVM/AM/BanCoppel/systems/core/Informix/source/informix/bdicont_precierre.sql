create procedure "informix".precierre(pempresa char(3),w_fecha date)
returning char(3);
define w_proceso        char(20);
define lv_cuantos       integer;
define cod_ret          char(3);


delete from co_balprev
where empresa = pempresa;

let w_proceso = "precierre";
let cod_ret = "99999";
EXECUTE PROCEDURE contproc(pempresa,w_fecha,w_proceso,cod_ret);

delete from co_auditerr;
let cod_ret = "000";

EXECUTE PROCEDURE auditor(pempresa,w_fecha);

EXECUTE PROCEDURE nivelacion_ccostos(pempresa,w_fecha) INTO cod_ret;

select count(*)
into lv_cuantos
from co_auditerr;

if (lv_cuantos = 0) then
   --EXECUTE PROCEDURE gen_balprev(pempresa,w_fecha);
   --EXECUTE PROCEDURE ctas_nuevas(pempresa,w_fecha);
   EXECUTE PROCEDURE contproc(pempresa,w_fecha,w_proceso,cod_ret);
else
   let cod_ret = "142";
   EXECUTE PROCEDURE contproc(pempresa,w_fecha,w_proceso,cod_ret);
   return cod_ret;
end if
return cod_ret;
end procedure;