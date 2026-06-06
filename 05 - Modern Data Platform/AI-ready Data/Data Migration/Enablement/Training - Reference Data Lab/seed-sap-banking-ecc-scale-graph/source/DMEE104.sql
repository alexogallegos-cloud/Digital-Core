-- DMEE104  ·  Payment Medium (DMEE)  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE104 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE104ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE214
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
