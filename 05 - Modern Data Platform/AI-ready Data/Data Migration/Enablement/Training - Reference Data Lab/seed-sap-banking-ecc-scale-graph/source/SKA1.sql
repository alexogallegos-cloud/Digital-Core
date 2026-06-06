-- SKA1  ·  Financial Accounting / GL  ·  arquetipo MASTER  ·  fan-in=142
-- G/L account master (chart of accounts)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE SKA1 (
  MANDT            CLNT      ,  -- mandante (client)
  SKA1ID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  BUKRS            CHAR(4)   ,  -- FK -> T001
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
