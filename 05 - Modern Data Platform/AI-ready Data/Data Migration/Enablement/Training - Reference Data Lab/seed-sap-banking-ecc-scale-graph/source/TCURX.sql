-- TCURX  ·  Financial Accounting / GL  ·  arquetipo CUST  ·  fan-in=246
-- Decimal places per currency (amount conversion)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE TCURX (
  MANDT            CLNT      ,  -- mandante (client)
  TCURXID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
