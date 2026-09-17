CREATE PROCEDURE "informix".calculamesiversario(diacorte INTEGER, fechatrab DATE, cantidad INTEGER) 
     RETURNING 
       CHAR(5)        AS Cod_Ret,
       DATE           AS fecha_mes;

     DEFINE d1            DATE;
     DEFINE cCodRet       CHAR(5);
     DEFINE FechaMes      DATE;
     DEFINE FechaAux      DATE;
     DEFINE ldiaMes       INTEGER;
     DEFINE d2            DATE;

    LET d1      = DATE(1);
    LET cCodRet ='00000';
    LET FechaMes = DATE(1);
    LET FechaAux = DATE(1);

  --  set debug file to "/pisa/cas/calculamesiversario.out";
  --  trace on;
    LET fechatrab = MDY(MONTH(fechatrab),'01',YEAR(fechatrab));

    CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
    LET FechaAux = FechaMes;

    WHILE (day(FechaAux) <> diacorte and month(FechaAux) = month(FechaMes))
        LET FechaAux = FechaAux + 1;
    END WHILE

        IF month(FechaAux) <> month(FechaMes) THEN
           LET FechaAux = FechaAux - 1; 
        END IF;

    CALL "informix".sp_valfechabil(FechaAux,'+') RETURNING cCodRet, FechaMes;

    RETURN cCodRet, FechaMes;

END PROCEDURE;