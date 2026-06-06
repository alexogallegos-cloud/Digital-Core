-- BKK132  ·  Deposits Mgmt (FS-AM)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK132 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK132ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  KONTO            CHAR(10)  ,  -- FK -> BKKEXT
  BUKRS            CHAR(4)   ,  -- FK -> T001
  KONTO2           CHAR(10)  ,  -- FK -> BKK187
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
