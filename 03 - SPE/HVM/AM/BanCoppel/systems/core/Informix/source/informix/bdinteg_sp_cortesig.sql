CREATE PROCEDURE "informix".sp_cortesig(pFecha date, pMeses integer)
RETURNING char(6), date;

    DEFINE vccodret             char(6);
    DEFINE vccodret2            char(6);
    DEFINE vccodret3            char(60);
    DEFINE vsqlerr              integer;
    DEFINE visamerr             integer;
    DEFINE vdescerr             char(60);
    DEFINE vCodret              char(6);
    DEFINE dDiaPrimero          date;
    DEFINE dDiaUltimo           date;
    DEFINE dFechaMesResultante  date;
    DEFINE dDiaUltimoResultante date;
    
    LET vccodret  = '000';
    LET vccodret2 = '000';
    LET vccodret3 = '';
    LET vsqlerr   = 0;
    LET visamerr  = 0;
    LET vdescerr  = '';
    LET vCodret   = '';
    LET dDiaPrimero = '';
    LET dDiaUltimo  = '';
    LET dFechaMesResultante = '';
    LET dDiaUltimoResultante = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cortesig.err';
        TRACE ON;
        IF vsqlerr <> 0  THEN
            LET vcCodRet  = vsqlerr;
            LET vccodret2 = visamerr;
            LET vccodret3 = vdescerr;
            RETURN vcCodRet, pFecha;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_cortesig.out';
    --- TRACE ON;

    IF day(pfecha) >= 29 THEN
        -- // TOMAR EL DÍA 1  Y HACER SUMA DE MESES
        EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(lpad(month(pFecha), 2, '0'), year(pFecha)) 
        INTO vCodret, dDiaPrimero, dDiaUltimo;

        LET dFechaMesResultante = dDiaPrimero + pMeses units month;

        -- // OBTENER DIA ULTIMO DEL MES DE LA FECHA RESULTANTE
        EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(lpad(month(dFechaMesResultante), 2, '0'), year(dFechaMesResultante)) 
        INTO vCodret, dDiaPrimero, dDiaUltimoResultante;

        -- // VALIDAR SI EL DIA DE MESIVERSARIO EXISTE EN EL MES DE FECHA RESULTANTE
        IF day(pFecha) > Day(dDiaUltimoResultante) THEN
            -- // NO EXISTE EL DÍA, TOMAR EL DÍA ULTIMO DE ESE MES
            RETURN '00', dDiaUltimoResultante;
        ELSE
            -- // DIA SI EXISTE, SUMA DE MESES NORMAL
            RETURN '00', pFecha + pMeses units month;
        END IF;
    ELSE
        RETURN '00', pFecha + pMeses units month;
    END IF;

    END;

END PROCEDURE;