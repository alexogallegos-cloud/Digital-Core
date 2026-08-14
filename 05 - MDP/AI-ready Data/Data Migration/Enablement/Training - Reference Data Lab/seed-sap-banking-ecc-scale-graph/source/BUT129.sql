-- BUT129  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT129 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT129ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT051
  SAKNR            CHAR(10)  ,  -- FK -> SKA1
  CARDID           CHAR(10)  ,  -- FK -> FCC_DOC
  PARTNER2         CHAR(10)  ,  -- FK -> BUT217
  PARTNER3         CHAR(10)  ,  -- FK -> BUT205
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS            CUKY      ,  -- FK -> TCURX
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
