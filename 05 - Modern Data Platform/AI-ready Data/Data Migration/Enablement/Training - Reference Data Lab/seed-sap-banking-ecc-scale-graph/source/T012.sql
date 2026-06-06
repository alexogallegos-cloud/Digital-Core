-- T012  ·  Payments  ·  arquetipo CUST  ·  fan-in=0
-- House banks
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE T012 (
  MANDT            CLNT      ,  -- mandante (client)
  T012ID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
