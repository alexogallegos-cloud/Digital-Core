-- TCURR  ·  Financial Accounting / GL  ·  arquetipo CUST  ·  fan-in=0
-- Exchange rates
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TCURR (
  MANDT            CLNT      ,  -- mandante (client)
  TCURRID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
