-- FEB112  ·  Bank Statement / Channels  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB112 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB112ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB104
  STMID2           CHAR(10)  ,  -- FK -> FEBKO
  STMID3           CHAR(10)  ,  -- FK -> FEB213
  CARDID           CHAR(10)  ,  -- FK -> CCARD251
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
