-- BS132  ·  Financial Accounting / GL  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BS132 (
  MANDT            CLNT      ,  -- mandante (client)
  BS132ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
