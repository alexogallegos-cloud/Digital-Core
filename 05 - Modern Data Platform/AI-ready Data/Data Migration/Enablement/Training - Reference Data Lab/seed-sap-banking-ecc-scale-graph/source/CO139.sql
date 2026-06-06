-- CO139  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO139 (
  MANDT            CLNT      ,  -- mandante (client)
  CO139ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> COSS
  KOKRS2           CHAR(10)  ,  -- FK -> COBK
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  KOKRS3           CHAR(10)  ,  -- FK -> CO185
  KOKRS4           CHAR(10)  ,  -- FK -> CO194
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  SAKNR2           CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
