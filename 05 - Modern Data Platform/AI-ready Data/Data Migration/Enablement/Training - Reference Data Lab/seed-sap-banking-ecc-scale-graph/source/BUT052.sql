-- BUT052  ·  Business Partner  ·  arquetipo MASTER  ·  fan-in=8
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT052 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT052ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT195
  PARTNER2         CHAR(10)  ,  -- FK -> BUT205
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
