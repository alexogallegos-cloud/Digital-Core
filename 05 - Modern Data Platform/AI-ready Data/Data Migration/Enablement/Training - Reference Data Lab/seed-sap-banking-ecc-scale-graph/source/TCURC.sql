-- TCURC  ·  Financial Accounting / GL  ·  arquetipo CUST  ·  fan-in=253
-- Currency codes
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TCURC (
  MANDT            CLNT      ,  -- mandante (client)
  TCURCID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
