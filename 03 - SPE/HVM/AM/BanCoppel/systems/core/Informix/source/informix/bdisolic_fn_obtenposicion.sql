create function "informix".fn_obtenposicion(pCadena varchar(255,1), pBuscado varchar(255,1), pOcurrencia smallint)
returning integer;
--Elaborado por : Juan A. Coronel
--Fecha: 29-11-2007
--Permite saber la posicion en que se encuentra una cadena dentro de otra, despues de N apariciones (ocurrencia)
--Nota: No puede buscar espacios.
define Posic Integer;
define Veces Integer;
define i     Integer;
define AuxpCadena varchar(255,1);
define AuxpBuscado varchar(255,1);
define x varchar(255,1);

    --Set debug file to '/opt/informix/tmp/credito/coronel/obtenposicion.out';
    --trace on;
Begin
	Let AuxpCadena  = pCadena;
	Let AuxpBuscado = pBuscado;

	Let Posic = 0;
	Let Veces = 0;
	If pOcurrencia < 1 then
		Return Posic;
	End if;
	For i = 1 to length(pCadena)
		let x = length(pCadena);
		let x = length(pBuscado);
		let x = substr(pCadena, i, Length(pBuscado));
		If substr(pCadena, i, Length(pBuscado)) = pBuscado then
			Let Veces = Veces + 1;
		End if;
		If Veces = pOcurrencia then
			Exit for;
		End if;
	End For;
	If Veces = pOcurrencia Then
		Let Posic = i;
	End if;
	Return Posic;
End;
End Function;