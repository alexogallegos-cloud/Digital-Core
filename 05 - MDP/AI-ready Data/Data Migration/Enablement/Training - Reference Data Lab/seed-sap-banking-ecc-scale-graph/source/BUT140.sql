-- BUT140  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT140 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT140ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT105
  PARTNER2         CHAR(10)  ,  -- FK -> BUT103
  PARTNER3         CHAR(10)  ,  -- FK -> TB001
  PARTNER4         CHAR(10)  ,  -- FK -> BUT195
  PARTNER5         CHAR(10)  ,  -- FK -> BUT203
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
