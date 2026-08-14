-- BKK160  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK160 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK160ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKC
  KONTO2           CHAR(10)  ,  -- FK -> BKK216
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
