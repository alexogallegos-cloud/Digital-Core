-- CMS111  ·  Collateral (BCA)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS111 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS111ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> FPAYH
  COLID            CHAR(10)  ,  -- FK -> CMS101
  WAERS            CUKY      ,  -- FK -> TCURX
  COLID2           CHAR(10)  ,  -- FK -> CMS222
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS2           CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
