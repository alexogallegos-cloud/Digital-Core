-- BS151  ·  Financial Accounting / GL  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BS151 (
  MANDT            CLNT      ,  -- mandante (client)
  BS151ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> COKA
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  SAKNR2           CHAR(10)  ,  -- FK -> SKB1
  WAERS            CUKY      ,  -- FK -> TCURX
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS2           CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
