-- BUT020  ·  Business Partner  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT020 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT020ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT195
  PARTNER2         CHAR(10)  ,  -- FK -> BUT210
  PARTNER3         CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
