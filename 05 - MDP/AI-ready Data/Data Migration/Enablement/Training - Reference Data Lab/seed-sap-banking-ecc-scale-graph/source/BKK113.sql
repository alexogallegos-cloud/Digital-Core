-- BKK113  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK113 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK113ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKC
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  KONTO2           CHAR(10)  ,  -- FK -> BKK208
  PARTNER          CHAR(10)  ,  -- FK -> BUT195
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
