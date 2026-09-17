create procedure "informix".cat(fTasa float, Plazo integer)
returning float;

    define x0       float;
    define x1       float;
    define fx0      float;
    define fx1      float;
    define x        float;
    define PagoMin  float;
    define fx       float;
    define vn       float;
    define iPeriodo integer;
    define fFactor  float;

--Función para calcular Costo Anual Total de crédito, según tasa y plazo en meses. Usado en Módulo de Crédito.
--Fecha de Elaboración	: 29-03-2007
--Elabrorado por      	: Juan A Coronel
--Solicitado por	: Román Vega, Depto de Riesgos



begin
    Let x0 = 0;
    Let x1 = 100;
    Let fx0 = fTasa;

    --Valor de la secante
    --Let fx1 = -0.0555259612159481; 

    Let PagoMin = (1 + fTasa) / Plazo;

    while 1=1

        Let fx = 0;
        Let vn = 1 / (1 + x1 / 36000 * 30);
        For iPeriodo = 0 to Plazo
            Let fFactor = POW( vn, iPeriodo );
            If iPeriodo = 0 then
                Let fx = fx + ( fFactor * -1 );
            Else
                Let fx = fx + ( fFactor * PagoMin );
            End if;
        End For;

        Let fx1 = fx;
        Let x = x1 - ( fx1 * (x0 - x1) / (fx0 - fx1) );
        Let x0 = x1;
        Let x1 = x;
        Let fx0 = fx1;

        If ( fx > -0.000001 and fx < 0.000001 ) then
            exit while;
        End if;
    end while;
    return x;
end;
end procedure;