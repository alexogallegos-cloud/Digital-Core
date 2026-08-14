-- REGU165  ·  Payments  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE REGU165 (
  MANDT            CLNT      ,  -- mandante (client)
  REGU165ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PYORD            CHAR(10)  ,  -- FK -> T042Z
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
