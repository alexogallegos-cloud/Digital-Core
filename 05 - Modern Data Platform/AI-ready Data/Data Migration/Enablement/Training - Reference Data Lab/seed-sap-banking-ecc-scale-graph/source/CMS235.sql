-- CMS235  ·  Collateral (BCA)  ·  arquetipo CUST  ·  fan-in=15
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS235 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS235ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
