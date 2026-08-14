-- TB033  ·  Cards  ·  arquetipo MASTER  ·  fan-in=25
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TB033 (
  MANDT            CLNT      ,  -- mandante (client)
  TB033ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CARDID           CHAR(10)  ,  -- FK -> CCARD251
  CARDID2          CHAR(10)  ,  -- FK -> CCARD248
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
