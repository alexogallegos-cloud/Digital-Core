-- CCARD168  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD168 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD168ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> FCC_HEAD
  CARDID2          CHAR(10)  ,  -- FK -> TB033
  CARDID3          CHAR(10)  ,  -- FK -> CCARD101
  CARDID4          CHAR(10)  ,  -- FK -> CCARD241
  CARDID5          CHAR(10)  ,  -- FK -> CCARD248
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
