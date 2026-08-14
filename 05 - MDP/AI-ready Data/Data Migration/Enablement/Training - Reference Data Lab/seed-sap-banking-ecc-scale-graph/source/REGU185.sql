-- REGU185  ·  Payments  ·  arquetipo CUST  ·  fan-in=9
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU185 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU185ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
