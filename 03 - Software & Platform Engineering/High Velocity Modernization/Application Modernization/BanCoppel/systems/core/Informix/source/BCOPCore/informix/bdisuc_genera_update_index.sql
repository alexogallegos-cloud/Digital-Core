create procedure "informix".genera_update_index (inicio int ,interacciones int)
returning  lvarchar;

define i int;
define cadena lvarchar;

let cadena = 'select unique idxname , "update statistics low for table  "&&b.tabname&&"(" &&trim(columna_indice(b.tabname, a.part'||inicio||'))';
if (inicio > 1 and interacciones > 2)
then 
for i = 2 + 1  to interacciones + 1 step 1

let cadena = cadena ||'&&","&&trim(columna_indice(b.tabname, a.part'||i||') )';

if (i = interacciones)
then
exit for;
end if;

end for;

let cadena = cadena ||'&&");" from sysindexes  a, systables b, syscolumns c where a.tabid  > 99 and a.tabid = b.tabid and b.tabid = c.tabid ';

for i = 2 to interacciones + 1 step 1
let cadena = cadena ||' and a.part'||i||' <> 0';
if (i = interacciones)
then
exit for;
end if;
end for;

let cadena = cadena ||' and a.part'||interacciones + 1 ||' = 0';
else

let cadena = cadena || '&&");" from sysindexes  a, systables b, syscolumns c where a.tabid  > 99 and a.tabid = b.tabid and b.tabid = c.tabid and a.part'||inicio||' <> 0';

if (interacciones = 2)
then
let cadena =  cadena ||' and a.part3 = 0';
end if;

end if;
let cadena = cadena||' ;';

return cadena;
end procedure;