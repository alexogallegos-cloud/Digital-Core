-- BUT106  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT106 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT106ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BP001
  PARTNER2         CHAR(10)  ,  -- FK -> BUT050
  PARTNER3         CHAR(10)  ,  -- FK -> BUT052
  PARTNER4         CHAR(10)  ,  -- FK -> BUT189
  PARTNER5         CHAR(10)  ,  -- FK -> BUT204
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
