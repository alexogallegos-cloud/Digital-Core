create procedure "informix".abonacompensatorio(pempresa char(3),pfecha date)

returning char(5);

define vfolio_mov char(16);
define vfecha date;
define vfechamov date;
define vhoramov char(12);
define vfoliosuc char(16);
define vsecuencia int;
define vsucursal char(4);
define vusuario char(8);
define vcuenta char(20);
define vtransacc char(4);
define vnumcredito char(20);
define vnrotarjeta varchar(250);
define vcodigofun char(3);
define vcodigotran char(4);
define vmonto  decimal(18,2);
define vmontodls  decimal(14,2);
define vtipocambio  decimal(14,0);
define vreferencia varchar(250);
define vtpmovto  char(1);
define vrfcomer  varchar(250);
define vreferencia23  varchar(250);
define cod_ret char(3);
define sql_err smallint;

   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;


let vfolio_mov = "";
let vfecha = "01122007";
let vfechamov = "01122007";
let vhoramov = "";
let vfoliosuc = "";
let vsecuencia  = 0;
let vsucursal  ="";
let vusuario  ="";
let vcuenta    ="";
let vtransacc  = "";
let vnumcredito = "";
let vnrotarjeta = "";
let vcodigofun = "";
let vcodigotran = "";
let vmonto   = 0;
let vmontodls   = 0;
let vtipocambio   = 0;
let vreferencia = "";
let vtpmovto = "";
let vrfcomer  = "";
let vreferencia23 = "";
let vusuario   = "";
let cod_ret = "000";
--let sql_err = 0;

--set debug file to "dipdup.out";
--trace on;

	foreach

		select secuencia,fecha_mov,hora_mov,trim(num_credito) num_credito,sucursal,user usuario,
		       decode(codigo_fun,339,6931,340,6932,002,6933) transacc,monto,folio_suc,trim(nro_tarjeta) nro_tarjeta,0 monto_dls,
		       tipo_cambio,referencia,"C" tpo_mvto,rfc_comer,referencia23

		into vsecuencia,vfechamov,vhoramov,vnumcredito,vsucursal,vusuario,vtransacc,vmonto,vfoliosuc,vnrotarjeta,vmontodls,
		vtipocambio,vreferencia,vtpmovto,vrfcomer,vreferencia23

		from compensatorio

		execute procedure bdicred:abono_cred(pempresa,vnumcredito,vsucursal,vusuario,vtransacc,vmonto,vfoliosuc,vnrotarjeta,vmontodls,vtipocambio, 
                                     pfecha,vreferencia,vtpmovto,vrfcomer,vreferencia23) into cod_ret; 


if cod_ret = "000" then
			update bdicred:sd_movhis
			set reversado = "S"
			where fecha_mov = vfechamov
                        and   num_credito = vnumcredito
		        and   sucursal = vsucursal
			and   hora_mov  = vhoramov  
			and   secuencia = vsecuencia
		        and   empresa = pempresa;
				
end if;
end foreach

return cod_ret;

end procedure;