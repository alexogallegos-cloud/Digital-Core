-- CCARD243  ·  Cards  ·  arquetipo CUST  ·  fan-in=1
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CCARD243 (
  MANDT            CLNT      ,  -- mandante (client)
  CCARD243ID       CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
