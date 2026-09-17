create procedure "informix".conschqpagado(pempresa char(3),
                                          pcuenta char(20),
                                          pnumchq integer)
          returning char(5),char(1),money(14,2),date;

   define vcodret   char(5);
   define vstatchq  char(1);
   define vimpchq   money(14,2);
   define vfecchq   date;
   define vcuenta   char(20);

--- Inicializa Variables de Salida
   let vcodret   = "000";
   let vstatchq  = " ";
   let vimpchq   = 0;
   let vfecchq   = " ";



--- Valida que la Cuenta no sea Blanco
   if pcuenta = " " then
      let vcodret = "110";
      return vcodret, vstatchq, vimpchq, vfecchq;
   end if

--- Valida que el Numero de Documento no sea Nulo
   if pnumchq is null or pnumchq = 0 then
      let vcodret = "110";
      return vcodret, vstatchq, vimpchq, vfecchq;
   end if

--- Valida que exista la cuenta
   select cuenta into vcuenta
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   if vcuenta is null then
      let vcodret = "100";
      return vcodret, vstatchq, vimpchq, vfecchq;
   end if

   select estado,fecha_alta,importe
      into vstatchq, vfecchq, vimpchq
      from sc_contch
      where empresa = pempresa and cuenta = pcuenta and numero = pnumchq;

   if vfecchq is null then
      select estado,fecha_alta,importe
         into vstatchq, vfecchq, vimpchq
         from sc_histch
         where empresa = pempresa and cuenta = pcuenta and numero = pnumchq;
      if vfecchq is null then
         let vcodret = "500";
         return vcodret, vstatchq, vimpchq, vfecchq;
      end if
   end if

   return vcodret, vstatchq, vimpchq, vfecchq;
   
   end procedure
;