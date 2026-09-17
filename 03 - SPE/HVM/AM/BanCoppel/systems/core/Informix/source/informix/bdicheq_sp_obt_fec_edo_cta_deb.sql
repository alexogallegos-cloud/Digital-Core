CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_deb(pCuenta char(20))
        RETURNING char(5), char(6), date, date;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener fechas para estado de cuenta de debito
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  17/07/2008
	
	--------------------------------------------------------------------
	-- Modifico  : Gabriela Aguilar
	-- Activdad  : Cambio de tabla de sc_maehis hacia  sc_maehis_factelect
	-- fecha     : 10/11/2017
	
	
	

       DEFINE vcodret   char(5);
       DEFINE vAnioMes  char(6);
       DEFINE vFechaFin date;
       DEFINE vFechaIni date;
       DEFINE sql_err integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vAnioMes = '000000';
LET vFechaIni = '01/01/1900';
LET vFechaFin = '01/01/1900';
BEGIN

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_obt_fec_edo_cta_deb.out";
	--TRACE ON;


   SET ISOLATION DIRTY READ ;
   set lock mode to wait 3;

    FOREACH
        SELECT LIMIT 3 aniomes, fechaini, fechafin
        INTO vAnioMes, vFechaIni, vFechaFin
        --FROM sc_maehis
		FROM sc_maehis_factelect
        WHERE empresa = '001'
        AND cuenta = pCuenta
        ORDER BY fechaini DESC


        --IF vAnioMes IS NULL THEN
        --  LET vcodret = '100';
        --  RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
        --END IF;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin WITH RESUME;
    END FOREACH;
END;

END PROCEDURE;