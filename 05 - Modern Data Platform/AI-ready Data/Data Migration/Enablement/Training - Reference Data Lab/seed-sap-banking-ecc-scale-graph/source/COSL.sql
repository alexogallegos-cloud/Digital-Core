-- COSL  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE COSL (
  MANDT            CLNT      ,  -- mandante (client)
  COSLID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT104
  KOKRS            CHAR(10)  ,  -- FK -> COKA
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  KOKRS2           CHAR(10)  ,  -- FK -> CO179
  KOKRS3           CHAR(10)  ,  -- FK -> CO194
  BUKRS            CHAR(4)   ,  -- FK -> T001
  SAKNR2           CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
