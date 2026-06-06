-- REGU116  ·  Payments  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU116 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU116ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  PYORD            CHAR(10)  ,  -- FK -> FPAYP
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PYORD2           CHAR(10)  ,  -- FK -> REGU195
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
