create procedure "informix".sp_cortesig(pFecha date, pMeses integer)
 returning char(6), date;

--Juan Andres 27-08-2008

define vCodret char(6);
define dDiaPrimero date;
define dDiaUltimo  date;
define dFechaMesResultante date;
define dDiaUltimoResultante date;
define vsqlerr     integer;
define vccodret char(6);

Begin
        ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                LET  vcCodRet  = vsqlerr;
                RETURN vcCodRet, pFecha;
            END IF;
        END  EXCEPTION

    If day(pfecha) >= 29 then

        -- Tomar el día 1  y hacer suma de meses

        execute procedure sp_diaprimeroultimomesanio(lpad(month(pFecha), 2, '0'), year(pFecha)) into vCodret, dDiaPrimero, dDiaUltimo;

        Let dFechaMesResultante = dDiaPrimero + pMeses units month;

        -- Obtener dia ultimo del mes de la fecha resultante

        execute procedure sp_diaprimeroultimomesanio(lpad(month(dFechaMesResultante), 2, '0'), year(dFechaMesResultante)) 
into vCodret, dDiaPrimero, dDiaUltimoResultante;

        -- Validar si el dia de mesiversario existe en el mes de fecha resultante

        If day(pFecha) > Day(dDiaUltimoResultante)   then --No existe el día

            -- Tomar el día ultimo de ese mes
            return '00', dDiaUltimoResultante;
        else
            -- Día si existe, suma de meses normal.
            return '00', pFecha + pMeses units month;
        end if;
    Else
        return '00', pFecha + pMeses units month;
    End if;

end;
end procedure;