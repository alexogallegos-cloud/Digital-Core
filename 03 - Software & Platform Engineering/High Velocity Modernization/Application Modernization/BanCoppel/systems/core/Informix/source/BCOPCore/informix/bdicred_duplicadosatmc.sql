create procedure "informix".duplicadosatmc(pempresa char(3),pfecha date)

returning int;

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

insert into sd_transfun
values("001","005",10,"001","6931","CORRIGE COMISION");

insert into sd_transfun
values("001","005",11,"001","6932","CORRECCION IVA");

insert into sd_transfun
values("001","005",12,"001","6933","CORRECCION RETIRO");

foreach

select secuencia,trim(a.folio_mov),a.fecha,b.folio_suc,trim(a.cuenta) cuenta,trim(b.num_credito)num_credito,
b.codigo_fun,b.monto,b.fecha_mov,b.usuario

into vsecuencia,vfolio_mov,vfecha,vfoliosuc,vcuenta,vnumcredito,vcodigofun,vmonto,vfechamov,vusuario
from bditarjeta:td_conatmc a,bdicred:sd_movhis2602 b
where a.folio_mov = b.folio_suc
and (b.fecha_mov = "12/26/2007" or fecha_mov = "01/02/2008")
and (a.fecha = "12/26/2007" OR a.fecha = "01/02/2008")
and usuario = "intercar"


if exists(select * from bdicred:sd_movhis2602
	  where num_credito = vnumcredito
	  and   folio_suc = vfolio_mov
	  and   nro_tarjeta = vcuenta
	  and   codigo_fun = vcodigofun
	  and   monto = vmonto
      and   (fecha_mov = "12/26/2007" or fecha_mov = "01/02/2008")
	  and   usuario = "informix"
) then


select b.secuencia,b.fecha_mov,b.hora_mov,trim(b.num_credito) num_credito,b.sucursal,user usuario,
decode(b.codigo_fun,002,6933,340,6932,339,6931) codigo_tran,b.monto,b.folio_suc,trim(b.nro_tarjeta) nro_tarjeta,0 monto_dls,
b.tipo_cambio,b.referencia,"C" tpo_mvto,rfc_comer,referencia23

into vsecuencia,vfechamov,vhoramov,vnumcredito,vsucursal,vusuario,vcodigotran,vmonto,vfoliosuc,vnrotarjeta,vmontodls,
vtipocambio,vreferencia,vtpmovto,vrfcomer,vreferencia23


from bdicred:sd_movhis2602 b
where num_credito = vnumcredito
and   folio_suc = vfoliosuc 
and   codigo_fun = vcodigofun 
and   monto = vmonto
and   (b.fecha_mov = "12/26/2007" or b.fecha_mov = "01/02/2008")
and   b.usuario = "informix";


execute procedure bdicred:abono_cred(pempresa,vnumcredito,vsucursal,vusuario,vcodigotran,vmonto,vfoliosuc,vnrotarjeta,vmontodls,vtipocambio, pfecha,vreferencia,vtpmovto,vrfcomer,vreferencia23) into cod_ret; 

end if;

if cod_ret = "000" then
			update bdicred:sd_movhis
			set reversado = "S"
			where empresa = pempresa
			and   secuencia = vsecuencia
			and   fecha_mov = vfechamov
			and   hora_mov  = vhoramov  
		        and   sucursal = vsucursal
                        and   num_credito = vnumcredito;
				
end if;
end foreach

return cod_ret;

end procedure;