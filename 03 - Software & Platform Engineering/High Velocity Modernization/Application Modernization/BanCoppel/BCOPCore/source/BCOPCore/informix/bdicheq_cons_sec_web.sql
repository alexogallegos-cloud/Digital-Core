CREATE PROCEDURE "informix".cons_sec_web(pempresa CHAR(3), pcuenta CHAR(20))
--DATOS A REGRESAR
 Returning
 CHAR(5),
 SMALLINT;

 --DEFINICION DE VARIABLES
 DEFINE vcodret         CHAR(5);
 DEFINE vsiguiente      INTEGER;
 DEFINE vsqlerr         INTEGER;
 DEFINE VexisTar        INTEGER;
 DEFINE vExiste			INTEGER;

 LET vcodret = "00000";
 LET vsiguiente = 0;
 LET vsqlerr = 0;
 LET VexisTar = 0;
 LET vExiste = 0;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;
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

        RETURN vcodret, NVL(vsiguiente,0);

ELSE
        LET Vcodret = "00416";
        LET vsiguiente = "";
        RETURN vcodret, NVL(vsiguiente,0);		
END IF
END PROCEDURE;