CREATE PROCEDURE "informix".sd_obtienepagosacum(pnumcredito CHAR(20),pfechahoy DATE)
RETURNING CHAR(5),DECIMAL(18,2),SMALLINT;

------------------------------------------------------------------------------------
--ACTIVIDAD:Obtiene el total de los pagos y abonos al saldo acumulados
--en el mes de corte por diversos motivos (pagos, devoluciones, bonificaciones, etc)
------------------------------------------------------------------------------------

--Definicion de variables
DEFINE chrcodret    CHAR(5);
DEFINE intcodret    INTEGER;
DEFINE intdia       SMALLINT;
DEFINE intmes       SMALLINT;
DEFINE intmesant    SMALLINT;
DEFINE intyear      SMALLINT;
DEFINE intyearant   SMALLINT;
DEFINE intnumpagos  SMALLINT;
DEFINE intnumpagos1 SMALLINT;
DEFINE intnumpagos2 SMALLINT;
DEFINE decmonto1    DECIMAL(18,2);
DEFINE decmonto2    DECIMAL(18,2);
DEFINE decmontohis  DECIMAL(18,2);
DEFINE decmontodia  DECIMAL(18,2);
DEFINE decpagosacum DECIMAL(18,2);


--DEBUG FLAG
--SET debug file to "/tmp/sd_obtienepagosacum.out";
--TRACE ON;

set isolation to dirty read;

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret=intcodret;
            RETURN chrcodret,decpagosacum,intnumpagos;
		END IF;
    END EXCEPTION;

    --Inicializacion de Variables
    LET chrcodret    ='000';
    LET intcodret    =0;
    LET intdia       =0;
    LET intmes       =0;
    LET intmesant    =0;
    LET intyear      =0;
    LET intyearant   =0;
    LET intnumpagos  =0;
    LET intnumpagos1 =0;
    LET intnumpagos2 =0;
    LET decmonto1    =0;
    LET decmonto2    =0;
    LET decmontohis  =0;
    LET decmontodia  =0;
    LET decpagosacum =0;

    LET intdia = DAY(pfechahoy);
    LET intmes = MONTH(pfechahoy);
    LET intyear = YEAR(pfechahoy);

    IF intdia > 20 THEN
        --SELECT NVL(SUM(monto),0), count(*) INTO decmontohis, intnumpagos1 FROM bdicred:sd_movhis
        --WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun IN ('033','333','334','046','342')
        --AND reversado = 'N' AND --codigo_ref = 1
        --AND YEAR(fecha_mov) = intyear AND MONTH(fecha_mov) = intmes AND DAY(fecha_mov) > 20;

        let pfechahoy = mdy(month(intmes),day(20),year(intyear));

        SELECT NVL(SUM(monto),0), count(*) INTO decmontohis, intnumpagos1 FROM bdicred:sd_movhis
        WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun ='033'
        AND reversado = 'N' AND codigo_ref = 1
        and fecha_mov > pfechahoy;
--        AND YEAR(fecha_mov) = intyear AND MONTH(fecha_mov) = intmes AND DAY(fecha_mov) > 20;

        IF decmontohis > 0 THEN
            LET intnumpagos = intnumpagos1;
        END IF;

        --SELECT NVL(SUM(monto),0), count(*) INTO decmontodia, intnumpagos2 FROM bdicred:sd_movdia
        --WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun IN ('033','333','334','046','342')
        --AND reversado = 'N'; --AND codigo_ref = 1;

        SELECT NVL(SUM(monto),0), count(*) INTO decmontodia, intnumpagos2 FROM bdicred:sd_movdia
        WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun = '033'
        AND reversado = 'N' AND codigo_ref = 1 and fecha_mov >= date(0);

        IF decmontodia > 0 THEN
            LET intnumpagos = intnumpagos + intnumpagos2;
        END IF;
    ELSE
        LET intmesant = intmes - 1;
        IF intmesant <= 0 THEN
            LET intmesant = 12;
            LET intyearant = intyear - 1;
        END IF;

       let pfechahoy = mdy(month(intmesant),day(20),year(intyearant));

        --SELECT fecha_mov,monto FROM bdicred:sd_movhis
        --WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun IN ('033','333','334','046','342')
        --AND reversado = 'N' --AND codigo_ref = 1
        --AND ( YEAR(fecha_mov) >= intyearant AND MONTH(fecha_mov) >= intmesant )
        --INTO TEMP tmp_movhis;

        --SELECT fecha_mov,monto FROM bdicred:sd_movhis
        SELECT nvl(sum(monto),0), count(*) INTO decmontohis, intnumpagos
        FROM bdicred:sd_movhis
        WHERE empresa='001' AND num_credito = pnumcredito AND codigo_fun = '033'
        AND reversado = 'N' AND codigo_ref = 1
        and fecha_mov > pfechahoy;
--        AND ( YEAR(fecha_mov) >= intyearant AND MONTH(fecha_mov) >= intmesant )
--        INTO TEMP tmp_movhis;

--        SELECT NVL(SUM(monto),0), count(*) INTO decmonto1, intnumpagos1
--        FROM tmp_movhis WHERE MONTH(fecha_mov) = intmesant AND DAY(fecha_mov) > 20;

--        IF decmonto1 > 0 THEN
--           LET intnumpagos = intnumpagos1;
--        END IF;

--        SELECT NVL(SUM(monto), 0), count(*) INTO decmonto2, intnumpagos1
--        FROM tmp_movhis WHERE MONTH(fecha_mov) = intmes;

--        IF decmonto2 > 0 THEN
--            LET intnumpagos = intnumpagos + intnumpagos1;
--        END IF;

        --SELECT NVL(SUM(monto), 0), count(*) INTO decmontodia, intnumpagos2 FROM bdicred:sd_movdia
        --WHERE empresa='001' AND num_credito = pnumcredito
        --AND codigo_fun IN ('033','333','334','046','342')
        --AND reversado = 'N'; --AND codigo_ref = 1;

        SELECT NVL(SUM(monto), 0), count(*) INTO decmontodia, intnumpagos2
        FROM bdicred:sd_movdia WHERE empresa='001'
        AND num_credito = pnumcredito AND codigo_fun = '033'
        AND reversado = 'N' AND codigo_ref = 1 and fecha_mov >= date(0);

        IF decmontodia > 0 THEN
            LET intnumpagos = intnumpagos + intnumpagos2;
        END IF;

--        DROP TABLE tmp_movhis;
--        LET decmontohis = decmonto1 + decmonto2;
    END IF;

    LET decpagosacum = decmontohis + decmontodia;

RETURN chrcodret,decpagosacum,intnumpagos;

END;
END PROCEDURE;