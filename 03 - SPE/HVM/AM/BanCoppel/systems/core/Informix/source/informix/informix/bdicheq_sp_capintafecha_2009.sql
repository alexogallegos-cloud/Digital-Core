CREATE PROCEDURE "informix".sp_capintafecha_2009(pCuenta CHAR(20), pFecha  DATE)

RETURNING  CHAR(10), DECIMAL(14,2), DECIMAL(14,2);

DEFINE cCodret      CHAR(5);
DEFINE cSQL_ERR     INTEGER;
DEFINE cDia         CHAR(2);
DEFINE cAnioMes     CHAR(6);
DEFINE vCapital     DECIMAL(14,2);
DEFINE vInteres     DECIMAL(14,2);

LET cCodret     = '000';
LET cSQL_ERR    = 100;
LET vCapital    = 0.00;
LET vInteres    = 0.00;

-- SET DEBUG FILE TO '/tmp/sp_SaldoaFecha.out';
-- TRACE ON;

BEGIN

ON EXCEPTION 
    SET cSQL_ERR
    LET cCodret = cSQL_ERR;
    RETURN cCodret, vCapital, vInteres;
END EXCEPTION;

LET cDia = SUBSTR(pFecha,4,2);
LET cAnioMes = SUBSTR(pFecha,7,4) || SUBSTR(pFecha,1,2);
LET cDia = cDia;
LET cAnioMes = cAnioMes;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF LPAD(cDia,2,'0') = '01' THEN

    SELECT capvig1, intprovnp1
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '02' THEN

    SELECT capvig2, intprovnp2
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '03' THEN

    SELECT capvig3, intprovnp3
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '04' THEN

    SELECT capvig4, intprovnp4
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '05' THEN

    SELECT capvig5, intprovnp5
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '06' THEN

    SELECT capvig6, intprovnp6
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '07' THEN

    SELECT capvig7, intprovnp7
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '08' THEN

    SELECT capvig8, intprovnp8
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '09' THEN

    SELECT capvig9, intprovnp9
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '10' THEN

    SELECT capvig10, intprovnp10
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '11' THEN

    SELECT capvig11, intprovnp11
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '12' THEN

    SELECT capvig12, intprovnp12
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '13' THEN

    SELECT capvig13, intprovnp13
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '14' THEN

    SELECT capvig14, intprovnp14
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '15' THEN

    SELECT capvig15, intprovnp15
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '16' THEN

    SELECT capvig16, intprovnp16
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '17' THEN

    SELECT capvig17, intprovnp17
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '18' THEN

    SELECT capvig18, intprovnp18
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '19' THEN

    SELECT capvig19, intprovnp19
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '20' THEN

    SELECT capvig20, intprovnp20
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '21' THEN

    SELECT capvig21, intprovnp21
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '22' THEN

    SELECT capvig22, intprovnp22
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '23' THEN

    SELECT capvig23, intprovnp23
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '24' THEN

    SELECT capvig24, intprovnp24
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 	
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '25' THEN

    SELECT capvig25, intprovnp25
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '26' THEN

    SELECT capvig26, intprovnp26
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '27' THEN

    SELECT capvig27, intprovnp27
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '28' THEN

    SELECT capvig28, intprovnp28
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '29' THEN

    SELECT capvig29, intprovnp29
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '30' THEN

    SELECT capvig30, intprovnp30
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELIF LPAD(cDia,2,'0') = '31' THEN

    SELECT capvig31, intprovnp31
      INTO vCapital, vInteres
      FROM bdicheq:sc_sdodiarioc2009 
     WHERE cuenta = pCuenta 
       AND aniomes = cAnioMes;

ELSE
    -- // FECHA INVALIDA
    LET cCodret = '200'; 
END IF;

IF vCapital = '' OR vCapital IS NULL THEN
    -- // CUENTA NO EXISTE EN FECHA
    LET cCodret = '100'; 
END IF;

RETURN cCodret, vCapital, vInteres;

END;

END PROCEDURE;