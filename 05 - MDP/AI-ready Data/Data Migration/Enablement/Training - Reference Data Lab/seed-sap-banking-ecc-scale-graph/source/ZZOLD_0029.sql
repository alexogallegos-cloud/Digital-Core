-- ZZOLD_0029  ·  obsolete  ·  arquetipo TXN  ·  fan-in=4
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE ZZOLD_0029 (
  MANDT            CLNT      ,  -- mandante (client)
  ZZOLDID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  REF              CHAR(10)  ,  -- FK -> ZZOLD_0043
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
