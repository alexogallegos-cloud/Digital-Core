-- CMS119  ·  Collateral (BCA)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS119 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS119ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> COKA
  COLID            CHAR(10)  ,  -- FK -> TCMS_OBJTYPE
  COLID2           CHAR(10)  ,  -- FK -> CMS101
  COLID3           CHAR(10)  ,  -- FK -> CMS227
  COLID4           CHAR(10)  ,  -- FK -> CMS212
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
