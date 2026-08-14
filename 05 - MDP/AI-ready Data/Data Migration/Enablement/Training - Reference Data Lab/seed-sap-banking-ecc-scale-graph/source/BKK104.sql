-- BKK104  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK104 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK104ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  KONTO            CHAR(10)  ,  -- FK -> BKK214
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
