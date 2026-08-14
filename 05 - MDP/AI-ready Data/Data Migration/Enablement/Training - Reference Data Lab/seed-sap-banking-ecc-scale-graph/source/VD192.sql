-- VD192  ·  Loans Mgmt (FS-CML)  ·  arquetipo CUST  ·  fan-in=8
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VD192 (
  MANDT            CLNT      ,  -- mandante (client)
  VD192ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  WERT             CHAR(20)  ,  -- valor de configuracion
  DESCR            CHAR(40)     -- descripcion
);
