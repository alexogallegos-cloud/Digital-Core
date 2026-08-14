-- T001  ·  Financial Accounting / GL  ·  arquetipo CUST  ·  fan-in=925
-- Company codes — referenced by every posting
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE T001 (
  MANDT            CLNT      ,  -- mandante (client)
  T001ID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
