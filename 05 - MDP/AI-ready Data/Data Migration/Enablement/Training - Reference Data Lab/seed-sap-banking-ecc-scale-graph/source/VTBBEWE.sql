-- VTBBEWE  ·  Loans Mgmt (FS-CML)  ·  arquetipo MASTER  ·  fan-in=65
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VTBBEWE (
  MANDT            CLNT      ,  -- mandante (client)
  VTBBEWEID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  BUKRS            CHAR(4)   ,  -- FK -> T001
  DARLEHEN         CHAR(10)  ,  -- FK -> VD212
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
