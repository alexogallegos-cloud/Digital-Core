-- BUT179  ·  Business Partner  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT179 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT179ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT050
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
