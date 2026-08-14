-- VD176  ·  Loans Mgmt (FS-CML)  ·  arquetipo TEXT  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VD176 (
  MANDT            CLNT      ,  -- mandante (client)
  VD176ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VDBEPK
  SPRAS            LANG      ,  -- clave de idioma
  TXTLG            CHAR(50)     -- texto descriptivo
);
