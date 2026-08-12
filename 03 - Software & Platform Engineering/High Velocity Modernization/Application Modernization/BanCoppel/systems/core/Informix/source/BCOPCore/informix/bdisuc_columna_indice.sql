create procedure "informix".columna_indice(tabla char(18), columna int)
returning char(18);

define nombre_columna char(18);
define tabla_id int;

select  tabid into tabla_id  from systables
where tabname = tabla;

select colname into nombre_columna from syscolumns
where tabid = tabla_id and  colno = columna;

return nombre_columna;

end procedure;