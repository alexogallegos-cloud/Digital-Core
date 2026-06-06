-- VD129  ·  Loans Mgmt (FS-CML)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VD129 (
  MANDT            CLNT      ,  -- mandante (client)
  VD129ID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  SAKNR            CHAR(10)  ,  -- FK -> SKB1
  DARLEHEN         CHAR(10)  ,  -- FK -> VTBBEWE
  DARLEHEN2        CHAR(10)  ,  -- FK -> VD220
  BUKRS            CHAR(4)   ,  -- FK -> T001
  SAKNR2           CHAR(10)  ,  -- FK -> SKA1
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
