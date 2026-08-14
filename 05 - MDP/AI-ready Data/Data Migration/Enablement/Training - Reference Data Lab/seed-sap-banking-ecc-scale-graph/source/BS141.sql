-- BS141  ·  Financial Accounting / GL  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BS141 (
  MANDT            CLNT      ,  -- mandante (client)
  BS141ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARD101
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  WAERS2           CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
