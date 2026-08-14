-- CCARD138  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD138 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD138ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB110
  CARDID           CHAR(10)  ,  -- FK -> BKK_CARD
  BUKRS            CHAR(4)   ,  -- FK -> T001
  CARDID2          CHAR(10)  ,  -- FK -> CCARD248
  WAERS            CUKY      ,  -- FK -> TCURC
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
