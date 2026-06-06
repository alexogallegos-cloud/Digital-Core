-- VDPSO  ·  Loans Mgmt (FS-CML)  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE VDPSO (
  MANDT            CLNT      ,  -- mandante (client)
  VDPSOID          CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  DARLEHEN         CHAR(10)  ,  -- FK -> VDARL
  DARLEHEN2        CHAR(10)  ,  -- FK -> VDBEPK
  DARLEHEN3        CHAR(10)  ,  -- FK -> VTBFHAPO
  DARLEHEN4        CHAR(10)  ,  -- FK -> VD223
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
