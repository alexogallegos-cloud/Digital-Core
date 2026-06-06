-- FCC_HEAD  ·  Cards  ·  arquetipo MASTER  ·  fan-in=3
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FCC_HEAD (
  MANDT            CLNT      ,  -- mandante (client)
  FCCID            CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARD217
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PARTNER          CHAR(10)  ,  -- FK -> BUT103
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
