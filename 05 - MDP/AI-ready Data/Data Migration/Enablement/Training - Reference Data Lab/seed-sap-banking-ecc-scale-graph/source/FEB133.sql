-- FEB133  ·  Bank Statement / Channels  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB133 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB133ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKKEXT
  STMID            CHAR(10)  ,  -- FK -> FEB106
  STMID2           CHAR(10)  ,  -- FK -> FEB110
  STMID3           CHAR(10)  ,  -- FK -> FEB231
  STMID4           CHAR(10)  ,  -- FK -> FEB229
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
