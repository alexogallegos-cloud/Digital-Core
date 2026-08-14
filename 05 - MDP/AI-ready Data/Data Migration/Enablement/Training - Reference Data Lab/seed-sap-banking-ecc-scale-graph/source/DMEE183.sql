-- DMEE183  ·  Payment Medium (DMEE)  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE DMEE183 (
  MANDT            CLNT      ,  -- mandante (client)
  DMEE183ID        CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DMEEID           CHAR(10)  ,  -- FK -> DMEE_PAR
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
