-- DMEE_TREE_HEAD  ·  Payment Medium (DMEE)  ·  arquetipo MASTER  ·  fan-in=1
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE_TREE_HEAD (
  MANDT            CLNT      ,  -- mandante (client)
  DMEEID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID2          CHAR(10)  ,  -- FK -> DMEE202
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
