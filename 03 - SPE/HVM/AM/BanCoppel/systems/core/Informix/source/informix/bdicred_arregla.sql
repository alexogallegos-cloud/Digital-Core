create procedure "informix".arregla()
define credito char(15);
define cliente char(9);
define prowid int;


foreach with hold
select rowid, numcte_cto into prowid, cliente from sd_maecontrato

select min(num_credito) into credito from sd_maecred 
where numcte = cliente;


update sd_maecontrato
set num_contrato = credito
where rowid = prowid;
end foreach;
end procedure
;