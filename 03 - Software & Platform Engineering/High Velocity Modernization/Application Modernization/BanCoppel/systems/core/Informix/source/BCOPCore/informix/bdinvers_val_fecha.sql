create procedure "informix".val_fecha(pempresa char(3),
                                      pfecha date,
			              pajustar_vencim char(1))
returning char(5), date;

   define cod_ret char(5);
   define cod char(3);
   define w_fecha date;
   define vultdialab char(1);
   define vajusta char(1);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret = "000";


-- ***************************************************************************
-- Valida que la fecha no sea Feriada
-- ***************************************************************************
   select fecha into w_fecha 
      from bdinteg:si_feriado
      where empresa = pempresa and fecha = pfecha and pais = "001" and
                      laborable = "N";
   select valor into vultdialab
      from bdinteg:si_param
      where empresa = pempresa and descripcion = "ultdialab";
   if vultdialab is null then
      let vultdialab = "V";
   end if
   if w_fecha is null then
      let vajusta = "0";
      if vultdialab = "V" then
         if weekday(pfecha) = "0" or                  -- Domingo
	    weekday(pfecha) = "6" then                -- Sabado
            let vajusta = "1";
         end if
      else
         if vultdialab = "S" then
            if weekday(pfecha) = "0" then                -- Domingo
               let vajusta = "1";
            end if
         end if
      end if
      if vajusta = "1" then
	 -- Ajusta la fecha al dia Siguiente/Previo ya que es Inhabil
	 if pajustar_vencim = "S" then
	    let pfecha = pfecha + 1 units day;
	    call val_fecha(pempresa,pfecha, pajustar_vencim) 
		 returning cod_ret, pfecha;
            let cod_ret = "915";
         else
	    let pfecha = pfecha - 1 units day;
	    call val_fecha(pempresa,pfecha, pajustar_vencim)
		 returning cod_ret, pfecha;
            let cod_ret = "916";
         end if
      end if
   else
      -- Ajusta la fecha al dia Siguiente/Previo ya que es Feriado
      if pajustar_vencim = "S" then
	 let pfecha = pfecha + 1 units day;
	 call val_fecha(pempresa,pfecha, pajustar_vencim) 
	      returning cod_ret, pfecha;
         let cod_ret = "917";
      else
	 let pfecha = pfecha - 1 units day;
	 call val_fecha(pempresa,pfecha, pajustar_vencim) 
	      returning cod_ret, pfecha;
         let cod_ret = "918";
      end if
   end if

return cod_ret, pfecha;
end procedure;