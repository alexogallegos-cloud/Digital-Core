-- BSIS  ·  Financial Accounting / GL  ·  arquetipo MASTER  ·  fan-in=1
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BSIS (
  MANDT            CLNT      ,  -- mandante (client)
  BSISID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WAERS            CUKY      ,  -- FK -> TCURX
  PARTNER          CHAR(10)  ,  -- FK -> BUT000
  BUKRS            CHAR(4)   ,  -- FK -> T001
  STMID            CHAR(10)  ,  -- FK -> FEBCL
  NAME1            CHAR(40)  ,  -- nombre / descripcion
  ERDAT            DATS      ,  -- fecha creacion
  LOEVM            CHAR(1)      -- flag de borrado
);
