-- CRM_0004  ·  crm  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE CRM_0004 (
  CRMID            CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  CRM_ID           CHAR(10)  ,  -- FK -> CRM_ACCOUNT
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
