-- BS168  ·  Financial Accounting / GL  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BS168 (
  MANDT            CLNT      ,  -- mandante (client)
  BS168ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
