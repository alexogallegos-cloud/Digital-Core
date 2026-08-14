create procedure "informix".ins_consulta_buro( pempresa char(03),
psucursal char(03), pusuario char(08),pnum_solicitud char(20));
--returning char(5);

--------- Declaraciones   Generales
define inicio int;
define item_cadena int;
define item_valor  int;
define etiqueta_size int;
define tamamax int;
define tamares int;
define tamafin int;
define longitud_etiqueta int;
define etiqueta char(04);
define valor_cadena lvarchar;
define sql_err int;
define paso varchar(10);
define salva char(04);
define i int;
define fecha date;
define encuentra int;
define bandera int;
define continua int;
define cod_ret char(5);
define pnum_cliente char(20);
define vhora datetime hour to fraction(3);
---- Deficicion tabla br_pn
define pnpn varchar(26);
define pn00 varchar(26);
define pn01 varchar(26);
define pn02 varchar(26);
define pn03 varchar(26);
define pn04 varchar(8);
define pn05 varchar(13);
define pn06 varchar(04);
define pn07 varchar(04);
define pn08 char(02);
define pn09 char(1);
define pn10 varchar(20);
define pn11 char(1);
define pn12 char(1);
define pn13 varchar(20);
define pn14 varchar(20);
define pn15 varchar(20);
define pn16 char(2);
define pn17 char(2);
define pn18 varchar(30);
define pn19 varchar(8);
define pn20 varchar(8);

---- Deficicion tabla br_pa
define papa varchar(40);
define pa00 varchar(40);
define pa01 varchar(40);
define pa02 varchar(40);
define pa03 varchar(40);
define pa04 varchar(04);
define pa05 char(05);
define pa06 char(8);
define pa07 varchar(11);
define pa08 varchar(08);
define pa09 varchar(11);
define pa10 char(1);
define pa11 char(1);
define pa12 char(8);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_papa varchar(40);


---- Deficicion tabla br_pe
define pepe varchar(40);
define pe00 varchar(40);
define pe01 varchar(40);
define pe02 varchar(40);
define pe03 varchar(40);
define pe04 varchar(40);
define pe05 varchar(04);
define pe06 char(05);
define pe07 varchar(11);
define pe08 varchar(08);
define pe09 varchar(11);
define pe10 varchar(30);
define pe11 char(08);
define pe12 char(02);
define pe13 varchar(09);
define pe14 varchar(01);
define pe15 varchar(15);
define pe16 char(08);
define pe17 char(08);
define pe18 char(08);
define pe19 char(01);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_pepe varchar(40);

---- Deficicion tabla br_tl
define tltl char(08);
define tl00 char(04);
define tl01 char(10);
define tl02 varchar(16);
define tl03 varchar(11);
define tl04 varchar(25);
define tl05 char(01);
define tl06 char(01);
define tl07 char(02);
define tl08 char(02);
define tl09 varchar(09);
define tl10 varchar(04);
define tl11 char(1);
define tl12 varchar(9);
define tl13 char(08);
define tl14 char(08);
define tl15 char(08);
define tl16 char(08);
define tl17 char(08);
define tl18 char(01);
define tl19 char(08);
define tl20 varchar(40);
define tl21 varchar(09);
define tl22 varchar(09);
define tl23 varchar(09);
define tl24 varchar(09);
define tl25 varchar(04);
define tl26 char(02);
define tl27 varchar(24);
define tl28 char(08);
define tl29 char(08);
define tl30 char(02);
define tl31 char(03);
define tl32 char(02);
define tl33 char(02);
define tl34 char(02);
define tl35 char(02);
define tl36 varchar(09);
define tl37 char(08);
define tl38 char(02);
define tl42 char(08);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_tltl char(08);

---- Deficicion tabla br_iq
define iqiq  char(08);
define iq00 char(04);
define iq01 char(10);
define iq02 varchar(16);
define iq03 varchar(11);
define iq04 char(02);
define iq05 char(02);
define iq06 varchar(09);
define iq07 char(01);
define iq08 char(01);
define iq09 varchar(25);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_iqiq char(08);

define entro char(1);
---- Deficicion tabla br_rs
define rsrs char(08);
define rs00 char(02);
define rs01 char(02);
define rs02 char(02);
define rs03 char(02);
define rs04 char(02);
define rs05 char(02);
define rs06 char(02);
define rs07 char(02);
define rs08 char(02);
define rs09 char(04);
define rs10 varchar(04);
define rs11 char(04);
define rs12 char(04);
define rs13 char(04);
define rs14 char(04);
define rs15 char(02);
define rs16 char(02);
define rs17 char(01);
define rs18 char(08);
define rs19 char(01);
define rs20 char(02);
define rs21 varchar(09);
define rs22 varchar(09);
define rs23 varchar(10);
define rs24 varchar(09);
define rs25 varchar(09);
define rs26 varchar(03);
define rs27 varchar(09);
define rs28 varchar(10);
define rs29 varchar(09);
define rs30 varchar(09);
define rs31 char(02);
define rs32 char(02);
define rs33 char(02);
define rs34 char(08);
define rs35 char(08);
define rs36 char(02);
define rs37 char(08);
define rs38 char(02);
define rs39 char(08);
define rs40 char(02);
define rs41 char(08);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_rsrs char(08);

---- Deficicion tabla br_hi
define hihi char(08);
define hi00 char(03);
define hi01 varchar(16);
define hi02 varchar(48);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_hihi char(08);


---- Deficicion tabla br_hr
define hrhr char(08);
define hr00 char(03);
define hr01 varchar(16);
define hr02 varchar(48);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_hrhr char(08);

---- Deficicion tabla br_cr
define crcr varchar(04);
define cr00 lvarchar;


---- Deficicion tabla br_sc
define scsc  varchar(30);
define sc00 varchar(03);
define sc01 varchar(04);
define sc02 varchar(03);
define sc03 varchar(03);
define sc04 varchar(03);
define sc06 varchar(02);

---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_scsc varchar(30);

---- Etiqueta Error ERRRUR25
define verrorburo char(8);
define nrows smallint;
define vfecha_hoy date;
define pcadena char(250);
define pcadena1 char(250);
define pcadena2 char(250);
define regre smallint;
  set debug file to "/pisa/pisabanco/pisa_ftes/buro/ins_con.out";
   trace on;

select fecha_hoy into vfecha_hoy from bdicred:sd_fechas;
let verrorburo = "";
let vhora = extend(current,hour to fraction(3));
let nrows = 0;
let tamamax = 0;
select length(regreso) into tamamax
from sb_regreso
  where num_solicitud = pnum_solicitud;
if tamamax is null then
   let tamamax = 0;
else
   let tamamax = tamamax -1;
end if
if tamamax = 0 then
return;
end if
if tamamax > 251 then
  select substr(regreso,1,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  select substr(regreso,1,tamamax) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
insert into br_auditor values(pnum_solicitud,vfecha_hoy,vhora);
----  Inicializaciòn de valores para tabla br_pn
let pnpn = " ";
let pn00 = " ";
let pn01 = " ";
let pn02 = " ";
let pn03 = " ";
let pn04 = null;
let pn05 = " ";
let pn06 = " ";
let pn07 = " ";
let pn08 = " ";
let pn09 = " ";
let pn10 = " ";
let pn11 = " ";
let pn12 = " ";
let pn13 = " ";
let pn14 = " ";
let pn15 = " ";
let pn16 = " ";
let pn17 = " ";
let pn18 = " ";
let pn19 = null;
let pn20 = null;

----  Inicializaciòn de valores para tabla br_pa
let papa = " ";
let pa00 = " ";
let pa01 = " ";
let pa02 = " ";
let pa03 = " ";
let pa04 = " ";
let pa05 = " ";
let pa06 = null;
let pa07 = " ";
let pa08 = " ";
let pa09 = " ";
let pa10 = " ";
let pa11 = " ";
let pa12 = null;

----  Inicializaciòn de valores para tabla br_pe
let pepe = " ";
let pe00 = " ";
let pe01 = " ";
let pe02 = " ";
let pe03 = " ";
let pe04 = " ";
let pe05 = " ";
let pe06 = " ";
let pe07 = " ";
let pe08 = " ";
let pe09 = " ";
let pe10 = " ";
let pe11 = null;
let pe12 = " ";
let pe13 = 0;
let pe14 = " ";
let pe15 = " ";
let pe16 = null;
let pe17 = null;
let pe18 = null;
let pe19 = " ";

----  Inicializaciòn de valores para tabla br_tl
let tltl = null;
let tl00 = " ";
let tl01 =  " ";
let tl02 =  " ";
let tl03 =  " ";
let tl04 =  " ";
let tl05 =  " ";
let tl06 =  " ";
let tl07 =  " ";
let tl08 =  " ";
let tl09 =  0;
let tl10 =  0;
let tl11 =  " ";
let tl12 =  0;
let tl13 = null;
let tl14 = null;
let tl15 = null;
let tl16 = null;
let tl17 = null;
let tl18 =  " ";
let tl19 = null;
let tl20 =  " ";
let tl21 =  0;
let tl22 =  0;
let tl23 =  0;
let tl24 =  0;
let tl25 =  0;
let tl26 =  " ";
let tl27 =  " ";
let tl28 = null;
let tl29 = null;
let tl30 =  " ";
let tl31 =  0;
let tl32 =  0;
let tl33 =  0;
let tl34 =  0;
let tl35 =  0;
let tl36 =  0;
let tl37 = null;
let tl38 =  " ";
let tl42 = null;

----  Inicializaciòn de valores para tabla br_iq
let iqiq = null;
let iq00 = " ";
let iq01 = " ";
let iq02 = " ";
let iq03 = " ";
let iq04 = " ";
let iq05 = " ";
let iq06 = 0;
let iq07 = " ";
let iq08 = " ";
let iq09 = " ";

----  Inicializaciòn de valores para tabla br_rs
let rsrs = null;
let rs00 = 0;
let rs01 = 0;
let rs02 = 0;
let rs03 = 0;
let rs04 = 0;
let rs05 = 0;
let rs06 = 0;
let rs07 = 0;
let rs08 = 0;
let rs09 = 0;
let rs10 = 0;
let rs11 = 0;
let rs12 = 0;
let rs13 = 0;
let rs14 = 0;
let rs15 = 0;
let rs16 = 0;
let rs17 = " ";
let rs18 = " ";
let rs19 = " ";
let rs20 = " ";
let rs21 = 0;
let rs22 = 0;
let rs23 = 0;
let rs24 = 0;
let rs25 = 0;
let rs26 = 0;
let rs27 = 0;
let rs28 = 0;
let rs29 = 0;
let rs30 = 0;
let rs31 = 0;
let rs32 = 0;
let rs33 = 0;
let rs34 = null;
let rs35 = null;
let rs36 = 0;
let rs37 = null;
let rs38 = 0;
let rs39 = null;
let rs40 = 0;
let rs41 = null;

----  Inicializaciòn de valores para tabla br_hi
let hihi = null;
let hi00 = " ";
let hi01 = " ";
let hi02 = " ";

----  Inicializaciòn de valores para tabla br_hr
let hrhr = null;
let hr00 = " ";
let hr01 = " ";
let hr02 = " ";

----  Inicializaciòn de valores para tabla br_cr
let crcr =  " ";
let cr00 = " ";

----  Inicializaciòn de valores para tabla br_sc
let scsc = " ";
let sc00 = " ";
let sc01 = " ";
let sc02 = " ";
let sc03 = " ";
let sc04 = " ";
let sc06 = " ";

--- Inicializaciòn de variables complementarias
let paso = " ";
let etiqueta = " ";
let fecha = " ";
let pnum_cliente = "";
let item_cadena = "";


BEGIN

ON EXCEPTION SET sql_err
   if sql_err <> 0 then
      --ROLLBACK WORK;
       --- Borrado e insersion de error por registro, para no generar registros inecesarios
      insert into br_cadena_error values (pnum_cliente,fecha, sql_err,paso,item_cadena,substr(pcadena,1,item_cadena + 10),vfecha_hoy);
      RETURN ;
   end if
END EXCEPTION;

-- Valida si la cadena viene nulla regresa datos insuficientes
if Trim(pcadena) = "" or pcadena is null then
   LET cod_ret = "110";
   RETURN ;
end if

---Obtencion Nuero de cliente

let paso ="numcte";

select numcte into pnum_cliente from bdisolic:ss_solicitudes
where num_solicitud = pnum_solicitud;

--- Obtencion de fecha
let paso = "Fecha";

select fecha_hoy   into fecha from bdicred:sd_fechas;

--- Verificacion de existencia de cliente
let paso = "Existe";

-- Inicializacion Par empezar a trabajar
let inicio = 50;
let  item_cadena = inicio;
let  etiqueta_size = 4;
let  longitud_etiqueta = etiqueta_size;
--  Si Hubo Error el el Mensaje Regresa 110
let verrorburo = substr(pcadena,1,8);
if verrorburo = "ERRRUR25" then
   LET cod_ret = "111";
   RETURN ;
end if

let etiqueta = substr(pcadena,item_cadena,longitud_etiqueta);
let item_cadena = item_cadena + longitud_etiqueta;
let item_valor = item_cadena;
let longitud_etiqueta = substr(etiqueta,3,2);
let item_cadena = item_cadena + longitud_etiqueta;
let continua = 0;
let bandera = 0;
let tamafin = 0;
let regre = 0;
let entro = "N";
while  (substr(etiqueta,1,2)  != "PA" and substr(etiqueta,1,2)  != "PE"
    and substr(etiqueta,1,2)  != "TL" and substr(etiqueta,1,2)  != "IQ"
    and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
    and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
    and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES")

   let paso = "PN";
let entro = "S";

   let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
 if (substr(etiqueta,1,2) = "PN") then let pnpn = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let pn00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pn01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pn02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pn03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pn04 = valor_cadena;
       if (pn04 = "00000000")  then let pn04 = null;  end if;
       let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pn05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pn06 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pn07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pn08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pn09 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pn10 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pn11 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pn12 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let pn13 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let pn14 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let pn15 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let pn16 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let pn17 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let pn18 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let pn19 = valor_cadena;
      if (pn19 = "00000000")  then let pn19 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let pn20 = valor_cadena;
      if (pn20 = "00000000")  then let pn20 = null;  end if;
      let bandera = 1;
   end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
end while;

if (bandera <> 0)
then
  insert into  br_pn  values(pnum_cliente,fecha,pnpn,pn00,pn01,pn02,pn03,to_date(pn04,"%d%m%Y"),
  pn05,pn06,pn07,pn08,pn09,pn10,pn11,pn12,pn13,pn14,pn15,pn16,pn17,pn18,
  to_date(pn19,"%d%m%Y"),to_date(pn20,"%d%m%Y"));
let continua = 1;

end if;

let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
while  (substr(etiqueta,1,2)  != "PE" and continua <> 0
        and substr(etiqueta,1,2)  != "TL" and substr(etiqueta,1,2)  != "IQ"
        and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
        and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
        and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
        and substr(etiqueta,1,2)  != "PN"
        )
       let regre = 0;
let entro = "S" ;
       let paso = "PA";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "PA") then let respalda_papa = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "PA") then let papa = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let pa00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pa01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pa02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pa03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pa04 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pa05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pa06 = valor_cadena;
       if (pa06 = "00000000")  then let pa06 = null;  end if;
       let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pa07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pa08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pa09 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pa10 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pa11 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pa12 = valor_cadena;
      if (pa12 = "00000000")  then let pa12 = null;  end if;
      let bandera = 1;
 end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
   let pa06 = pa06;

            if ( substr(etiqueta,1,2) = "PA" )
          then

                insert into  br_pa  values (pnum_cliente,respalda_papa,pa00,pa01,pa02,pa03,pa04,pa05,to_date(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,to_date(pa12,"%d%m%Y"),vfecha_hoy);
	let pa00 = " ";
	let pa01 = " ";
	let pa02 = " ";
	let pa03 = " ";
	let pa04 = " ";
	let pa05 = " ";
	let pa06 = null;
	let pa07 = " ";
	let pa08 = " ";
	let pa09 = " ";
	let pa10 = " ";
	let pa11 = " ";
	let pa12 = null;
                let valor_cadena = null;
            end if;


end while;

if (bandera <> 0)
then
  insert into  br_pa  values (pnum_cliente,papa,pa00,pa01,pa02,pa03,pa04,pa05,
  to_date(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,to_date(pa12,"%d%m%Y"),vfecha_hoy);
  let  nrows = dbinfo("sqlca.sqlerrd2");
  let  nrows = nrows;

end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "TL"  and continua <> 0
       and substr(etiqueta,1,2)  != "IQ" and substr(etiqueta,1,2)  != "PA"
       and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
       and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
       and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
       and substr(etiqueta,1,2)  != "PN")
       let regre =0;
         let entro = "S";
       let paso = "PE";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "PE") then let respalda_pepe = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "PE") then let pepe = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let pe00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pe01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pe02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pe03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pe04 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pe05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pe06 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pe07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pe08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pe09 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pe10 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pe11 = valor_cadena;
      if (pe11 = "00000000")  then let pe11 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pe12 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let pe13 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let pe14 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let pe15 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let pe16 = valor_cadena;
      if (pe16 = "00000000")  then let pe16 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let pe17 = valor_cadena;
      if (pe17 = "00000000")  then let pe17 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let pe18 = valor_cadena;
      if (pe18 = "00000000")  then let pe18 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let pe19 = valor_cadena;
      let bandera = 1;
 end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + etiqueta_size;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "PE" )
          then
                insert into  br_pe values (pnum_cliente,respalda_pepe,pe00,pe01,pa02,pe03,pe04,pe05,
                pe06,pe07,pe08,pe09,pe10,to_date(pe11,"%d%m%Y"),pe12,num_valor(pe13),
                pe14,pe15,to_date(pe16,"%d%m%Y"),to_date(pe17,"%d%m%Y"),to_date(pe18,"%d%m%Y"),pe19,vfecha_hoy);
	let pe00 = " ";
	let pe01 = " ";
	let pe02 = " ";
	let pe03 = " ";
	let pe04 = " ";
	let pe05 = " ";
	let pe06 = " ";
	let pe07 = " ";
	let pe08 = " ";
	let pe09 = " ";
	let pe10 = " ";
	let pe11 = null;
	let pe12 = " ";
  	let pe13 = 0;
	let pe14 = " ";
	let pe15 = " ";
	let pe16 = null;
	let pe17 = null;
	let pe18 = null;
	let pe19 = " ";
                let valor_cadena = null;
            end if;
end while;

if (bandera <> 0)
then
insert into  br_pe values (pnum_cliente,pepe,pe00,pe01,pa02,pe03,pe04,pe05,pe06,pe07,pe08,pe09,pe10,
to_date(pe11,"%d%m%Y"),pe12,pe13,pe14,pe15,to_date(pe16,"%d%m%Y"),to_date(pe17,"%d%m%Y"),
to_date(pe18,"%d%m%Y"),pe19,vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro ="N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0 ;
while  (substr(etiqueta,1,2)  != "IQ" and continua<> 0
        and substr(etiqueta,1,2)  != "PA" and substr(etiqueta,1,2)  != "PE"
        and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
        and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
        and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
        and substr(etiqueta,1,2)  != "PN")
let entro = "S";
let regre = 0;
       let bandera = 0;
       let paso = "TL";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "TL") then let respalda_tltl = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "TL") then let tltl = valor_cadena;
    if (tltl = "00000000")  then let tltl = null;  end if;
    let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let tl00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let tl01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let tl02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let tl03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let tl04 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let tl05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let tl06 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let tl07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let tl08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let tl09 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let tl10 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let tl11 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let tl12 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let tl13 = valor_cadena;
      if (tl13 = "00000000")  then let tl13 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let tl14 = valor_cadena;
      if (tl14 = "00000000")  then let tl14 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let tl15 = valor_cadena;
      if (tl15 = "00000000")  then let tl15 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let tl16 = valor_cadena;
      if (tl16 = "00000000")  then let tl16 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let tl17 = valor_cadena;
      if (tl17 = "00000000")  then let tl17 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let tl18 = valor_cadena;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let tl19 = valor_cadena;
      if (tl19 = "00000000")  then let tl19 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let tl20 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "21")  then let tl21 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "22")  then let tl22 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "23")  then let tl23 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "24")  then let tl24 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "25")  then let tl25 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "26")  then let tl26 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "27")  then let tl27 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "28")  then let tl28 = valor_cadena; if (tl28 = "00000000")  then let tl28 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "29")  then let tl29 = valor_cadena; if (tl29 = "00000000")  then let tl29 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "30")  then let tl30 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "31")  then let tl31 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "32")  then let tl32 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "33")  then let tl33 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "34")  then let tl34 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "35")  then let tl35 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "36")  then let tl36 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "37")  then let tl37 = valor_cadena; if (tl37 = "00000000")  then let tl37 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "38")  then let tl38 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "42")  then let tl42 = valor_cadena; if (tl42 = "00000000")  then let tl42 = null;  end if; let bandera = 1;
 end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "TL" )
          then

                insert into  br_tl values(pnum_cliente,to_date(respalda_tltl,"%d%m%Y"),tl00,tl01,tl02,
                tl03,tl04,tl05,tl06,tl07,tl08,num_valor(tl09),num_valor(tl10),tl11,num_valor(tl12),
                to_date(tl13,"%d%m%Y"),to_date(tl14,"%d%m%Y"),to_date(tl15,"%d%m%Y"),
                to_date(tl16,"%d%m%Y"),to_date(tl17,"%d%m%Y"),tl18,to_date(tl19,"%d%m%Y"),
                tl20,num_valor(tl21),num_valor(tl22),num_valor(tl23),num_valor(tl24),num_valor(tl25),tl26,tl27,
                to_date(tl28,"%d%m%Y"),to_date(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),
                num_valor(tl33),num_valor(tl34),num_valor(tl35),
                num_valor(tl36),to_date(tl37,"%d%m%Y"),tl38,to_date(tl42,"%d%m%Y"),vfecha_hoy);

	let tl00 = " ";
	let tl01 =  " ";
	let tl02 =  " ";
	let tl03 =  " ";
	let tl04 =  " ";
	let tl05 =  " ";
	let tl06 =  " ";
	let tl07 =  " ";
	let tl08 =  " ";
	let tl09 =  0;
	let tl10 =  0;
	let tl11 =  " ";
	let tl12 =  0;
	let tl13 = null;
	let tl14 = null;
	let tl15 = null;
	let tl16 = null;
	let tl17 = null;
	let tl18 =  " ";
	let tl19 = null;
	let tl20 =  " ";
	let tl21 =  0;
	let tl22 =  0;
	let tl23 =  0;
	let tl24 =  0;
	let tl25 =  0;
	let tl26 =  " ";
	let tl27 =  " ";
	let tl28 = null;
	let tl29 = null;
	let tl30 =  " ";
	let tl31 =  0;
	let tl32 =  0;
	let tl33 =  0;
	let tl34 =  0;
	let tl35 =  0;
	let tl36 =  0;
	let tl37 = null;
	let tl38 =  " ";
	let tl42 = null;
                let valor_cadena = null;
            end if;


end while;

if (bandera <> 0)
then
insert into  br_tl values  (pnum_cliente,to_date(tltl,"%d%m%Y"),tl00,tl01,tl02,tl03,tl04,tl05,tl06,tl07,tl08,tl09,
                           num_valor(tl10),tl11,num_valor(tl12),to_date(tl13,"%d%m%Y"),to_date(tl14,"%d%m%Y"),
  		           to_date(tl15,"%d%m%Y"),to_date(tl16,"%d%m%Y"),to_date(tl17,"%d%m%Y"),tl18,
  		           to_date(tl19,"%d%m%Y"),tl20,num_valor(tl21),num_valor(tl22),tl23,tl24,tl25,tl26,tl27,
 		           to_date(tl28,"%d%m%Y"),to_date(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),
 		           num_valor(tl33),num_valor(tl34),num_valor(tl35),num_valor(tl36),to_date(tl37,"%d%m%Y"),
                           tl38,to_date(tl42,"%d%m%Y"),vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HI"
    and substr(etiqueta,1,2)  != "HR" and substr(etiqueta,1,2)  != "HI"
    and substr(etiqueta,1,2)  != "CR" and substr(etiqueta,1,2)  != "SC"
    and substr(etiqueta,1,2)  != "ES"  and continua <> 0)
let regre = 0;
let entro = "S";
       let paso = "IQ";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);


if (substr(etiqueta,1,2) = "IQ") then let respalda_iqiq = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "IQ") then let iqiq = valor_cadena; if (iqiq = "00000000")  then let iqiq = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let iq00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let iq01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let iq02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let iq03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let iq04 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let iq05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let iq06 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let iq07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let iq08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let iq09 = valor_cadena; let bandera = 1;
 end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = etiqueta_size + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

          if ( substr(etiqueta,1,2) = "IQ" )
          then

                insert into  br_iq  values (pnum_cliente,to_date(respalda_iqiq,"%d%m%Y"),
                iq00,iq01,iq02,iq03,iq04,iq05,num_valor(iq06),iq07,iq08,iq09,vfecha_hoy);
	let iq00 = " ";
	let iq01 = " ";
	let iq02 = " ";
	let iq03 = " ";
	let iq04 = " ";
	let iq05 = " ";
	let iq06 = 0;
	let iq07 = " ";
	let iq08 = " ";
	let iq09 = " ";
                let valor_cadena =  null;
          end if;


end while;

if ( bandera <> 0)
then
insert into  br_iq  values (pnum_cliente,to_date(iqiq,"%d%m%Y"),iq00,iq01,iq02,iq03,iq04,iq05,
num_valor(iq06),iq07,iq08,iq09,vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "HI"  and  substr(etiqueta,1,2)  != "HR"   and substr(etiqueta,1,2)  != "CR" and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES" and continua <> 0)
       let paso = "RS";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
let regre = 0;

 if (substr(etiqueta,1,2) = "RS") then let respalda_rsrs = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "RS") then let rsrs = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let rs00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let rs01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let rs02 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let rs03 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let rs04 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let rs05 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let rs06 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let rs07 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let rs08 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let rs09 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let rs10 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let rs11 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let rs12 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let rs13 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let rs14 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let rs15 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let rs16 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let rs17 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let rs18 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let rs19 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let rs20 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "21")  then let rs21 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "22")  then let rs22 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "23")  then let rs23 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "24")  then let rs24 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "25")  then let rs25 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "26")  then let rs26 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "27")  then let rs27 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "28")  then let rs28 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "29")  then let rs29 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "30")  then let rs30 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "31")  then let rs31 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "32")  then let rs32 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "33")  then let rs33 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "34")  then let rs34 = valor_cadena; if (rs34 = "00000000")  then let rs34 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "35")  then let rs35 = valor_cadena; if (rs35 = "00000000")  then let rs35 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "36")  then let rs36 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "37")  then let rs37 = valor_cadena; if (rs37 = "00000000")  then let rs37 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "38")  then let rs38 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "39")  then let rs39 = valor_cadena; if (rs39 = "00000000")  then let rs39 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "40")  then let rs40 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "41")  then let rs41= valor_cadena;  if (rs41 = "00000000")  then let rs41 = null;  end if; let bandera = 1;
 end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = etiqueta_size + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "RS" )
          then

                insert into  br_rs values (pnum_cliente,to_date(respalda_rsrs,"%d%m%Y") ,num_valor(rs00) ,
                num_valor(rs01) ,num_valor(rs02),num_valor(rs03) ,num_valor(rs04) , num_valor(rs05) ,
                num_valor(rs06) , num_valor(rs07) , num_valor(rs08) , num_valor(rs09) , num_valor(rs10) ,
                num_valor(rs11) , num_valor(rs12) , num_valor(rs13) , num_valor(rs14) , num_valor(rs15) ,
                num_valor(rs16) ,rs17 , rs18 , rs19 , rs20 , num_valor(rs21) , num_valor(rs22) ,
                num_valor(rs23) , num_valor(rs24) , num_valor(rs25) , num_valor(rs26) ,
                num_valor(rs27) , num_valor(rs28) , num_valor(rs29) , num_valor(rs30) , num_valor(rs31) ,
                num_valor(rs32) , num_valor(rs33) , to_date(rs34,"%d%m%Y")  , to_date(rs35,"%d%m%Y")  ,
                num_valor(rs36) , to_date(rs37,"%d%m%Y")  , num_valor(rs38) , to_date(rs39 ,"%d%m%Y") ,
                num_valor(rs40) , to_date(rs41,"%d%m%Y"),vfecha_hoy  );

               {let rs00 = 0;
	let rs01 = 0;
	let rs02 = 0;
	let rs03 = 0;
	let rs04 = 0;
	let rs05 = 0;
	let rs06 = 0;
	let rs07 = 0;
	let rs08 = 0;
	let rs09 = 0;  Cuando a parece mas de una vez solo se presentan los datos del 20 al 30
	let rs10 = 0;
	let rs11 = 0;
	let rs12 = 0;
	let rs13 = 0;
	let rs14 = 0;
	let rs15 = 0;
	let rs16 = 0;
	let rs17 = " ";
	let rs18 = " ";
	let rs19 = " "; }
	let rs20 = " ";
	let rs21 = 0;
	let rs22 = 0;
	let rs23 = 0;
	let rs24 = 0;
	let rs25 = 0;
	let rs26 = 0;
	let rs27 = 0;
	let rs28 = 0;
	let rs29 = 0;
                let rs30 = 0;
               {let rs31 = 0;
	let rs32 = 0;
	let rs33 = 0;
	let rs34 = null;
	let rs35 = null;
	let rs36 = 0;
	let rs37 = null;  Cuando a parece mas de una vez solo se presentan los datos del 20 al 30
	let rs38 = 0;
	let rs39 = null;
	let rs40 = 0;
	let rs41 = null; }
                let valor_cadena = null;
            end if;


end while;


if (bandera <> 0)
then
insert into  br_rs values (pnum_cliente,to_date(rsrs,"%d%m%Y") , num_valor(rs00) , num_valor(rs01) ,
num_valor(rs02) , num_valor(rs03) , num_valor(rs04) , num_valor(rs05) , num_valor(rs06) , num_valor(rs07) ,
num_valor(rs08) , num_valor(rs09) , num_valor(rs10) , num_valor(rs11) , num_valor(rs12) , num_valor(rs13) ,
num_valor(rs14) , num_valor(rs15) , num_valor(rs16) , rs17 , rs18 , rs19 , rs20 , num_valor(rs21) ,
num_valor(rs22) , num_valor(rs23) , num_valor(rs24) , num_valor(rs25) , num_valor(rs26) , num_valor(rs27) ,
num_valor(rs28) , num_valor(rs29) , num_valor(rs30) , num_valor(rs31) , num_valor(rs32) , num_valor(rs33) ,
to_date(rs34,"%d%m%Y")  , to_date(rs35,"%d%m%Y")  ,   num_valor(rs36) , to_date(rs37,"%d%m%Y")  ,
num_valor(rs38) , to_date(rs39 ,"%d%m%Y") , num_valor(rs40) , to_date(rs41,"%d%m%Y"), vfecha_hoy  );
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "HR" and substr(etiqueta,1,2)  != "CR"
    and substr(etiqueta,1,2)  != "SC"  and substr(etiqueta,1,2)  != "ES"
    and continua <> 0  )
let regre = 0;
let entro = "S";
       let paso = "HI";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "HI") then let respalda_hihi = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "HI") then let hihi = valor_cadena; if (hihi = "00000000")  then let hihi = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let hi00 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let hi01 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let hi02 = valor_cadena;  let bandera = 1;
 end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let item_cadena = item_cadena + longitud_etiqueta;
   let regre = etiqueta_size + longitud_etiqueta;
            if ( substr(etiqueta,1,2) = "HI" )
          then

                insert into  br_hi  values (pnum_cliente,to_date(respalda_hihi,"%d%m%Y") ,hi00,hi01,hi02,vfecha_hoy);
	let hi00 = " ";
	let hi01 = " ";
	let hi02 = " ";
	let valor_cadena = null;
            end if;

end while;

if ( bandera <> 0)
then
insert into  br_hi  values (pnum_cliente,to_date(hihi,"%d%m%Y") ,hi00,hi01,hi02,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "CR"  and substr(etiqueta,1,2)  != "SC"  and substr(etiqueta,1,2)  != "ES" and continua <> 0 )

       let paso = "HR";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "HR") then let respalda_hrhr = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "HR") then let hrhr = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let hr00 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let hr01 = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let hr02 = valor_cadena; let bandera = 1;
 end if;



   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let item_cadena = item_cadena + longitud_etiqueta;
   let regre = etiqueta_size + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "HR" )
          then
                insert into  br_hr  values (pnum_cliente,to_date(respalda_hrhr,"%d%m%Y") ,hr00,hr01,hr02,vfecha_hoy);
	let hr00 = " ";
	let hr01 = " ";
	let hr02 = " ";
	let valor_cadena = null;
            end if;


end while;

if (bandera <> 0)
then insert into  br_hr  values (pnum_cliente,to_date(hrhr,"%d%m%Y") ,hr00,hr01,hr02,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "SC"  and substr(etiqueta,1,2)  != "ES"  and continua <> 0)

let regre = 0;
       let paso = "CR";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

 if (substr(etiqueta,1,2) = "CR") then let crcr = valor_cadena;  end if; let bandera = 1;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let item_cadena = item_cadena + longitud_etiqueta;
   let regre = etiqueta_size + longitud_etiqueta;
            if ( etiqueta = "0000" )
            then
              for i = 1    to 2000 step 1
                let salva = substr(pcadena, item_valor + i - 1 ,4);
                   if (salva = "SC08" or salva = "ES05")
                   then
                        let longitud_etiqueta =  (i - 1);
                        EXIT FOR;
                   end if;
                end for;
               let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
               if (substr(etiqueta,1,2) = "00")  then let cr00 = valor_cadena; end if; let bandera = 1;
               let item_cadena = item_cadena + longitud_etiqueta;
               let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
               let item_cadena = item_cadena + etiqueta_size;
               let item_valor = item_cadena;
               let longitud_etiqueta = substr(etiqueta,3,2);
               let regre = etiqueta_size + longitud_etiqueta;
               let item_cadena = item_cadena + longitud_etiqueta;
               EXIT WHILE;
            end if;

end while;

if (bandera <> 0)
then insert into  br_cr  values (pnum_cliente,crcr,cr00,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (etiqueta  != "ES05"  and continua <> 0 )
       let paso = "SC";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
let regre = 0;
let entro = "S";

 if (substr(etiqueta,1,2) = "SC") then let respalda_scsc = valor_cadena; end if;

 if (substr(etiqueta,1,2) = "SC") then let scsc = valor_cadena; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let sc00 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let sc01 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let sc02 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let sc03 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let sc04 = valor_cadena;  let bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let sc06 = valor_cadena;  let bandera = 1;
 end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let item_cadena = item_cadena + longitud_etiqueta;
   let regre = etiqueta_size + longitud_etiqueta;
            if ( substr(etiqueta,1,2) = "SC" )
          then

                insert into  br_sc  values (pnum_cliente,respalda_scsc,sc00,sc01,sc02,sc03,sc04,sc06,vfecha_hoy);
	let sc00 = " ";
	let sc01 = " ";
	let sc02 = " ";
	let sc03 = " ";
	let sc04 = " ";
	let sc06 = " ";
	let valor_cadena = null;
            end if;


end while;

if (bandera <>0)
then  insert into  br_sc  values (pnum_cliente,scsc,sc00,sc01,sc02,sc03,sc04,sc06,vfecha_hoy);
end if;

if (substr(etiqueta,1,2) = "ES" and  substr(pcadena, item_valor + 22, 2) = "**" and continua <> 0)
then
   let cod_ret = "000";
   let paso = "0000";
else
  let cod_ret = "111";
  let paso = "PNES";
  insert into br_cadena_error values (pnum_cliente,fecha, "SIN PN/ES", " ",0,substr(pcadena,1,item_cadena + 10),vfecha_hoy);
end if;
call bdisolic:califica_scoring2("001", pnum_solicitud)
returning cod_ret;
return  ;
END;
end procedure;