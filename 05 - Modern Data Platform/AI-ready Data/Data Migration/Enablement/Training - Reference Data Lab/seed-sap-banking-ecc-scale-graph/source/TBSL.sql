-- TBSL  ·  Financial Accounting / GL  ·  arquetipo CUST  ·  fan-in=1
-- Posting keys
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TBSL (
  MANDT            CLNT      ,  -- mandante (client)
  TBSLID           CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
