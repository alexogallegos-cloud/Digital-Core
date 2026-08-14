-- CMS169  ·  Collateral (BCA)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS169 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS169ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKC
  COLID            CHAR(10)  ,  -- FK -> CMS105
  COLID2           CHAR(10)  ,  -- FK -> CMS101
  COLID3           CHAR(10)  ,  -- FK -> CMS216
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
