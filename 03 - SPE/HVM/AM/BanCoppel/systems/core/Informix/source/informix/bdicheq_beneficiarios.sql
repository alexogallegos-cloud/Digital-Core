create procedure "informix".beneficiarios( pempresa char(3),
              pcuenta        char(20),
              psecuencia     smallint,
	      pnombre         char(40),
              pparentesco     char(2),
              porcentaje     smallint,
	      pnumcte	     char(20)) 
returning char(5);

define cod_ret     char(5);
define longitud    smallint;
define vnum_cte    char(20);
define vtipocte    char(1);

define sql_err, 
       isam_err    integer;

define v_long_cta  CHAR(2);


begin

   on exception set sql_err, isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

SET ISOLATION TO DIRTY READ;
set lock mode to wait 3;

   let cod_ret="000";

   if pcuenta is null or
      psecuencia is null or
        pnumcte is null or
	pparentesco is null or
        porcentaje is null then
        let cod_ret="110";
        return cod_ret;
   end if

   if psecuencia = 1 then  
      delete from sc_beneficiario
      where empresa = pempresa and cuenta = pcuenta ;
   end if;

   select num_cte into vnum_cte
   from sc_maechq where cuenta = pcuenta;

   if not vnum_cte is null then
      select tipo_cliente into vtipocte
      from   bdinteg:si_cliente 
      where  numcte = vnum_cte;
   end if 


   insert into sc_beneficiario (empresa, cuenta, secuencia, nombre, parentesco, porcentaje, numcte)
                         values(pempresa,pcuenta, psecuencia, pnombre, pparentesco, porcentaje, pnumcte);

   insert into bdinteg:si_cterelacionado 
          (empresa,numcte,sistema,cuenta,
          tipo_relacion,parentesco,
          tipo_cliente_ori,user_insert,
          fecha_insert)
   values (pempresa,pnumcte,"SC",pcuenta,
	  "01",pparentesco,vtipocte,USER,
           current);

   return cod_ret;



end;
end procedure;