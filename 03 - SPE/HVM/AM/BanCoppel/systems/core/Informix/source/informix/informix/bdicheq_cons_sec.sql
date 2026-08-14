CREATE PROCEDURE "informix".cons_sec(pempresa char(3), pcuenta          char(20))
--DATOS A REGRESAR
 Returning
 char(5),
 smallint;
--DEFINICION DE VARIABLES
 define vcodret         char(5);
 define vsiguiente      integer;
 --define vexiste         integer;
 define vsqlerr         integer;
 define VexisTar        integer;
 define vExiste			integer;

 let vcodret = "000";
 let vsiguiente = 0;
 --let vexiste= 0;
 let vsqlerr = 0;
 let VexisTar = 0;
 let vExiste = 0;

---SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ ;

SELECT count(empresa) into vExiste FROM bdicheq:"informix".sc_maechq WHERE cuenta = pcuenta;

IF vExiste > 0 THEN
	
	SELECT count(empresa) into vExiste FROM bdicheq:"informix".sc_firmantes WHERE cuenta = pcuenta;
	
    IF vExiste > 0 THEN

        select max(secuencia) + 1 into vsiguiente
        from bdicheq:"informix".sc_firmantes
        where empresa=pempresa and cuenta=pcuenta;

         if vsiguiente is null then
                let vsiguiente = 1;
        end if;

    ELSE

        let vsiguiente = 1;

    END IF       

        RETURN vcodret, vsiguiente;

ELSE

        LET Vcodret = "416";
        LET vsiguiente = "";
        RETURN vcodret, vsiguiente;
		
END IF
END PROCEDURE;