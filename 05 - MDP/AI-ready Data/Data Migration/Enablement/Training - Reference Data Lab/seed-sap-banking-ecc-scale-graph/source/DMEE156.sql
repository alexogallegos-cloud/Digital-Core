-- DMEE156  ·  Payment Medium (DMEE)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE156 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE156ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  DMEEID           CHAR(10)  ,  -- FK -> DMEE_TREE_NODE
  DMEEID2          CHAR(10)  ,  -- FK -> DMEE206
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
