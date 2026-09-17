CREATE PROCEDURE "informix".sp_existeconstanciaanual(pFechaAnio CHAR(4))
--Funcion que verifica si ya se ha corrido el proceso de generacion de constan)
--devuelve '000000' si aun no se ha ejecutado el proceso para el año consultado
--devuelve '000001' si ya se ejecutó
    -- DATOS A REGRESAR
	RETURNING
    CHAR(6);  -- Codigo de Retorno

    -- DEFINICION DE VARIABLES
    DEFINE vCodRet          CHAR(6);
    Define dFechaInicial    date;
    Define dFechaFinal      date;
    Define sAuxFecha        char(10);
    Define iCuantos         smallint;
    define vsqlerr          integer;

BEGIN

    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET  vCodRet  = vsqlerr;
            RETURN vCodRet;
        END IF;
    END  EXCEPTION


    Let sAuxFecha   =  '01-01-' || trim((pFechaAnio + 1)::char(4)); --Formato y
    Let dFechaInicial = sAuxFecha::Date;

    Let sAuxFecha   =  '02-10-' || trim((pFechaAnio + 1)::char(4)); --Formato y
    Let dFechaFinal = sAuxFecha::Date;

    Select COUNT(*)
    Into iCuantos
    from sl_procesos
    where proceso = 'constanual'
    and fech_proceso >= dFechaInicial
    and fech_proceso <= dFechaFinal
    and status=1;

    If iCuantos > 0 then
        Let vCodRet = '000001';
    Else
        Let vCodRet = '000000';
    End if;
    Return vCodRet;
END;
END PROCEDURE;