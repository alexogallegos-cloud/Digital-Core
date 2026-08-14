-- CCARD135  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD135 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD135ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  CARDID           CHAR(10)  ,  -- FK -> BKK_CARD
  CARDID2          CHAR(10)  ,  -- FK -> CCARD245
  CARDID3          CHAR(10)  ,  -- FK -> CCARD241
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
