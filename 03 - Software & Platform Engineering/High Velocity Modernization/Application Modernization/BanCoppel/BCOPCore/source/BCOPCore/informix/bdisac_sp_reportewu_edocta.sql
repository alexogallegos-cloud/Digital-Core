CREATE PROCEDURE "informix".sp_reportewu_edocta(pFechaIni DATE, pFechaFin DATE, pConvenio CHAR(5))

    RETURNING
    CHAR(10) AS fecha, 
    CHAR(14) AS saldo_inicial,
    CHAR(10) AS total_abonos,
    CHAR(14) AS monto_total_abonos,
    CHAR(10) AS total_cargos,
    CHAR(14) AS monto_total_cargos,
    CHAR(14) AS saldo_final,
    CHAR(20) AS cuenta_concentradora,
    CHAR(18) AS cuenta_clabe,
    CHAR(5)  AS cod_ret;

    DEFINE cCodRet				CHAR(5);
    DEFINE iSqlErr				INTEGER;
    DEFINE dFechaIni			DATE;
    DEFINE dFechaFin			DATE;
    DEFINE cFechaIni			CHAR(10);
    DEFINE cFechaAnt			CHAR(10);
    DEFINE cFechaParam          CHAR(10);
    DEFINE dFechaParam          DATE;
    DEFINE cAnioMes				CHAR(6);
    DEFINE cAnioMesAnt			CHAR(6);
    DEFINE cAnioMes2 		CHAR(6); ---Se corrige el año mes anterior cuando la fecha es 02 de enero
    DEFINE cMes 				CHAR(6);
    DEFINE cCtaConcentradora	CHAR(20);
    DEFINE cCtaClabe			CHAR(20);
    DEFINE cFecha				CHAR(10);
    DEFINE cSaldoInicial		CHAR(14);
    DEFINE cTotalAbonos			CHAR(10);
    DEFINE cMontoTotalAbonos	CHAR(14);
    DEFINE cTotalCargos			CHAR(10);
    DEFINE cMontoTotalCargos	CHAR(14);
    DEFINE cSaldoFinal			CHAR(14);
    DEFINE cCategoria 			CHAR(2);
    DEFINE cConvenio 			CHAR(3);

    LET cCodRet = "";
    LET iSqlErr = 0;
    LET dFechaIni = CURRENT;
    LET dFechaFin = CURRENT;
    LET cFechaIni = "";
    LET cFechaAnt = "";
    LET cFechaParam = "";
    LET cAnioMes = "";
    LET cMes = "";
    LET cAnioMesAnt = "";
    LET cAnioMes2 = "";
    LET cCtaConcentradora = "";
    LET cCtaClabe = "";
    LET cFecha = "";
    LET cSaldoInicial = "";
    LET cTotalAbonos = "";
    LET cMontoTotalAbonos = "";
    LET cTotalCargos = "";
    LET cMontoTotalCargos = "";
    LET cSaldoFinal = "";
    LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
    LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);

    BEGIN

        ON EXCEPTION SET iSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
            IF iSqlErr <> 0 THEN
                RETURN cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, iSqlErr;
            END IF;
        END EXCEPTION;

        --SET DEBUG FILE TO "/informix/HMLG/sp_reportewu_edocta.out";
        --TRACE ON;

        --Verifica parametros nulos o en blanco.
    IF( pFechaIni == "" OR pFechaIni IS NULL ) OR ( pFechaFin == "" OR pFechaFin IS NULL ) OR (cCategoria = "" OR cCategoria IS NULL) OR (cConvenio = "" OR cConvenio IS NULL)THEN
        LET cCodRet = "00001";
        RETURN cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, cCodRet;
    ELSE
        --Se asignan a variables los parametros recibidos.
        LET dFechaIni = pFechaIni;
        LET dFechaFin = pFechaFin;
        --Se obtiene el numero de cuenta concentradora y numero de cuenta clabe para BTS.
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        SELECT cuenta_prestadora,numcuentaclabe 
        INTO cCtaConcentradora,cCtaClabe 
        FROM bdisac:"informix".sac_convenios 
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        SELECT valor INTO cFechaParam FROM bdicheq:"informix".sc_param WHERE codparam='fechcon_movhis';

        LET dFechaParam = cFechaParam;
        --Trabaja mientras la fecha inicial sea menor o igual a la fecha final.
        WHILE(dFechaIni <= dFechaFin)
            --Se asigna a variable la fecha inicio.
            LET cFechaIni = dFechaIni;
            --Se asigna a variable año y mes de la fecha inicio.
            LET cAnioMes = TRIM(SUBSTRING(dFechaIni FROM 7 FOR 4)) || TRIM(SUBSTRING(dFechaIni FROM 1 FOR 2));
            LET cMes = TRIM(SUBSTRING(dFechaIni FROM 1 FOR 2));
            --Verifica si es el dia primero del mes.

            IF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "01" )THEN
                --Se le resta un dia a la fecha inicio y se asigna a variable, en este caso sera el ultimo dia del mes anterior.
                LET cFechaAnt = dFechaIni - INTERVAL (1) DAY TO DAY;
                --Se asigna a variable año y mes del dia anterior.
                LET cAnioMesAnt = TRIM(SUBSTRING(cFechaAnt FROM 1 FOR 4)) || TRIM(SUBSTRING(cFechaAnt FROM 6 FOR 2));
                --Verifica que dia fue el anterior, 28, 29, 30 o 31, dependiendo que dia resulte ser obtendra el capital vigente de ese dia.


                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                IF( TRIM(SUBSTRING(cFechaAnt FROM 9 FOR 2)) = "28" )THEN
                    SELECT capvig28 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMesAnt;
                ELIF( TRIM(SUBSTRING(cFechaAnt FROM 9 FOR 2)) = "29" )THEN
                    SELECT capvig29 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMesAnt;
                ELIF( TRIM(SUBSTRING(cFechaAnt FROM 9 FOR 2)) = "30" )THEN
                    SELECT capvig30 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMesAnt;
                ELIF( TRIM(SUBSTRING(cFechaAnt FROM 9 FOR 2)) = "31" )THEN
                    SELECT capvig31 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMesAnt;
                END IF;

                --Se obtiene el capital vigente del primer dia del mes.
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
                SELECT capvig1 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;

                --Respectivamente se obtendra el capital vigente de cada dia correspondiente al rango de fechas a procesar.
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "02" )THEN


                IF cMes <>"01" THEN
                    SELECT capvig1 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                    SELECT capvig2 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                ELSE

                    LET cAnioMes2 = Year(dFechaIni)-1 || Month(dFechaIni - 1 units month);

                    SELECT capvig31 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc  WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes2;
                    SELECT capvig2 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;

                END IF;


            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "03" )THEN
                SELECT capvig2 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig3 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "04" )THEN
                SELECT capvig3 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig4 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "05" )THEN
                SELECT capvig4 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig5 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "06" )THEN
                SELECT capvig5 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig6 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "07" )THEN
                SELECT capvig6 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig7 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "08" )THEN
                SELECT capvig7 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig8 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "09" )THEN
                SELECT capvig8 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig9 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "10" )THEN
                SELECT capvig9 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig10 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "11" )THEN
                SELECT capvig10 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig11 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "12" )THEN
                SELECT capvig11 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig12 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "13" )THEN
                SELECT capvig12 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig13 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "14" )THEN
                SELECT capvig13 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig14 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "15" )THEN
                SELECT capvig14 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig15 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "16" )THEN
                SELECT capvig15 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig16 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "17" )THEN
                SELECT capvig16 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig17 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "18" )THEN
                SELECT capvig17 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig18 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "19" )THEN
                SELECT capvig18 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig19 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "20" )THEN
                SELECT capvig19 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig20 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "21" )THEN
                SELECT capvig20 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig21 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "22" )THEN
                SELECT capvig21 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig22 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "23" )THEN
                SELECT capvig22 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig23 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "24" )THEN
                SELECT capvig23 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig24 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "25" )THEN
                    IF cMes <>"12" THEN
                            SELECT capvig24 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                            SELECT capvig25 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                    ELSE
                            SELECT capvig24 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                            SELECT capvig24 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                    END IF;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "26" )THEN
                IF cMes <>"12" THEN
                            SELECT capvig25 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                            SELECT capvig26 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                ELSE
                            SELECT capvig24 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                            SELECT capvig26 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                END IF;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "27" )THEN
                SELECT capvig26 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig27 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "28" )THEN
                SELECT capvig27 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig28 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "29" )THEN
                SELECT capvig28 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig29 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "30" )THEN
                SELECT capvig29 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig30 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            ELIF( TRIM(SUBSTRING(cFechaIni FROM 4 FOR 2)) = "31" )THEN
                SELECT capvig30 INTO cSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
                SELECT capvig31 INTO cSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc WHERE cuenta = cCtaConcentradora AND aniomes = cAnioMes;
            END IF;

            --Se obtiene la cantidad de transacciones y el monto total de las transacciones de abono correspondientes del dia a consultar.
            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ;

            IF dFechaIni >= dFechaParam THEN		
                SELECT COUNT(transacc), SUM(monto_tot) INTO cTotalAbonos, cMontoTotalAbonos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = dFechaIni AND movhis.cuenta = cCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "A" AND movhis.cancelad <> 'S';
            ELSE
                SELECT COUNT(transacc), SUM(monto_tot) INTO cTotalAbonos, cMontoTotalAbonos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = dFechaIni AND movhisold.cuenta = cCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "A" AND movhisold.cancelad <> 'S';
            END IF;
            --Se obtiene la cantidad de transacciones y el monto total de las transacciones de cargo correspondientes del dia a consultar.
            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ;

            IF dFechaIni >= dFechaParam THEN
                SELECT COUNT(transacc), SUM(monto_tot) INTO cTotalCargos, cMontoTotalCargos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = dFechaIni AND movhis.cuenta = cCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "C" AND movhis.cancelad <> 'S';
            ELSE
                SELECT COUNT(transacc), SUM(monto_tot) INTO cTotalCargos, cMontoTotalCargos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = dFechaIni AND movhisold.cuenta = cCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "C" AND movhisold.cancelad <> 'S';
            END IF;
            RETURN cFechaIni, NVL(cSaldoInicial, '$0.00'), cTotalAbonos, NVL(cMontoTotalAbonos, '$0.00'), cTotalCargos, NVL(cMontoTotalCargos, '$0.00'), NVL(cSaldoFinal, '$0.00'), cCtaConcentradora, cCtaClabe, iSqlErr WITH RESUME;
            --Se asigna a variable el dia siguiente del mes para continuar consultando.
            LET dFechaIni = dFechaIni + INTERVAL (1) DAY TO DAY;
        END WHILE;
    END IF;
    END
    END PROCEDURE;