-- FEBCL  ·  Bank Statement / Channels  ·  arquetipo MASTER  ·  fan-in=3
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEBCL (
  MANDT            CLNT      ,  -- mandante (client)
  FEBCLID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WAERS            CUKY      ,  -- FK -> TCURC
  STMID            CHAR(10)  ,  -- FK -> FEB231
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  KOKRS            CHAR(10)  ,  -- FK -> COEP
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
