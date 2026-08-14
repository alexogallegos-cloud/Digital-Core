-- CO126  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO126 (
  MANDT            CLNT      ,  -- mandante (client)
  CO126ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> COBK
  KOKRS2           CHAR(10)  ,  -- FK -> CO185
  BUKRS            CHAR(4)   ,  -- FK -> T001
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
