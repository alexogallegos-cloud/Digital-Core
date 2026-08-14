-- DMEE206  ·  Payment Medium (DMEE)  ·  arquetipo CUST  ·  fan-in=28
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE206 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE206ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
