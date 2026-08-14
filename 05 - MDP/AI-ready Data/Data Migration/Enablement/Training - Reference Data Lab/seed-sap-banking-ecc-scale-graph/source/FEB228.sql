-- FEB228  ·  Bank Statement / Channels  ·  arquetipo CUST  ·  fan-in=4
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE FEB228 (
  MANDT            CLNT      ,  -- mandante (client)
  FEB228ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
