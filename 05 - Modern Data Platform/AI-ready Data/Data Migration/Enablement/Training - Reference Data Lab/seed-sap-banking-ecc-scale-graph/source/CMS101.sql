-- CMS101  ·  Collateral (BCA)  ·  arquetipo MASTER  ·  fan-in=106
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS101 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS101ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WAERS            CUKY      ,  -- FK -> TCURC
  COLID            CHAR(10)  ,  -- FK -> CMS222
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
