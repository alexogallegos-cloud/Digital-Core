-- FEB166  ·  Bank Statement / Channels  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB166 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB166ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE107
  STMID            CHAR(10)  ,  -- FK -> FEB110
  BUKRS            CHAR(4)   ,  -- FK -> T001
  STMID2           CHAR(10)  ,  -- FK -> FEB231
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
