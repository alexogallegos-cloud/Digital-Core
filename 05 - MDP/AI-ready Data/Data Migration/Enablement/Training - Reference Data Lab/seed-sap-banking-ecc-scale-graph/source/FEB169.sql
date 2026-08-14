-- FEB169  ·  Bank Statement / Channels  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB169 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB169ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> T028G
  STMID2           CHAR(10)  ,  -- FK -> FEBRE
  STMID3           CHAR(10)  ,  -- FK -> FEB231
  WAERS            CUKY      ,  -- FK -> TCURX
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
