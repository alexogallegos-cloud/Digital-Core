-- BKK226  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TOTALS  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK226 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK226ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKK40
  KONTO2           CHAR(10)  ,  -- FK -> BKK216
  BUKRS            CHAR(4)   ,  -- FK -> T001
  GJAHR            NUMC(4)   ,  -- ejercicio
  MONAT            NUMC(2)   ,  -- periodo
  SALDO            CURR(17)     -- saldo acumulado
);
