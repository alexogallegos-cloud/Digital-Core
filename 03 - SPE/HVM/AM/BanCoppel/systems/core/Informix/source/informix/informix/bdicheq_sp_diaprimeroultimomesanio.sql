create procedure "informix".sp_diaprimeroultimomesanio(pMes char(2), pAnio char(4))
 returning char(6) , date, date;

--Sp para devolver el día primero y ultimo de un mes-año
--Para compilarse en la base de datos integral
--Juan Andres Coronel Junio 2008

Define sAuxFecha   Char(10);
Define sAuxMes     Char(2);
Define sAuxAnio    Char(4);
Define dDiaprimero date;
Define dDiaUltimo  date;
Define vcCodRet    char(6);
define vsqlerr     integer;

    Begin
        ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                LET  vcCodRet  = vsqlerr;
                RETURN vcCodRet, date(1), date(1);
            END IF;
        END  EXCEPTION

        Let vcCodRet = '000000';
        Let sAuxFecha   = lpad(trim(pMes), 2, '0') || '-01-' || pAnio ;
        Let dDiaprimero = sAuxFecha::Date;

        If pMes = '12' then
            Let sAuxMes = '01';
            Let sAuxAnio = pAnio + 1 ;
        Else
            Let sAuxMes = pMes + 1;
            Let sAuxMes = lpad(trim(sAuxMes), 2, '0');
            Let sAuxAnio = pAnio;
        End If;

        Let sAuxFecha  = sAuxMes || '-01-' || sAuxAnio ;
        Let dDiaUltimo = sAuxFecha::date - 1;
    End;

    Return vcCodRet , dDiaprimero, dDiaUltimo;
End procedure;