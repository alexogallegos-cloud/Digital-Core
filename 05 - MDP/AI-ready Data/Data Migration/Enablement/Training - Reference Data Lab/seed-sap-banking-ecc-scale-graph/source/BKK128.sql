-- BKK128  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK128 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK128ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKK1
  KONTO2           CHAR(10)  ,  -- FK -> BKK192
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
