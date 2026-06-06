-- BUT118  ·  Business Partner  ·  arquetipo TXN  ·  fan-in=0
-- (generada)
-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.
CREATE TABLE BUT118 (
  MANDT            CLNT      ,  -- mandante (client)
  BUT118ID         CHAR(18)  ,  -- clave primaria (ALPHA, ceros a la izq.)
  PARTNER          CHAR(10)  ,  -- FK -> BUT050
  BANKL            CHAR(10)  ,  -- FK -> BNKA
  PARTNER2         CHAR(10)  ,  -- FK -> BUT102
  PARTNER3         CHAR(10)  ,  -- FK -> BUT201
  PARTNER4         CHAR(10)  ,  -- FK -> BUT190
  BUKRS            CHAR(4)   ,  -- FK -> T001
  BUDAT            DATS      ,  -- fecha contable
  BLDAT            DATS      ,  -- fecha documento
  DMBTR            CURR(15)  ,  -- importe (minor units, ver TCURX)
  SHKZG            CHAR(1)      -- debe/haber
);
