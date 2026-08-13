create procedure "informix".corrfolio()
   returning smallint;
  define credito char(20);
  define folio char(16);
  define ri integer;
  define upd smallint;

   let upd = 0;
   foreach
  select
      rowid,
      num_credito,
        trim(usuario)||trim( num_credito[8,11])|| secuencia
     into ri, credito, folio  from sd_movdia
    where codigo_fun  = '034'

     and num_producto = '410'

     update sd_movdia set folio_suc = folio where
        rowid = ri;
      let upd = upd + 1;
   end foreach;
    return upd;
end procedure;