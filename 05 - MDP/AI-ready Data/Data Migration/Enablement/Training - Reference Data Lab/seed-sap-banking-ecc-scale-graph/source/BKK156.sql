-- BKK156  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK156 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK156ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKA
  KONTO2           CHAR(10)  ,  -- FK -> BKK222
  KONTO3           CHAR(10)  ,  -- FK -> BKK221
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
