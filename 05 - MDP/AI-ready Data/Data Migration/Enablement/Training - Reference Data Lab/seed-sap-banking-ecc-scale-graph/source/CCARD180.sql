-- CCARD180  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD180 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD180ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARD101
  COLID            CHAR(10)  ,  -- FK -> CMS101
  CARDID2          CHAR(10)  ,  -- FK -> BKK_CARD
  CARDID3          CHAR(10)  ,  -- FK -> CCARD241
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
