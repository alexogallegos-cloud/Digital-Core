-- BUT217  ·  Business Partner  ·  arquetipo CUST  ·  fan-in=20
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT217 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT217ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
