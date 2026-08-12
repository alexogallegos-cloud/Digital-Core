create procedure "informix".valida_spei(monto money(14,2), num_cte char(20), num_ren integer)
   returning char(5), char(20);

-- ** Valores de retorno:
--    1) Codigo de retorno
--    2) No. de cta. del cliente para efectuar cargo

-- ************* Declaracion deVariables

-- Variables para convenio_mn
   define vt_cod_ret           char(5);
   define vt_cuenta            char(20);
   define vt_bloq_prom         char(1);
   define vt_status            char(1);
   define vt_monto_min         money(14,2);
   define vt_monto_max         money(14,2);
   define vt_banco             integer;      -- FRA 20/10/99

-- Inicia Debug del Programa	FRA 09/08/1999
--set debug file to "/tmp/bel/valida_spei.dbg";
--trace on;

-- ************* Inicializacion de Variables
   let vt_cod_ret = 0;
   let vt_cuenta = 0;
   let vt_banco = 0;    --FRA 20/10/1999
   let vt_monto_min=0;
   let vt_monto_max=0;

-- Establece Modo de Espera
   --set isolation to cursor stability;
   set isolation to dirty read;
   set lock mode to wait;


-- ************* Programa Principal
-- Lectura de Cada Una de lasOrdenes a Analizar
  foreach orden_cur for
   select importemaximo, status, cuentacliente,banco
      into vt_monto_max, vt_status, vt_cuenta,vt_banco
      from terceros:convenio_mn
      where cliente = num_cte
        and renglon = num_ren
      if vt_banco =60 then
         Let vt_cod_ret =755;
      end if

      if vt_status <> "A" then
         Let vt_cod_ret = 821;
      end if

      if monto < vt_monto_min then
         Let vt_cod_ret = 823;
      end if

      if monto > vt_monto_max then
         Let vt_cod_ret = 824;
      end if
  end foreach

return vt_cod_ret, vt_cuenta;

end procedure;