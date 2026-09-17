CREATE PROCEDURE "informix".sp_diaprimeroultimomesanio(pMes char(2), pAnio char(4))
RETURNING char(6), date, date;

    -- // Sp para devolver el día primero y ultimo de un mes-año
    -- // Para compilarse en la base de datos integral
    -- // Juan Andres Coronel Junio 2008

    DEFINE vcCodRet     char(6);
    DEFINE vccodret2    char(6);
    DEFINE vccodret3    char(60);
    DEFINE vsqlerr      integer;
    DEFINE visamerr     integer;
    DEFINE vdescerr     char(60);
    DEFINE sAuxFecha    Char(10);
    DEFINE sAuxMes      Char(2);
    DEFINE sAuxAnio     Char(4);
    DEFINE dDiaprimero  date;
    DEFINE dDiaUltimo   date;
    
    LET vcCodRet    = '000000';
    LET vccodret2   = '000000';
    LET vccodret3   = '';
    LET vsqlerr     = 0;
    LET visamerr    = 0;
    LET vdescerr    = '';
    LET sAuxFecha   = '';
    LET sAuxMes     = '';
    LET sAuxAnio    = '';
    LET dDiaprimero = '';
    LET dDiaUltimo  = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_diaprimeroultimomesanio.err';
        TRACE ON;
        IF vsqlerr <> 0  THEN
            LET vcCodRet  = vsqlerr;
            LET vccodret2 = visamerr;
            LET vccodret3 = vdescerr;
            RETURN vcCodRet, date(1), date(1);
        END IF;
    END  EXCEPTION
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_diaprimeroultimomesanio.out';
    --- TRACE ON;
    
    LET sAuxFecha   = lpad(trim(pMes), 2, '0') || '-01-' || pAnio ;
    LET dDiaprimero = sAuxFecha::Date;

    IF pMes = '12' THEN
        Let sAuxMes = '01';
        Let sAuxAnio = pAnio + 1 ;
    ELSE
        Let sAuxMes = pMes + 1;
        Let sAuxMes = lpad(trim(sAuxMes), 2, '0');
        Let sAuxAnio = pAnio;
    END IF;

    LET sAuxFecha  = sAuxMes || '-01-' || sAuxAnio ;
    LET dDiaUltimo = sAuxFecha::date - 1;

    END;

    RETURN vcCodRet , dDiaprimero, dDiaUltimo;

END PROCEDURE;