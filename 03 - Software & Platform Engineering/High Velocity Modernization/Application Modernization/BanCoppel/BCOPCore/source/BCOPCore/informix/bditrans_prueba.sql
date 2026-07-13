create procedure "informix".prueba()
   returning char(2), smallint;

   define v_cod_ret          char(2);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
   define dos_prim_letras char(2);
   define num_cli_coinc   smallint;
   let v_cod_ret     = "00";
   let num_cli_coinc = 0;

-- ****************************************************************************
-- Obtiene y valida los Codigos Correspondientes
-- ****************************************************************************
   -- Extrae parametros de Transferencias
   select nombre1[1,2] into dos_prim_letras from bdicent:si_cliente
                          where bdicent:si_cliente.numero = "010100026";
   select count(*) into num_cli_coinc
      from bdicent:si_cliente
      where bdicent:si_cliente.nombre1[1,2] = dos_prim_letras;
   let v_cod_ret= dos_prim_letras;

return v_cod_ret, num_cli_coinc;
end procedure;