create procedure "informix".hist_chq(pempresa char(3))

-------------------------------------------------------------------------
--Definicion de Variables
-------------------------------------------------------------------------
define cuen,ctahist char(20);
define num         int;
define fe_alt      date;
define v_estado char(1);
define v_row integer;
define vimporte  money(14,2);
--------------------------------------------------------------------------
--Actualizando el historico de cheques
--------------------------------------------------------------------------
foreach
   select rowid, cuenta, numero, estado, fecha_alta,importe
      into v_row, cuen, num, v_estado, fe_alt, vimporte
      from sc_contch
      where empresa = pempresa and estado="S" or estado="P" or estado="X"
   select cuenta into ctahist from sc_histch
      where empresa = pempresa and cuenta = cuen and numero = num;
   if ctahist <> cuen or ctahist is null then
      insert into sc_histch
         (empresa,cuenta, numero, estado, fecha_alta,importe)
         values (pempresa,cuen, num, v_estado, fe_alt,vimporte);
   end if
   delete from sc_contch
      where rowid=v_row;
end foreach
return;
end procedure;