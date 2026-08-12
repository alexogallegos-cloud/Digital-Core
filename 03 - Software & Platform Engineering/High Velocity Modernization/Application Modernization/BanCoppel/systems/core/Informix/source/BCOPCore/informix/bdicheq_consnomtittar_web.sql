CREATE PROCEDURE "informix".consnomtittar_web(pEmpresa CHAR(3), pTarjeta CHAR(20))

--DATOS A REGRESAR---
RETURNING

char(5), --Codigo de Retorno 
char(20), --Numero Cliente
char(20), --Numero Cuenta
char(26), --Apellido Paterno
char(26), --Apellido Materno
char(26), --Nombre1
char(26), --Nombre2
char(13),  --RFC
CHAR(4);  -- Numero de Producto

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         char(5);
DEFINE Vnumcte          char(20);
DEFINE Vnumcta          char(20);
DEFINE VaPaterno        char(26);
DEFINE vaMaterno        char(26);
DEFINE vNombre1         char(26);
DEFINE VNombre2         char(26);
DEFINE Vrfc             char(13);
DEFINE vCantReg         smallint;
DEFINE vNumProd         CHAR(4);
DEFINE vValProd         CHAR(4);
DEFINE cProducto        CHAR(100);
DEFINE cProductoTarjeta CHAR(4);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret 	= "00000";
LET Vnumcte		= "";
LET Vnumcta		= "";
LET VaPaterno 	= "";
LET vaMaterno 	= "";
LET vNombre1	= "";
LET VNombre2 	= "";
LET Vrfc 		= "";
LET vCantReg 	= 0;
LET vValProd   	= "";
LET vNumProd    ="";
LET cProducto   = '';
LET cProductoTarjeta = '';

--SET DEBUG FILE TO '/home/tmp/leonardo/consnomtittar.out';
--TRACE ON;
	
	-- Se agrega para evitar bloqueo 17/01/2012
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
		SELECT TRIM(valor)
		INTO cProducto
		FROM bditransfer:"informix".tf_param 
		WHERE empresa = pEmpresa
        AND cod_param = '4';
		
		SELECT prodtarjeta
		INTO cProductoTarjeta
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = pEmpresa
		AND num_tarjeta = pTarjeta
		AND prodtarjeta = cProducto;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		
			SELECT
				b.num_cte, a.cuenta, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, c.rfc,
				b.producto 
			INTO
				Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vNumProd 
			FROM
				bdicheq:sc_tarjeta a, bdicheq:sc_maechq b, bdinteg:si_cliente c
			WHERE
				a.empresa = pEmpresa and a.num_tarjeta = pTarjeta and a.cuenta = b.cuenta and b.num_cte = c.numcte ; 
				
			if Vnumcte <> "" and Vnumcta <> ""  and Vrfc <> "" then
			   let vCantReg = vCantReg +1;
					
			   SELECT
					   valor 
			   INTO
					   vValProd 
			   FROM
					   bditarjeta:td_producto_emp
			   WHERE
					   codigo = vNumProd; 
				
			   IF vValProd IS NULL OR Trim(vValProd) = "" THEN
					LET vValProd = "00501";
			   END IF

			   RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vValProd ;

			end if

			IF vCantReg = 0 THEN
					LET Vcod_Ret      = "00252";
					LET Vnumcte       = "";
					LET Vnumcta       = "";
					LET VaPaterno     = "";
					LET vaMaterno     = "";
					LET vNombre1      = "";
					LET VNombre2      = "";
					LET vNombre2      = "";
					LET Vrfc          = "";
					LET vNumProd      ="";

					RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vNumProd;
			end if
		ELSE
			LET Vcod_Ret = '00858';
			
			RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vNumProd;
		END IF;
		
END PROCEDURE
DOCUMENT
'Folio: 1611',
'AUTOR :95594213 Leonardo Plata',
'FECHA : 01/07/2014',
'MODIFICACIÃ?N: Se Modifica sp para que en caso de que el producto de la tarjeta sea 8000 retorne codigo de error',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez ',
'BD: bdicheq';

create procedure "informix".cons_prom_web(pempresa char(3),
                                      pcuenta char(20))
  returning char(5),
            money(14,2), money(14,2), money(14,2), money(14,2),
            money(14,2), money(14,2);

  define cod_ret char(5);
  define tfecha,var_fec,tfechar datetime year to month;
  define v_cal_int_chq char(1);
  define vfecha_hoy date;
  define vcuenta, tcuenta, var_cta char(20);
  define vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4, vsdo_prom5,
         vsdo_prom6,tacum_pos money(14,2);
  define sql_err,i integer;
  define tdias_pos smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
  let cod_ret          = "00000";
  let vsdo_prom1       = 0;
  let vsdo_prom2       = 0;
  let vsdo_prom3       = 0;
  let vsdo_prom4       = 0;
  let vsdo_prom5       = 0;
  let vsdo_prom6       = 0;


begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
           vsdo_prom5, vsdo_prom6;
      end if;
   end exception;

-- ****************************************************************************
-- Valida exista la Cuenta de Cheques y extrae informacion necesaria
-- ****************************************************************************
select sc_maechq.cuenta
       into vcuenta
from sc_maechq
where empresa = pempresa and cuenta = pcuenta;

if vcuenta is null then
   let cod_ret = "00100";
   return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
          vsdo_prom5, vsdo_prom6;
end if

 Select fecha_hoy into vfecha_hoy from sc_fechas
    where empresa = pempresa;

let tfecha = vfecha_hoy;
let i = 1;
while i < 7
    let tfecha = tfecha - 1 units month;
    begin
        let tfechar,tacum_pos, tdias_pos = (select fecha,acum_pos,dias_pos
            from sc_salpro
            where empresa = pempresa and cuenta = pcuenta and
                  fecha  = tfecha);
    end
    if tfechar is null then  
       let tacum_pos  = 0;
       let tdias_pos  = 0;
       let tfechar    = " ";
    end if
    if i = 1 then
       if tacum_pos > 0 then
         let vsdo_prom1 = tacum_pos/tdias_pos;
       else
         let vsdo_prom1 = 0;
       end if
    elif i = 2 then
       if tacum_pos > 0 then
         let vsdo_prom2 = tacum_pos/tdias_pos;
       else
         let vsdo_prom2 = 0;
       end if
    elif i = 3 then
       if tacum_pos > 0 then
         let vsdo_prom3 = tacum_pos/tdias_pos;
       else
         let vsdo_prom3 = 0;
       end if
    elif i = 4 then
       if tacum_pos > 0 then
         let vsdo_prom4 = tacum_pos/tdias_pos;
       else
         let vsdo_prom4 = 0;
       end if
    elif i = 5 then
       if tacum_pos > 0 then
         let vsdo_prom5 = tacum_pos/tdias_pos;
       else
         let vsdo_prom5 = 0;
       end if
    elif i = 6 then
       if tacum_pos > 0 then
         let vsdo_prom6 = tacum_pos/tdias_pos;
       else
         let vsdo_prom6 = 0;
       end if
    end if
    let i = i + 1;
    let var_cta = pcuenta;
    let var_fec = tfechar;
end while


-- ****************************************************************************
-- Verifica no enviar nulos como respuesta
-- ****************************************************************************
if vsdo_prom1 is null then
   let vsdo_prom1 = 0;
end if
if vsdo_prom2 is null then
   let vsdo_prom2 = 0;
end if
if vsdo_prom3 is null then
   let vsdo_prom3 = 0;
end if
if vsdo_prom4 is null then
   let vsdo_prom4 = 0;
end if
if vsdo_prom5 is null then
   let vsdo_prom5 = 0;
end if
if vsdo_prom6 is null then
   let vsdo_prom6 = 0;
end if
return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
       vsdo_prom5, vsdo_prom6;

end
end procedure;