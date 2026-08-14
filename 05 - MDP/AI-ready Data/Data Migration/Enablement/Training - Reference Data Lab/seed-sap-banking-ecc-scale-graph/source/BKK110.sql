-- BKK110  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK110 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK110ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKC
  STMID            CHAR(10)  ,  -- FK -> FEB107
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  WAERS            CUKY      ,  -- FK -> TCURC
  KONTO2           CHAR(10)  ,  -- FK -> BKK201
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
