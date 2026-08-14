-- REGUP  ·  Payments  ·  arquetipo MASTER  ·  fan-in=3
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGUP (
  MANDT            CLNT      ,  -- mandante (client)
  REGUPID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> REGU181
  PYORD2           CHAR(10)  ,  -- FK -> REGU205
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
