create procedure "informix".cotit(pempresa char(3),
                       pcuenta       char(20),
		       pnumero	     smallint,
		       pnombre       char(20),
                       pparentesco   char(2),
                       pnumcte       char(20))
   returning char(5);

-- **************************************************************************
-- Define variables
-- **************************************************************************
   define cod_ret char(5);
   define v_secuencia smallint;
   define sql_err integer;
   define isam_err integer;
   define vtipocte char(1);
   define vnum_cte char(20);

-- **************************************************************************
-- Inicializa variables
-- **************************************************************************
   let cod_ret = "000";
   let sql_err = 0;
   let isam_err = 0;


-- **************************************************************************
-- Verifica parametros de entrada
-- **************************************************************************
   if pcuenta     is null or
      pnumero	    is null or
      pnombre       is null or
      pparentesco   is null or
      pnumcte       is null then
      let cod_ret = "110";
      return cod_ret;
   end if

   begin
     on exception set sql_err, isam_err
       if sql_err <> 0 or isam_err <> 0 then
	  let cod_ret = sql_err;
	  return cod_ret;
       end if
     end exception;

-- **************************************************************************
-- Determina la secuencia a grabar
-- **************************************************************************
   select max(numero) into v_secuencia
      from sv_cotitular
      where empresa = pempresa and cuenta = pcuenta; 

   if v_secuencia is null then
      let v_secuencia = 1;
   else
      let v_secuencia = v_secuencia + 1;
   end if

   select num_cte into vnum_cte
   from sv_maeinv where cuenta = pcuenta;

   if not vnum_cte is null then
      select tipo_cliente into vtipocte
      from   bdinteg:si_cliente
      where  numcte = vnum_cte;
   end if
   
-- **************************************************************************
-- Graba en la tabla de cotitulares
-- **************************************************************************
   select num_cte into vnum_cte
   from sv_maeinv where cuenta = pcuenta;

   if not vnum_cte is null then
      select tipo_cliente into vtipocte
      from bdinteg:si_cliente
      where numcte = vnum_cte;
   end if

   insert into sv_cotitular
          (empresa,cuenta,numero,nombre,parentesco,numcte)
      values(pempresa,pcuenta,v_secuencia,pnombre,pparentesco,pnumcte);

   insert into bdinteg:si_cterelacionado
          (empresa,numcte,sistema,cuenta,
          parentesco,tipo_relacion,
          tipo_cliente_ori,user_insert,
          fecha_insert)
   values (pempresa,pnumcte,"SV",pcuenta,
           pparentesco,"03",vtipocte,USER,
           current);


end
return cod_ret;
end procedure;