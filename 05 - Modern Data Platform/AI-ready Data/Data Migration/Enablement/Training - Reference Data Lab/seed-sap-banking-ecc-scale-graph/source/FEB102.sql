-- FEB102  ·  Bank Statement / Channels  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB102 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB102ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB231
  BUKRS            CHAR(4)   ,  -- FK -> T001
  DMEEID           CHAR(10)  ,  -- FK -> DMEE108
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
