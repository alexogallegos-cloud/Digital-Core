create procedure "informix".inicio_mes(pempresa char(3))
   returning char(5);

   -- Define variables
   define vcodret char(5);
   define vsqlerr integer;

begin
   on exception set vsqlerr
      if vsqlerr < 0 then
	 let  vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   -- Inicializa variables
   let vcodret = "000";



   delete from sv_movmes;
   return vcodret;
end
end procedure;