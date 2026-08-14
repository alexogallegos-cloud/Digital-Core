-- CO170  ·  Controlling  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CO170 (
  MANDT            CLNT      ,  -- mandante (client)
  CO170ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  KOKRS            CHAR(10)  ,  -- FK -> COBK
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
