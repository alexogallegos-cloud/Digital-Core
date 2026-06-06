-- BUT113  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT113 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT113ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BPVB
  PARTNER2         CHAR(10)  ,  -- FK -> TBZ0
  WAERS            CUKY      ,  -- FK -> TCURX
  PARTNER3         CHAR(10)  ,  -- FK -> BUT210
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
