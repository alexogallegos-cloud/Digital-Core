-- ZZOLD_0034  ·  obsolete  ·  arquetipo TXN  ·  fan-in=2
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE ZZOLD_0034 (
  MANDT            CLNT      ,  -- mandante (client)
  ZZOLDID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  REF              CHAR(10)  ,  -- FK -> ZZOLD_0012
  REF2             CHAR(10)  ,  -- FK -> ZZOLD_0059
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
