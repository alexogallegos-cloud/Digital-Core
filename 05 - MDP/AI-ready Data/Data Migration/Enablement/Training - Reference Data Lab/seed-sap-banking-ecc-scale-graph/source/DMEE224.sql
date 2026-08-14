-- DMEE224  ·  Payment Medium (DMEE)  ·  arquetipo TOTALS  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE224 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE224ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE106
  DMEEID2          CHAR(10)  ,  -- FK -> DMEE206
  BUKRS            CHAR(4)   ,  -- FK -> T001
  GJAHR            NUMC(4)   ,  -- ejercicio
  MONAT            NUMC(2)   ,  -- periodo
  SALDO            CURR(17)     -- saldo acumulado
);
