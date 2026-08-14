-- CCARD227  ·  Cards  ·  arquetipo CUST  ·  fan-in=3
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD227 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD227ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
