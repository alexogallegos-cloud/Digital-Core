create procedure "informix".conschqdevueltos(pempresa char(3),
                                             pcuenta char(20))
          returning char(5),char(1),integer,money(14,2),char(4),date;

   define vcodret   char(5);
   define vtipochq  char(1);
   define vnumchq   integer;
   define vimpchq   money(14,2);
   define vbanco    char(4);
   define vfecchq   date;
   define vcuenta   char(20);
   define vbcopro   char(4);

--- Inicializa Variables de Salida
   let vcodret   = "000";
   let vtipochq  = " ";
   let vnumchq   = 0;
   let vimpchq   = 0;
   let vbanco    = " ";
   let vfecchq   = " ";


   ----------------------------------------------------------------------------
   -------------------------- VALIDACIONES ------------------------------------
   ----------------------------------------------------------------------------
--- Valida que la Cuenta no sea Blanco
   if pcuenta = " " then
      let vcodret = "110";
      return vcodret, vtipochq, vnumchq, vimpchq, vbanco, vfecchq;
   end if

--- Valida que exista la cuenta
   select cuenta into vcuenta
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   if vcuenta is null then
      let vcodret = "100";
      return vcodret, vtipochq, vnumchq, vimpchq, vbanco, vfecchq;
   end if

--- Obtiene el codigo del banco propio
   select valor into vbcopro
      from bdinteg:si_param
      where descripcion = "banco";

   foreach
      select numerochq,importechq,fechadev,banco
         into vnumchq, vimpchq, vfecchq, vbanco
         from sc_chequedev
         where empresa = pempresa and cuenta = pcuenta
      if vbanco = vbcopro then
         let vtipochq = "C";
      else
         let vtipochq = "D";
      end if
      return vcodret, vtipochq, vnumchq, vimpchq, vbanco, vfecchq with resume;
   end foreach

end procedure
;