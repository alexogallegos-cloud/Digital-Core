-- CO181  ·  Controlling  ·  arquetipo CUST  ·  fan-in=7
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO181 (
  MANDT            CLNT      ,  -- mandante (client)
  CO181ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
