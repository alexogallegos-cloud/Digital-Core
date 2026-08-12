CREATE PROCEDURE "informix".envio_corres_web(pempresa char(3),
                                         i_cuenta  char(20),
                                         i_cliente char(20),
                                         cual smallint)
                 returning char(5);
   
   DEFINE v_long_cta            smallint;
   DEFINE w_cod_ret             char(5);
   DEFINE w_cuenta              char(20);
   DEFINE w_edo_cta             char(1);
   DEFINE existe                smallint;

--     SET DEBUG FILE TO "/tmp/envio_corres.out";
--     TRACE ON;
--- Inicializa Variables de Salida
    let w_cod_ret   = "00000";
    let existe = 0;
    let w_cuenta    = "";
    let w_edo_cta   = "";

--- Valida que la Cuenta no sea Blanco
   if i_cuenta = " " then
      let w_cod_ret = "00110";
      return w_cod_ret;
   end if

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
--- Valida que Exista la Cuenta de Cheques y Extrae los Siguientes Campos
   select num_cte,  status_cta
      into w_cuenta, w_edo_cta
      from sc_maechq
      where empresa = pempresa and cuenta = i_cuenta;
   if w_cuenta is null then
      let w_cod_ret = "00100";
      return w_cod_ret;
   end if
   if w_edo_cta = "2" then
      let w_cod_ret = "00200";
      return w_cod_ret;
   end if;
   if w_cuenta != i_cliente then
      let w_cod_ret = "00122";
      return w_cod_ret;
   end if;
   if cual > 0 then
      select secuencia into existe
         from bdinteg:si_direcciones
         where numcte = i_cliente
               and secuencia = cual;
      if existe is null or existe = 0 then
         let w_cod_ret = "00130";
         return w_cod_ret;
      end if;
      update sc_maechq
         set direcc_envio = cual
         where empresa = pempresa and cuenta = i_cuenta;
   end if;
return w_cod_ret;
END PROCEDURE;