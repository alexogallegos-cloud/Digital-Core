-- REGU128  ·  Payments  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU128 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU128ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> PAYRQ
  CARDID           CHAR(10)  ,  -- FK -> BKK_CARD
  PYORD2           CHAR(10)  ,  -- FK -> FPAYH
  PYORD3           CHAR(10)  ,  -- FK -> REGU192
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
