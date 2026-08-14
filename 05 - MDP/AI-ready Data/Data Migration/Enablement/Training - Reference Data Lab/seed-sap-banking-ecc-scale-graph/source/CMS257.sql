-- CMS257  ·  Collateral (BCA)  ·  arquetipo TOTALS  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS257 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS257ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  COLID            CHAR(10)  ,  -- FK -> CMS107
  COLID2           CHAR(10)  ,  -- FK -> CMS243
  BUKRS            CHAR(4)   ,  -- FK -> T001
  GJAHR            NUMC(4)   ,  -- ejercicio
  MONAT            NUMC(2)   ,  -- periodo
  SALDO            CURR(17)     -- saldo acumulado
);
