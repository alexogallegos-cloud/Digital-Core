-- REGU127  ·  Payments  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU127 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU127ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> FPAYP
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PYORD2           CHAR(10)  ,  -- FK -> REGU204
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
