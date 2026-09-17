create procedure "informix".saca_diferencias()

select a.num_credito,
b.sdo_cap_insoluto,sum(capital_debe - capital_pagado) diferenciadebepagado
from sd_amortiza_credito a, sd_maesdos b
where a.num_credito = b.num_credito
group by a.num_credito,b.sdo_cap_insoluto
into temp dif_cred;

select * from dif_cred
where sdo_cap_insoluto <> diferenciadebepagado
into temp diferencias;


end procedure
;