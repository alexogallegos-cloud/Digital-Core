create function "informix".esnumerocasa(
	pNumCasa char(30)
)
returning integer;

--Elaborado por : Juan A. Coronel
--Fecha: 08-06-2007
--Recibe una cadena, y verifica si su contenido es un numero pósitivo para ser usado como numero exterior de casa.

define cNumCasa char(30);
define i integer;
define iResultado integer;

Begin
    if pNumCasa is null or length(trim(pNumCasa)) = 0  then
	Let iResultado = 0;
    else
	Let iResultado	 = 1;
	Let cNumCasa	 = trim(pNumCasa);
	For i=1 to length(cNumCasa) 
		if substr(cNumCasa, i, 1) not in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then
			Let iResultado = 0;
			Exit For;
		end if;
	End For;
    end if;
    return iResultado;
End;

End function;