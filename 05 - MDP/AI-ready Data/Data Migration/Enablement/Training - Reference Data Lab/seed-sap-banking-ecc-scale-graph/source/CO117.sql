-- CO117  ·  Controlling  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO117 (
  MANDT            CLNT      ,  -- mandante (client)
  CO117ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARDEC
  KOKRS            CHAR(10)  ,  -- FK -> COBK
  CARDID2          CHAR(10)  ,  -- FK -> FCC_DOC
  DMEEID           CHAR(10)  ,  -- FK -> DMEE211
  KOKRS2           CHAR(10)  ,  -- FK -> CO181
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
