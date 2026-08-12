create procedure "informix".consfirmasprod(pempresa char(3),
                                           pcuenta char(20))
returning char(5),char(30),char(30),char(1),char(1),char(50);

define vcodret char(5);
define vnumreg smallint;
define vnombre char(30);
define vapellidos char(30);
define vregfirma char(1);
define vtipfirma char(1);
define vcombinacion char(50);
define sql_err integer;
define vcuenta     char(20);
define vproducto char(4);

begin
   on exception set sql_err
      if sql_err <> 0 then
        let vcodret = sql_err;
        return vcodret,vnombre,vapellidos,vtipfirma,vregfirma,vcombinacion;
      end if;
   end exception;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let vcuenta     = " ";
   let vcodret = "000";
   let vnombre = " ";
   let vapellidos = " ";
   let vtipfirma = " ";
   let vregfirma = " ";
   let vcombinacion = " ";


-- ***************************************************************************
-- Valida la informacion de entrada
-- ***************************************************************************
   if pcuenta is null or pcuenta = "" then
      let vcodret = "110";
      return vcodret,vnombre,vapellidos,vtipfirma,vregfirma,vcombinacion;
   end if;

-- ***************************************************************************
-- Valida que existan firmantes para esa cuenta
-- ***************************************************************************
   select count(*) into vnumreg
      from sc_firmantes
      where empresa = pempresa and cuenta = pcuenta;
   let vcuenta = pcuenta;
   if vnumreg is null or vnumreg = 0 then
      set isolation to dirty read;
      select producto,cuenta_rel
        into vproducto, vcuenta
        from sc_maechq
        where empresa = pempresa and cuenta = pcuenta;
      if vproducto != "105" or vproducto is null then
         let vcodret = "100";
         return vcodret,vnombre,vapellidos,
                vtipfirma,vregfirma,vcombinacion;
      end if;
   end if
-- ***************************************************************************
-- Extrae firmantes
-- ***************************************************************************
  foreach
     select nombre,apellidos,reg_firma,tipo_firma,combinacion
        into vnombre,vapellidos,vregfirma,vtipfirma,vcombinacion
        from sc_firmantes
        where empresa = pempresa and cuenta = vcuenta
        if vtipfirma != "A" and vtipfirma != "B" then
           let vtipfirma="B";
        end if
        return vcodret,vnombre,vapellidos,vtipfirma,vregfirma,vcombinacion
        with resume;
  end foreach
end
end procedure;