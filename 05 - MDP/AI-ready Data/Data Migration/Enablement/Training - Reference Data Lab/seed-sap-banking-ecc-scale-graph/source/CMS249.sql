-- CMS249  ·  Collateral (BCA)  ·  arquetipo CUST  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CMS249 (
  MANDT            CLNT      ,  -- mandante (client)
  CMS249ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
