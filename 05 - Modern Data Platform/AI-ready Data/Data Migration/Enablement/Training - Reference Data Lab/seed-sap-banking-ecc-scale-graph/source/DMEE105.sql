-- DMEE105  ·  Payment Medium (DMEE)  ·  arquetipo MASTER  ·  fan-in=7
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE105 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE105ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE209
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PARTNER          CHAR(10)  ,  -- FK -> TB008S
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
