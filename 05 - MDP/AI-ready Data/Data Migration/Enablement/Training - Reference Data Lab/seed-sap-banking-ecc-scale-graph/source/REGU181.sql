-- REGU181  ·  Payments  ·  arquetipo CUST  ·  fan-in=11
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU181 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU181ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
