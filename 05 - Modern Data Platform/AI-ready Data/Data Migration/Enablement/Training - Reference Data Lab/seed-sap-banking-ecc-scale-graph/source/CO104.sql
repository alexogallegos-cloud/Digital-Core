-- CO104  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO104 (
  MANDT            CLNT      ,  -- mandante (client)
  CO104ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> CSKA
  KOKRS2           CHAR(10)  ,  -- FK -> COBK
  KOKRS3           CHAR(10)  ,  -- FK -> COKA
  KOKRS4           CHAR(10)  ,  -- FK -> CO181
  KOKRS5           CHAR(10)  ,  -- FK -> CO180
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
