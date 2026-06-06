-- Ningun movimiento en silver debe carecer de cuenta valida (FK).
select t.account_id
from {{ ref('silver_transaction') }} t
left join {{ ref('silver_account') }} a on t.account_id = a.account_id
where a.account_id is null
