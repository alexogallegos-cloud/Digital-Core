-- REGU129  ·  Payments  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU129 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU129ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> FPAYP
  PYORD2           CHAR(10)  ,  -- FK -> REGU205
  PYORD3           CHAR(10)  ,  -- FK -> REGU178
  BUKRS            CHAR(4)   ,  -- FK -> T001
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
