create function "informix".anioscumplidos(pFechaMayor date, pFechaMenor date)
returning integer;
--11-12-2007
--Juan Andrés Coronel M
--Funcion para calcular los años cumplidos exactos entre 2 fechas

define anios integer;
define diferencial decimal(14,2);

Begin
    Let Diferencial = 0;
    If day(pFechaMayor) = day(pFechaMenor) and month(pFechaMayor) = month(pFechaMenor) then
        Let Diferencial = mod(year(pFechaMayor) - year(pFechaMenor), 4) * 0.25;
    End if;

    Let anios = ((pFechaMayor - pFechaMenor)+ Diferencial )/ 365.25;
    return anios;
End;
end function;