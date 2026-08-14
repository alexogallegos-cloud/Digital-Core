-- FEB149  ·  Bank Statement / Channels  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB149 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB149ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB104
  STMID2           CHAR(10)  ,  -- FK -> FEB206
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
