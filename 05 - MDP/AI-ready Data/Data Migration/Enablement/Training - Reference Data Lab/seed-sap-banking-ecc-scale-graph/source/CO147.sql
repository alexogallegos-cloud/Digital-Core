-- CO147  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO147 (
  MANDT            CLNT      ,  -- mandante (client)
  CO147ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT0ID
  KOKRS            CHAR(10)  ,  -- FK -> CO182
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
