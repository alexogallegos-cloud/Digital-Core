-- REGU108  ·  Payments  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU108 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU108ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> T042
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  PYORD2           CHAR(10)  ,  -- FK -> REGU181
  PYORD3           CHAR(10)  ,  -- FK -> REGU183
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
