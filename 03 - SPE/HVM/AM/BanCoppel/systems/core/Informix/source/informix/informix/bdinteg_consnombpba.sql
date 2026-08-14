create procedure "informix".consnombpba(pempresa char(3),
                          ppaterno char(26), 
                          pmaterno char(26), 
	                  prazon char(60), 
                          psecuencia smallint) 
	returning char(5), char(63), char(20);

define sql_err integer;
define v_longitud, v_conta, v_ciclo smallint;
define v_nombre_completo char(63);
define v_nombre1, v_nombre2, v_paterno, v_materno char(15);
define v_numcte char(20);
define v_cod_ret char(5);
define v_razon_soc char(40);

let v_conta=0;
let v_cod_ret="00000";
let v_ciclo=0;
let v_nombre_completo=" ";
let v_numcte="0000000000";


begin
	on exception set sql_err
	 	if sql_err <> 0 then
	    		let v_cod_ret = sql_err;
			return v_cod_ret, v_nombre_completo, v_numcte;
         	end if;
      end exception;


--SET DEBUG FILE TO 'consnomb.out';
--TRACE ON;


if prazon is not null and prazon !="" then

		foreach
			select razon_social, numcte
				into v_razon_soc, v_numcte
      				from si_cliente
      				where razon_social = prazon 
      				--order by numcte
      				let v_ciclo=v_ciclo+1;
      			if v_ciclo<=psecuencia then
	 			continue foreach;
      			end if
				let v_nombre_completo = v_razon_soc;
	
			return v_cod_ret, v_nombre_completo, v_numcte
		with resume;
      			let v_conta=v_conta+1;
		end foreach;
else

	if ppaterno is null or ppaterno="" then
		let v_cod_ret = "110";
		return v_cod_ret, v_nombre_completo, v_numcte;
	else	
           let ppaterno = trim(ppaterno)||"*"; 
           let pmaterno = trim(pmaterno)||"*"; 
		foreach
			select nombre1, nombre2, apell_paterno, apell_materno, 
				numcte
				into v_nombre1, v_nombre2, v_paterno, 
				v_materno, v_numcte
      				from si_cliente
      				where apell_paterno matches ppaterno 
				and apell_materno matches pmaterno
      				--order by numcte
      				let v_ciclo=v_ciclo+1;
      			if v_ciclo<=psecuencia then
	 			continue foreach;
      			end if
				let v_nombre_completo = v_paterno || " " || v_materno || " " || v_nombre1 || " " || v_nombre2;
	
			return v_cod_ret, v_nombre_completo, v_numcte
		with resume;
      			let v_conta=v_conta+1;
		end foreach;
	end if;
end if;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_bloqueausuario_bpi(pEmpresa char(3), pUsuario char(50))
   returning char(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

        UPDATE bdinteg:si_bpiusuarios SET id_status = 40, f_status = current  WHERE usuario = pUsuario;

        LET cod_ret = '000';  -- Usuario bloqueado

   ELSE

        LET cod_ret = '001';  -- No existe el usuario

   END IF ;

   RETURN cod_ret;

END

END PROCEDURE ;