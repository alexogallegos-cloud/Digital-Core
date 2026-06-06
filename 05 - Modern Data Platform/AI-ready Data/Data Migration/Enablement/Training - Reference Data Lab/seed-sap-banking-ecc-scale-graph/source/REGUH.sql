-- REGUH  ·  Payments  ·  arquetipo MASTER  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGUH (
  MANDT            CLNT      ,  -- mandante (client)
  REGUHID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WAERS            CUKY      ,  -- FK -> TCURX
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
