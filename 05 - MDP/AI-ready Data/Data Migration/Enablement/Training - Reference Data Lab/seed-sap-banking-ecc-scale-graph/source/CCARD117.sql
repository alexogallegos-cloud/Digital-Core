-- CCARD117  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD117 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD117ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> FPAYH
  BUKRS            CHAR(4)   ,  -- FK -> T001
  CARDID           CHAR(10)  ,  -- FK -> CCARD241
  WAERS            CUKY      ,  -- FK -> TCURX
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
