-- FEB107  ·  Bank Statement / Channels  ·  arquetipo MASTER  ·  fan-in=8
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB107 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB107ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  STMID            CHAR(10)  ,  -- FK -> FEB206
  STMID2           CHAR(10)  ,  -- FK -> FEB231
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  STMID3           CHAR(10)  ,  -- FK -> FEB106
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
