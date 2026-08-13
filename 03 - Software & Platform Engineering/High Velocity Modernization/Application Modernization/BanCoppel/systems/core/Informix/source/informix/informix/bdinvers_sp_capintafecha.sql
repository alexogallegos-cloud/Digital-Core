CREATE PROCEDURE "informix".sp_capintafecha(pCuenta CHAR(20), pFecha  DATE, pSecuencia SMALLINT)

RETURNING  CHAR(5), CHAR(15), DECIMAL(14,2), DECIMAL(14,2);

    DEFINE cCodret      CHAR(5);
    DEFINE cCodret2     CHAR(15);
    DEFINE cSQL_ERR     INTEGER;
    DEFINE cISAM_ERR    INTEGER;
    DEFINE cDia         CHAR(2);
    DEFINE cAnioMes     CHAR(6);
    DEFINE vCapital     DECIMAL(14,2);
    DEFINE vInteres     DECIMAL(14,2);

    LET cCodret     = '000';
    LET cCodret2    = '000';
    LET cSQL_ERR    = 000;
    LET cISAM_ERR   = 000;
    LET vCapital    = 0.00;
    LET vInteres    = 0.00;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_capintafechainv.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION 
        SET cSQL_ERR, cISAM_ERR
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_capintafechainv.err";
        TRACE ON;
        LET cCodret = cSQL_ERR;
        LET cCodret2 = cISAM_ERR;
        RETURN cCodret, cCodret2, vCapital, vInteres;
    END EXCEPTION;

    LET cDia = SUBSTR(pFecha,4,2);
    LET cAnioMes = SUBSTR(pFecha,7,4) || SUBSTR(pFecha,1,2);
    LET cDia = cDia;
    LET cAnioMes = cAnioMes;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF LPAD(cDia,2,'0') = '01' THEN

        SELECT NVL(cv_dia1, 0.00), NVL(ipa_dia1, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '02' THEN

        SELECT NVL(cv_dia2, 0.00), NVL(ipa_dia2, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '03' THEN

        SELECT NVL(cv_dia3, 0.00), NVL(ipa_dia3, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '04' THEN

        SELECT NVL(cv_dia4, 0.00), NVL(ipa_dia4, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '05' THEN

        SELECT NVL(cv_dia5, 0.00), NVL(ipa_dia5, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;
           
    ELIF LPAD(cDia,2,'0') = '06' THEN

        SELECT NVL(cv_dia6, 0.00), NVL(ipa_dia6, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '07' THEN

        SELECT NVL(cv_dia7, 0.00), NVL(ipa_dia7, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '08' THEN

        SELECT NVL(cv_dia8, 0.00), NVL(ipa_dia8, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '09' THEN

        SELECT NVL(cv_dia9, 0.00), NVL(ipa_dia9, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '10' THEN

        SELECT NVL(cv_dia10, 0.00), NVL(ipa_dia10, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '11' THEN

        SELECT NVL(cv_dia11, 0.00), NVL(ipa_dia11, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '12' THEN

        SELECT NVL(cv_dia12, 0.00), NVL(ipa_dia12, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '13' THEN

        SELECT NVL(cv_dia13, 0.00), NVL(ipa_dia13, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '14' THEN

        SELECT NVL(cv_dia14, 0.00), NVL(ipa_dia14, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '15' THEN

        SELECT NVL(cv_dia15, 0.00), NVL(ipa_dia15, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '16' THEN

        SELECT NVL(cv_dia16, 0.00), NVL(ipa_dia16, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '17' THEN

        SELECT NVL(cv_dia17, 0.00), NVL(ipa_dia17, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '18' THEN

        SELECT NVL(cv_dia18, 0.00), NVL(ipa_dia18, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '19' THEN

        SELECT NVL(cv_dia19, 0.00), NVL(ipa_dia19, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '20' THEN

        SELECT NVL(cv_dia20, 0.00), NVL(ipa_dia20, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '21' THEN

        SELECT NVL(cv_dia21, 0.00), NVL(ipa_dia21, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '22' THEN

        SELECT NVL(cv_dia22, 0.00), NVL(ipa_dia22, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '23' THEN

        SELECT NVL(cv_dia23, 0.00), NVL(ipa_dia23, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '24' THEN

        SELECT NVL(cv_dia24, 0.00), NVL(ipa_dia24, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '25' THEN

        SELECT NVL(cv_dia25, 0.00), NVL(ipa_dia25, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '26' THEN

        SELECT NVL(cv_dia26, 0.00), NVL(ipa_dia26, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '27' THEN

        SELECT NVL(cv_dia27, 0.00), NVL(ipa_dia27, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '28' THEN

        SELECT NVL(cv_dia28, 0.00), NVL(ipa_dia28, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '29' THEN

        SELECT NVL(cv_dia29, 0.00), NVL(ipa_dia29, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '30' THEN

        SELECT NVL(cv_dia30, 0.00), NVL(ipa_dia30, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELIF LPAD(cDia,2,'0') = '31' THEN

        SELECT NVL(cv_dia31, 0.00), NVL(ipa_dia31, 0.00)
          INTO vCapital, vInteres
          FROM bdinvers:sv_provdia
         WHERE cuenta = pCuenta 
           AND aniomes = cAnioMes
           AND secuencia = pSecuencia;

    ELSE
        -- // FECHA INVALIDA
        LET cCodret = '200';
        LET cCodret2 = '200';
    END IF;

    IF vCapital = '' OR vCapital IS NULL THEN
        -- // CUENTA NO EXISTE EN FECHA
        --- LET cCodret = '100';
        --- LET cCodret2 = '100';
        LET vCapital = 0.00;
        LET vInteres = 0.00;
    END IF;

    RETURN cCodret, cCodret2, vCapital, vInteres;

    END;

END PROCEDURE;