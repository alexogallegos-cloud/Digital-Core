CREATE function "informix".fnnumerosemana (fecha date, pdiaprimersemanavalida smallint)
returning smallint, smallint;
--pDiaPrimerSemanaValida
--Mandar 4 para calcular de acuerdo a la norma iso 8601
--Cualquier numero fuera del rango de 1 a 7, se tomara como un valor 4.
--Mandar 1 para indicar que la prim semana del anio es la que tiene el primer lunes del anio.
--Mandar 2 para indicar que la prim semana del anio es la que tiene el primer Martes del anio.
--Mandar 3 para indicar que la prim semana del anio es la que tiene el primer Miercoles del anio.
--Mandar 4 para indicar que la prim semana del anio es la que tiene el primer Jueves del anio.
--Mandar 5 para indicar que la prim semana del anio es la que tiene el primer Viernes del anio.
--Mandar 6 para indicar que la prim semana del anio es la que tiene el primer Sabado del anio.
--Mandar 7 para indicar que la prim semana del anio es la que tiene el primer Domingo del anio.
--06/03/2009. Juan Andres, calcular numero de semana del anio en que se encuentra una fecha.
--Las semanas se consideran de Lunes a Domingo

define NumdeDia         smallint;
define DiasPrimerSemana smallint;
define DiasUltSemana    smallint;
define PrimerDiaAnio    smallint;
define UltimoDiaAnio    smallint;
define Numero           smallint;
define BanderaDia       smallint;
define NumeroSemana     smallint;
define iAnio            smallint;
--define pDiaPrimerSemanaValida smallint;
--set debug file to "/RESPALDOS/fnnumerosemana.out";
--trace on;
begin
    If pDiaPrimerSemanaValida is null then
        Let pDiaPrimerSemanaValida = 4;
    End if;
    If pDiaPrimerSemanaValida < 1 or pDiaPrimerSemanaValida > 7 then
        Let pDiaPrimerSemanaValida = 4;
    End if;
    --Let pDiaPrimerSemanaValida = 8 - pDiaPrimerSemanaValida;

    Let NumdeDia = fecha - mdy(12,31,year(fecha)-1);
    Let PrimerDiaAnio = weekday(mdy( 1, 1, year(fecha)));
    Let UltimoDiaAnio = weekday(mdy(12,31, year(fecha)));

    Let DiasPrimerSemana = 7 - (PrimerDiaAnio - 1);

    Let DiasUltSemana   = 7 - (UltimoDiaAnio - 1);
    If PrimerDiaAnio = pDiaPrimerSemanaValida or  UltimoDiaAnio = pDiaPrimerSemanaValida then
        Let BanderaDia = 1;
    Else
        Let BanderaDia = 0;
    End if;
    Let Numero = round((NumdeDia - DiasPrimerSemana - 4) / 7,0);
    If DiasPrimerSemana >=  8 - pDiaPrimerSemanaValida then
        Let NumeroSemana = Numero + 2;
    else
        Let NumeroSemana = Numero + 1;
    end if;
    If NumeroSemana > 52 and BanderaDia = 0 then
        Let NumeroSemana = 1;
    End if;
    If NumeroSemana = 0 then
        Let NumeroSemana = fnNumeroSemana(mdy(12, 31, year(fecha)-1), pDiaPrimerSemanaValida);
    End if;

    If month(fecha) = 12 and NumeroSemana = 1 then
        Let iAnio = year(fecha)+1;
    Elif month(fecha) = 1 and NumeroSemana >= 52 then
        Let iAnio = year(fecha) - 1;
    Else
        Let iAnio = year(fecha);
    End if;
    return NumeroSemana, iAnio;
end;
end function;