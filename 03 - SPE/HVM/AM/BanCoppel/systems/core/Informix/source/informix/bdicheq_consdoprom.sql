create procedure "informix".consdoprom(pempresa char(3),
                                      pcuenta char(20))
       returning char(5),money(14,2);

define vcodret char(5);
define vsdoprom money(14,2);
define vacum_sdo_pos money(14,2);
define vdia_sdo_pos smallint;


   let vcodret = "000";

   select acum_sdo_pos, dia_sdo_pos
      into vacum_sdo_pos, vdia_sdo_pos
      from sc_maenoc
      where empresa = pempresa and cuenta = pcuenta;
   if vdia_sdo_pos > 0 then
      let vsdoprom = vacum_sdo_pos / vdia_sdo_pos;
   else
      let vsdoprom = 0;
   end if
   return vcodret,vsdoprom;
end procedure;