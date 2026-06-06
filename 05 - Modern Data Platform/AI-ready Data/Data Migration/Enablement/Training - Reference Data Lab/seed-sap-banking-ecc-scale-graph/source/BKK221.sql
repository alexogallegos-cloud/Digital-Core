-- BKK221  ·  Deposits Mgmt (FS-AM)  ·  arquetipo CUST  ·  fan-in=11
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BKK221 (
  MANDT            CLNT      ,  -- mandante (client)
  BKK221ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
