create procedure "informix".sp_consbancos(ult_reg smallint)
returning char(5),	-- CodRet
          integer,	-- No. del banco
          char(60),	-- Nombre del banco
		  integer;	-- Permite cta a 11 digitos

-- definicion de variables
  define vchrcod_ret   	char(5);
  define vintcvecesif	integer;
  define vvchrnombre   	varchar(60);
  define vvchrnomCorto 	varchar(20);
  define sql_err   	integer;
  define vintContador	integer;
  define vintPermiteCta11 integer;

-- Inicializacion de variables
let vintcvecesif = 0;
let vvchrnombre = "";
let vchrcod_ret = "000";
let vintContador = 0;
let vintPermiteCta11 = 0;

begin
   on exception set sql_err
      if sql_err <> 0 then
         let vchrcod_ret = sql_err;
         return vchrcod_ret,vintcvecesif,vvchrnombre,vintPermiteCta11;
      end if
   end exception;

  select vchrValor
  into vintPermiteCta11
  from tblparametros
  where vchrcveparametro = 'PERMITIR_CTA11';

  if vintpermitecta11 is null then
  	let vchrcod_ret = '021'; --Falta parametro de permite cuenta.
  	return vchrcod_ret,vintcvecesif,vvchrnombre,vintPermiteCta11;
  end if;

  foreach
     select intcvebsi,UPPER(decode(nvl(vchrnombre, ''), '', vchrnombrecorto, vchrnombre))
     into vintcvecesif, vvchrnombre
     from tblbanco
     where intindice >= 0 and intcvebsi IS NOT NULL and chrhabilitarprom = 1
     order by 2

     let vchrcod_ret = "000";
     let vintContador = vintContador + 1;
     if vintContador >= (ult_reg + 1) then
        let vchrcod_ret = "000";
        return vchrcod_ret,vintcvecesif,vvchrnombre,vintPermiteCta11 with resume;
     end if;
   end foreach;
   if vintContador = 0 then
    return vchrcod_ret,vintcvecesif,vvchrnombre,vintPermiteCta11;
   end if;
end
end procedure;