-- ZZOLD_0025  ·  obsolete  ·  arquetipo TXN  ·  fan-in=1
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE ZZOLD_0025 (
  MANDT            CLNT      ,  -- mandante (client)
  ZZOLDID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  REF              CHAR(10)  ,  -- FK -> ZZOLD_0006
  REF2             CHAR(10)  ,  -- FK -> ZZOLD_0047
  REF3             CHAR(10)  ,  -- FK -> ZZOLD_0040
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
