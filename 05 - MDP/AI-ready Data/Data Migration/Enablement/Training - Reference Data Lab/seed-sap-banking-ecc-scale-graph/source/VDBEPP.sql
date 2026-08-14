-- VDBEPP  ·  Loans Mgmt (FS-CML)  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VDBEPP (
  MANDT            CLNT      ,  -- mandante (client)
  VDBEPPID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VD219
  BUKRS            CHAR(4)   ,  -- FK -> T001
  STMID            CHAR(10)  ,  -- FK -> FEB107
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
