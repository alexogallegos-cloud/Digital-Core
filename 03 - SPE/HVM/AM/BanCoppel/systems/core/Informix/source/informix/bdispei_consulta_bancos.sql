create procedure "informix".consulta_bancos(ult_reg integer)
   returning char(5),integer, char(60), char(1), smallint, smallint, smallint,
             smallint, smallint, char(1), char(1);

-- definicion de variables
  define vbanco        integer;
  define vnombreb      char(60);
  define vreq_formato  char(1);
  define vdig_cuenta   smallint;
  define vdig_sucursal smallint;
  define vdig_plaza    smallint;
  define vopera_tef    smallint;
  define vopera_speua  smallint;
  define vpermitecta   char(1);
  define vpermiteclabe char(1);
  
  define cod_ret       char(5);
  define sql_err       integer;
  define contador      integer;
  define vnumero       integer;
  define chrSpeiActivo  char(1);

-- Inicializacion de variables
let vbanco = 0;
let vnombreb = '';
let vreq_formato = '';
let vdig_cuenta = 0;
let vdig_sucursal = 0;
let vdig_plaza = 0;
let vopera_tef = 0;
let vopera_speua = 0;
let vnumero = 0;
let vpermitecta = 'S';
let vpermiteclabe = 'S';

let cod_ret = '000';


begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret,vbanco, vnombreb, vreq_formato, vdig_cuenta,
                vdig_sucursal,vdig_plaza,vopera_tef,vopera_speua,vpermitecta,vpermiteclabe;
      end if
   end exception;


--set debug file to "consulta_bancos.out";
--trace on;

  let contador = 0;
--  let cod_ret = "111";

  --Determina si valida sobre spl de spei o de speua dependiendo del parametro
  SELECT vchrvalor into chrSpeiActivo FROM tblparametros WHERE chrcveparametro = 'SPEI_ACTIVO';
  
  if chrSpeiActivo = '0' then  

  foreach
     select numero, banco into vnumero, vnombreb from bdispeua:bancos
     union
     select numero, banco from paginterban:bancos
     order  by 2

     let vbanco = 0;
     let vnombreb = '';
     let vreq_formato = '';
     let vdig_cuenta = 0;
     let vdig_sucursal = 0;
     let vdig_plaza = 0;
     let vopera_tef = 0;
     let vopera_speua = 0;
     let vpermitecta = 'S';
     let vpermiteclabe = 'S';


     select banco, numero, plaza, cuenta, sucursal, req_formato, 
            1 opera_speua, permitecta, permiteclabe
     into   vnombreb, vbanco, vdig_plaza, vdig_cuenta, vdig_sucursal, 
            vreq_formato, vopera_speua, vpermitecta, vpermiteclabe
     from   bdispeua:bancos
     where  numero = vnumero;

     if vopera_speua IS NULL then
        let vopera_speua = 0;
        select banco, numero, plaza, cuenta, sucursal, req_formato, 
               1 opera_tef, 'S' permitecta, 'S' permiteclabe
        into   vnombreb, vbanco, vdig_plaza, vdig_cuenta, vdig_sucursal, 
               vreq_formato, vopera_tef, vpermitecta, vpermiteclabe
        from   paginterban:bancos
        where  numero = vnumero;
     else
        select 1 opera_tef
        into vopera_tef
        from   paginterban:bancos
        where  numero = vnumero;
     end if;

    if vopera_tef IS NULL then
       let vopera_tef = 0;
    end if;

--     let cod_ret = "000";
     let contador = contador + 1;
     if contador >= (ult_reg + 1) then
        return cod_ret, vbanco, vnombreb, vreq_formato, vdig_cuenta, vdig_sucursal, vdig_plaza, vopera_speua, vopera_tef, vpermitecta, vpermiteclabe with resume;
     end if;
   end foreach;
   
   else
   
  SELECT vchrvalor into vpermitecta FROM tblparametros WHERE chrcveparametro = 'PERMITIR_CTA11';   

{  foreach
     select numero, banco from bdispei:vbancos
     union
     select numero, banco from paginterban:bancos
     order  by 2

     let vbanco = 0;
     let vnombreb = '';
     let vreq_formato = '';
     let vdig_cuenta = 0;
     let vdig_sucursal = 0;
     let vdig_plaza = 0;
     let vopera_tef = 0;
     let vopera_speua = 0;
     let vpermitecta = 'S';
     let vpermiteclabe = 'S';


     select decode(vchrnombrecorto, '', vchrnombre, vchrnombrecorto), intcvebsi, 0, 0, 0, 'N', 1 opera_speua, 1
     into   vnombreb, vbanco, vdig_plaza, vdig_cuenta, vdig_sucursal, 
            vreq_formato, vopera_speua, vpermiteclabe
     from   bdispei:tblbanco
     where  intcvebsi = vnumero;

     if vopera_speua IS NULL then
        let vopera_speua = 0;
        select banco, numero, plaza, cuenta, sucursal, req_formato, 
               1 opera_tef, 'S' permitecta, 'S' permiteclabe
        into   vnombreb, vbanco, vdig_plaza, vdig_cuenta, vdig_sucursal, 
               vreq_formato, vopera_tef, vpermitecta, vpermiteclabe
        from   paginterban:bancos
        where  numero = vnumero;
     else
        select 1 opera_tef
        into vopera_tef
        from   paginterban:bancos
        where  numero = vnumero;
     end if;

    if vopera_tef IS NULL then
       let vopera_tef = 0;
    end if;

     let contador = contador + 1;
     if contador >= (ult_reg + 1) then
        return cod_ret, vbanco, vnombreb, vreq_formato, vdig_cuenta, vdig_sucursal, vdig_plaza, vopera_speua, vopera_tef, vpermitecta, vpermiteclabe with resume;
     end if;
   end foreach;}
   
 end if;

end
end procedure;