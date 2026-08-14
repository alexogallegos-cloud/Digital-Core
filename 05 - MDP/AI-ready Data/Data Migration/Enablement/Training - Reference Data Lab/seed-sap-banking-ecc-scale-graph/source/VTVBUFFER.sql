-- VTVBUFFER  ·  Loans Mgmt (FS-CML)  ·  arquetipo MASTER  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VTVBUFFER (
  MANDT            CLNT      ,  -- mandante (client)
  VTVBUFFERI       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VD186
  DARLEHEN2        CHAR(10)  ,  -- FK -> VD198
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
