% =================================================================
% ALGOL : UDATECONV  -  Conversion y validacion de fechas
% CAPA: UTIL (HUB)  ·  Fan-in = 444 (2do hub mas alto)
% PROPOSITO: Utileria de sistema compartida para fechas Julianas/
%            Gregorianas. Llamada desde casi todos los dominios.
% LLAMA A : UPARSEDT (sub-utileria)
% =================================================================
PROCEDURE UDATECONV (FECHA_IN, FORMATO, FECHA_OUT, RC);
  INTEGER FECHA_IN;
  INTEGER FORMATO;
  INTEGER FECHA_OUT;
  INTEGER RC;
BEGIN
  INTEGER ANIO, MES, DIA;

  RC := 0;
  ANIO := FECHA_IN DIV 10000;
  MES  := (FECHA_IN MOD 10000) DIV 100;
  DIA  := FECHA_IN MOD 100;

  IF MES < 1 OR MES > 12 OR DIA < 1 OR DIA > 31 THEN
    BEGIN
      RC := 9001;
      FECHA_OUT := 0;
    END
  ELSE
    BEGIN
      CASE FORMATO OF
        BEGIN
          % 0 = Juliana, 1 = Gregoriana AAAAMMDD
          (ANIO * 1000) + DIAS_JULIANOS (ANIO, MES, DIA);
          FECHA_IN;
        END;
      FECHA_OUT := RESULTADO;
    END;
END UDATECONV;