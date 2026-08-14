-- BKK41  ·  Deposits Mgmt (FS-AM)  ·  arquetipo MASTER  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK41 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK41ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KONTO            CHAR(10)  ,  -- FK -> BKK216
  KONTO2           CHAR(10)  ,  -- FK -> BKK208
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
