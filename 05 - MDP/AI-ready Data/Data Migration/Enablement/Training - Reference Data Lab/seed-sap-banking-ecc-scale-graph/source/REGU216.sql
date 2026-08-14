-- REGU216  ·  Payments  ·  arquetipo TOTALS  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU216 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU216ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> T042Z
  PYORD2           CHAR(10)  ,  -- FK -> REGU205
  BUKRS            CHAR(4)   ,  -- FK -> T001
  GJAHR            NUMC(4)   ,  -- ejercicio
  MONAT            NUMC(2)   ,  -- periodo
  SALDO            CURR(17)     -- saldo acumulado
);
