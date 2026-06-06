-- TB001  ·  Business Partner  ·  arquetipo MASTER  ·  fan-in=8
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TB001 (
  MANDT            CLNT      ,  -- mandante (client)
  TB001ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PARTNER          CHAR(10)  ,  -- FK -> BUT217
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
