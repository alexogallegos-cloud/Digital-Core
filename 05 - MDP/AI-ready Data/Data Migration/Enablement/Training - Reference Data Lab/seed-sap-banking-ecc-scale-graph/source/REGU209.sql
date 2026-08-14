-- REGU209  ·  Payments  ·  arquetipo CUST  ·  fan-in=5
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU209 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU209ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
