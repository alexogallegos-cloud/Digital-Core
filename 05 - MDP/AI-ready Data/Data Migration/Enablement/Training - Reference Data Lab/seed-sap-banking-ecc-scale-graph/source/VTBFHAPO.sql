-- VTBFHAPO  ·  Loans Mgmt (FS-CML)  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VTBFHAPO (
  MANDT            CLNT      ,  -- mandante (client)
  VTBFHAPOID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VD192
  DARLEHEN2        CHAR(10)  ,  -- FK -> VD207
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
