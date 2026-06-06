-- FEB105  ·  Bank Statement / Channels  ·  arquetipo MASTER  ·  fan-in=13
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB105 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB105ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB231
  STMID2           CHAR(10)  ,  -- FK -> FEB206
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
