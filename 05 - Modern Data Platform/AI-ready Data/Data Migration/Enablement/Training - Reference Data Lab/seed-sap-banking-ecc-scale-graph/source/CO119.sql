-- CO119  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO119 (
  MANDT            CLNT      ,  -- mandante (client)
  CO119ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VDBEPK
  KOKRS            CHAR(10)  ,  -- FK -> COKA
  KOKRS2           CHAR(10)  ,  -- FK -> COSS
  KOKRS3           CHAR(10)  ,  -- FK -> CO194
  KOKRS4           CHAR(10)  ,  -- FK -> CO185
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
