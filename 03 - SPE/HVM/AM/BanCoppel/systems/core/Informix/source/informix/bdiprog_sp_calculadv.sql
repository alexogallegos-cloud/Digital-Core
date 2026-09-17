CREATE PROCEDURE "informix".sp_calculadv
					(
					cNumTelefono 	CHAR(10)	-->Referencia Telmex
					)
RETURNING CHAR(5),-->Codigo de Retorno
	  INTEGER ;   -->Dígito verificador

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE iDigver		INTEGER;
DEFINE icontador		INTEGER;

LET vcodret = "000";
LET iDigver = 0;

-- SET DEBUG FILE TO "/home/informix/sp_digver.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          iDigver;	--> Fecha de Ultimo Pago
	END EXCEPTION;


	let iContador = substr(cNumTelefono,1,1) * 1;
	let iContador = iContador + substr(cNumTelefono,2,1) * 3;
	let iContador = iContador + substr(cNumTelefono,3,1) * 7;
	let iContador = iContador + substr(cNumTelefono,4,1) * 1;
	let iContador = iContador + substr(cNumTelefono,5,1) * 3;
	let iContador = iContador + substr(cNumTelefono,6,1) * 7;
	let iContador = iContador + substr(cNumTelefono,7,1) * 1;
	let iContador = iContador + substr(cNumTelefono,8,1) * 3;
	let iContador = iContador + substr(cNumTelefono,9,1) * 7;
	let iContador = iContador + substr(cNumTelefono,10,1) * 1;
	let iContador = iContador + 49;
	let iContador = mod(iContador, 9);

	let iDigver = iContador + 1;


    RETURN vcodret, iDigver;

END
END PROCEDURE;