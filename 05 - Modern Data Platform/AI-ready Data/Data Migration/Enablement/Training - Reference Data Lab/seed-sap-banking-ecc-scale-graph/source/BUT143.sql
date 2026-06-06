-- BUT143  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT143 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT143ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT0ID
  PARTNER2         CHAR(10)  ,  -- FK -> BPVB
  PARTNER3         CHAR(10)  ,  -- FK -> BP001
  WAERS            CUKY      ,  -- FK -> TCURC
  PARTNER4         CHAR(10)  ,  -- FK -> BUT192
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
