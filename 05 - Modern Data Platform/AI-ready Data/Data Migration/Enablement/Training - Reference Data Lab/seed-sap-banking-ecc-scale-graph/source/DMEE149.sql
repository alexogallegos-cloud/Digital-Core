-- DMEE149  ·  Payment Medium (DMEE)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE149 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE149ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE106
  DMEEID2          CHAR(10)  ,  -- FK -> DMEE_TREE_NODE
  DMEEID3          CHAR(10)  ,  -- FK -> DMEE101
  DMEEID4          CHAR(10)  ,  -- FK -> DMEE191
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
