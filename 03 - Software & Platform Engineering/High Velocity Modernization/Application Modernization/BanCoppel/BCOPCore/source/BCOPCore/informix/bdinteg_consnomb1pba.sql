create procedure "informix".consnomb1pba(pempresa char(3),
                          ppaterno char(26),
                          pmaterno char(26),
	                  prazon char(60),
                          pno_rfc char(13),
                          psecuencia smallint)
	returning char(5),char(60),char(20),char(13);

define sql_err integer;
define v_longitud,v_ciclo smallint;
define v_nombre_completo char(63);
define v_nombre1,v_nombre2,v_paterno,v_materno char(26);
define v_numcte char(20);
define v_cod_ret char(5);
define v_razon_soc char(60);
define v_rfc char(13);

--set debug file to "consnomb1.out";
--trace on;

let v_cod_ret="00000";
let v_ciclo=0;
let v_nombre_completo=" ";
let v_numcte="0000000000";
let v_rfc = "";

begin
   on exception set sql_err
      if sql_err <> 0 then
   	 let v_cod_ret = sql_err;
	 return v_cod_ret,v_nombre_completo,v_numcte,v_rfc;
      end if;
   end exception;

--set debug file to "consnomb.out";
--trace on;

if prazon is not null and prazon !="" then
   foreach
      select razon_social,numcte,rfc
 	 into v_razon_soc,v_numcte,v_rfc
      	 from si_cliente
      	 where razon_social = prazon
      	 order by numcte
      let v_ciclo = v_ciclo+1;
      if v_ciclo <= psecuencia then
 	 continue foreach;
      end if
      let v_nombre_completo = v_razon_soc;
      return v_cod_ret,v_nombre_completo,v_numcte,v_rfc with resume;
   end foreach;
else
   if pno_rfc is not null and pno_rfc != "" then
      foreach
         select nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc
	    into v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
      	    from si_ctepf pf, si_cliente cl
      	    where rfc = pno_rfc and cl.numcte = pf.numcte
      	    order by pf.numcte
      	 let v_ciclo = v_ciclo+1;
      	 if v_ciclo <= psecuencia then
	    continue foreach;
      	 end if
	 let v_nombre_completo = trim(v_paterno) || " " || trim(v_materno)
             || " " || trim(v_nombre1) || " " || trim(v_nombre2);
	 return v_cod_ret,v_nombre_completo,v_numcte,v_rfc with resume;
      end foreach;
   else
      if ppaterno is null or ppaterno="" then
 	 let v_cod_ret = "110";
 	 return v_cod_ret,v_nombre_completo,v_numcte,v_rfc;
      else
         let ppaterno = trim(ppaterno)||"*";
         let pmaterno = trim(pmaterno)||"*";
         foreach
	    select nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
	       into v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
      	       from si_cliente
      	       where apell_paterno matches ppaterno
		     and apell_materno matches pmaterno
      	       order by numcte
      	    let v_ciclo = v_ciclo+1;
      	    if v_ciclo <= psecuencia then
	       continue foreach;
      	    end if
	    let v_nombre_completo = trim(v_paterno) || " " || trim(v_materno)
                || " " || trim(v_nombre1) || " " || trim(v_nombre2);
	    return v_cod_ret,v_nombre_completo,v_numcte,v_rfc with resume;
	 end foreach;
      end if;
   end if;
end if;
end
end procedure
DOCUMENT
"MODIFICO : Mario Escobar",
"FECHA : 13/Junio/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obt_cve_banco(pCveBanco char(3))
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener clave de 5 digitos de banco
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 18/03/2009

       DEFINE vcodret   char(5);
       DEFINE vCvecesif  integer;
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCvecesif;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vCvecesif = 0;

BEGIN

		SELECT cvecesif INTO vCvecesif FROM bdinteg:si_bancos WHERE banco = pCveBanco ;
        IF vCvecesif IS NULL THEN
			LET vCvecesif = 0;
        END IF;

		RETURN vcodret, vCvecesif;
END;

END PROCEDURE;