-- DMEE194  ·  Payment Medium (DMEE)  ·  arquetipo CUST  ·  fan-in=13
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE194 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE194ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
