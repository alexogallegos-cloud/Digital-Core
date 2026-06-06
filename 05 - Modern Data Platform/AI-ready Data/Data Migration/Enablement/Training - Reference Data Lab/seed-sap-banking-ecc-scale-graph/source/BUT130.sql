-- BUT130  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT130 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT130ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT102
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  PARTNER2         CHAR(10)  ,  -- FK -> BUT210
  PARTNER3         CHAR(10)  ,  -- FK -> BUT189
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
