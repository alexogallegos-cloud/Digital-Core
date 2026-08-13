create procedure "informix".consfirmantescte(pempresa char(3),
                                             pnumcte char(20))
returning char(5),char(30),char(30);

define vcodret char(5);
define vnumreg smallint;
define vnombre char(30);
define vapellidos char(30);
define sql_err integer;

begin
   on exception set sql_err
      if sql_err <> 0 then
        let vcodret = sql_err;
        return vcodret,vnombre,vapellidos;
      end if;
   end exception;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let vcodret = "000";
   let vnombre = " ";
   let vapellidos = " ";


-- ***************************************************************************
-- Valida la informacion de entrada
-- ***************************************************************************
   if pnumcte is null or pnumcte = "" then
      let vcodret = "110";
      return vcodret,vnombre,vapellidos;
   end if;

-- ***************************************************************************
-- Valida que existan firmantes para ese cliente
-- ***************************************************************************
   select count(*) into vnumreg
      from sc_firmantes
      where empresa = pempresa and numcte = pnumcte;
   if vnumreg is null then
      let vcodret = "104";
      return vcodret,vnombre,vapellidos;
   end if


-- ***************************************************************************
-- Extrae firmantes
-- ***************************************************************************
  foreach
     select unique nombre,apellidos into vnombre,vapellidos
        from sc_firmantes
        where empresa = pempresa and numcte = pnumcte
     return vcodret,vnombre,vapellidos with resume;
  end foreach
end
end procedure;