-- CMS107  ·  Collateral (BCA)  ·  arquetipo MASTER  ·  fan-in=4
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS107 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS107ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  COLID            CHAR(10)  ,  -- FK -> CMS255
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  STMID            CHAR(10)  ,  -- FK -> FEB102
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
