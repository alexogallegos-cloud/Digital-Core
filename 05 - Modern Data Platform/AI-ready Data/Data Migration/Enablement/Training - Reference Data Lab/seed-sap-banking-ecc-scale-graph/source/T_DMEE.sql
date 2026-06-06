-- T_DMEE  ·  Payment Medium (DMEE)  ·  arquetipo MASTER  ·  fan-in=14
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE T_DMEE (
  MANDT            CLNT      ,  -- mandante (client)
  TID              CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE206
  DMEEID2          CHAR(10)  ,  -- FK -> DMEE214
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
