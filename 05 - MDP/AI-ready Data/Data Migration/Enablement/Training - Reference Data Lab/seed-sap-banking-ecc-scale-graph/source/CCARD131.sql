-- CCARD131  ·  Cards  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD131 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD131ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARDEC
  CARDID2          CHAR(10)  ,  -- FK -> FCC_DOC
  WAERS            CUKY      ,  -- FK -> TCURX
  BUKRS            CHAR(4)   ,  -- FK -> T001
  WAERS2           CUKY      ,  -- FK -> TCURC
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
